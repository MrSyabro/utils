local M = {}

local env = {
	string = string,
	math = math,
	os = {
		getenv = os.getenv,
		time = os.time,
		date = os.date,
		difftime = os.difftime,
		tmpname = os.tmpname
	},
}
env.__index = env

---Deserialize string
---@param str string serialized lua data
---@param ser_func boolean serialize function or not (access to load())
---@return table?
---@return string?
function M.str(str, ser_func)
	local newenv = setmetatable({}, env)
	local f, err = load("return " .. str, "desrialize", "t", newenv)
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
