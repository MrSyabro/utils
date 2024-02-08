local obj = require "obj"

---@class EnvPackage : Object
---@field path string
---@field loaded table
---@field searchers table
---@field preload table
---@field config string
local package_class = obj:new "Package"
package_class.path = package.path
package_class.searchpath = package.searchpath
package_class.loaded = package.loaded
package_class.preload = package.preload
package_class.env = _ENV
package_class.config = package.config
package_class.searchers = {
	function(package, name)
		local preloadpkg = package.preload[name]
		if preloadpkg then
			return preloadpkg
		else
			return nil, ("no field package.preload['%s']"):format(name)
		end
	end,
	function(self, name)
		local filename, error = package.searchpath(name, self.path)
		if filename then
			local f = assert(loadfile(filename, "bt", self.env))
			return f, filename
		else
			return nil, error
		end
	end
}

function package_class:load(name)
	local loaded = self.loaded[name]
	if loaded then return loaded end

	local err = {("module '%s' not found:"):format(name)}
	for _, searcher in ipairs(self.searchers) do
		local pkg, path = searcher(self, name)
		if pkg then
			local out = pkg()
			self.loaded[name] = out or true
			return out, path
		else
			table.insert(err, path)
		end
	end
	error(table.concat(err, "\n\t"), 2)
end

function package_class:dofile(filename)
	local f = assert(loadfile(filename, "bt", self.env))
	return f()
end

function package_class:new()
	local new_instance = obj.new(package_class)
	local loaded = {__index = self.loaded}
	new_instance.loaded = setmetatable(loaded, loaded)
	local searchers = {__index = self.searchers}
	new_instance.searchers = setmetatable(searchers, searchers)

	local function require(name)
		return new_instance:load(name)
	end

	local env = {
		__index = self.env,
		package = new_instance,
		require = require,
		dofile = function(filename)
			return new_instance:dofile(filename)
		end
	}
	new_instance.env = setmetatable(env, env)

	return new_instance, require
end

return package_class
