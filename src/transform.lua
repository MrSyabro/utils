local vec = require "vec"
local M = {}

---Переводит угловой vec2 в декартовый vec3
---@param v number[]
---@return vec
function M.rad2dec(v)
	local sin2 = math.sin(v[2])
	local dir = vec(
		sin2 * math.cos(v[1]),
		sin2 * math.sin(v[1]),
		math.cos(v[2]))

	return dir
end

---Переводит декартовый vec3 в угловой vec2
---@param v number[]
---@return vec angles
---@return number len
function M.dec2rad(v)
	local len = vec.len(v)
	local out = vec(
		math.atan(v[1], v[2]),
		math.atan(len, v[3])
	)

	return out, len
end

---Перводит угол в декартовый vec2
---@param a number
---@return vec
function M.v2rad2dec(a)
	local out = vec(math.cos(a), math.sin(a))

	return out
end

---Переводит декартовый vec2 в угол
---@param v number[]
---@return number
function M.v2dec2rad(v)
	local out = math.atan(v[1], v[2])

	return out
end

return M
