local M = {}

---Deserialize string
---@param str string serialized lua data
---@param ser_func boolean serialize function or not (access to load())
---@return table?
---@return string?
function M.str(str, ser_func)
	local f, err = load("return " .. str, "desrialize", "bt", {
		string = string,
		os = os,
	})
	if not f then return nil, err end
	local data = f()
	return data
end

---Deserialize file
---@param filepath string
---@return table?
---@return string?
function M.file(filepath)
	local file, err = io.open(filepath)
	if not file then return nil, err end
	local str = file:read "a"
	file:close()
	return M.str(str, false)
end

return setmetatable(M, { __call = function(self, ...) return self.str(...) end })
