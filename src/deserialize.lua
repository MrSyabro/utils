local M = {}

---Deserialize string
---@param str string serialized lua data
---@param ser_func boolean serialize function or not (access to load())
---@return table?
---@return string?
function M.deser(str, ser_func)
	local f, err = load("return "..str, "desrialize", "tb", {load = (ser_func and load) or function() end})
	if not f then return nil, err end
	local data = f()
	return data
end

---Deserialize file
---@param filepath string
---@return nil
---@return string?
function M.deser_file(filepath)
	local file, err = io.open(filepath)
	if not file then return nil, err end
	local str = file:read("a")
	file:close()
	return M.deser(str, false)
end

return M
