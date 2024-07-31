local M = {}

---Deserialize string
---@param str string serialized lua data
---@return table?
---@return string?
function M.str(str)
	local f = assert(load("return " .. str, "desrialization", "t", {}))
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
	return M.str(str)
end

return setmetatable(M, { __call = function(self, ...) return self.str(...) end })
