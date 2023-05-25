local vec = require "vec"
local M = {}

---Переводит угловой вектор направления в декартовый
---@param v number[]
---@return vec
function M.rad2dec(v)
	local sin2 = math.sin(v[2])
	local dir = setmetatable({
		sin2 * math.cos(v[1]),
		sin2 * math.sin(v[1]),
		math.cos(v[2]),
	}, vec)

	return dir
end

---Переводит декартовый вектор направления в угловой
---@param v number[]
---@return vec angles
---@return number len
function M.dec2rad(v)
	local len = vec.len(v)
	local out = setmetatable({
		math.atan(v[1], v[2]),
		math.atan(len, v[3])
	}, vec)

	return out, len
end

return M
