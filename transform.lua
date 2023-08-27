local vec = require "vec"
local mcos, msin, matan = math.cos, math.sin, math.atan

local M = {}

---Переводит угловой vec2 в декартовый vec3
---@param v number[]
---@return vec
function M.rad2dec(v)
	local sin2 = mcos(v[2])
	local dir = vec(
		sin2 * mcos(v[1]),
		sin2 * msin(v[1]),
		mcos(v[2]))

	return dir
end

---Переводит декартовый vec3 в угловой vec2
---@param v number[]
---@return vec angles
---@return number len
function M.dec2rad(v)
	local len = vec.len(v)
	local out = vec(
		matan(v[1], v[2]),
		matan(len, v[3])
	)

	return out, len
end

---Перводит угол в декартовый vec2
---@param a number
---@return vec
function M.v2rad2dec(a)
	local out = vec(mcos(a), msin(a))

	return out
end

---Переводит декартовый vec2 в угол
---@param v number[]
---@return number
function M.v2dec2rad(v)
	local out = matan(v[1], v[2])

	return out
end

return M
