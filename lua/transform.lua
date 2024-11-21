local vec = require "vec"
local vnew, vlen = vec.new, vec.len
local mcos, msin, matan = math.cos, math.sin, math.atan

local M = {}

---Переводит угловой vec2 в декартовый vec3
---@param v vec2
---@return vec3
function M.rad2dec(v)
	local sin2 = msin(v[2])
	local dir = vnew(
		sin2 * mcos(v[1]),
		sin2 * msin(v[1]),
		mcos(v[2])
	)
	return dir
end

---Переводит декартовый vec3 в угловой vec2
---@param v vec3
---@return vec2 angles
---@return number len
function M.dec2rad(v)
	local len = vlen(v)
	local out = vnew(
		matan(v[1], v[2]),
		matan(len, v[3])
	)
	return out, len
end

---Перводит угол в декартовый vec2
---@param a number
---@return vec2
function M.v2rad2dec(a)
	return vnew(mcos(a), msin(a))
end

---Переводит декартовый vec2 в угол
---@param v vec2
---@return number
function M.v2dec2rad(v)
	return matan(v[2], v[1])
end

---Комплексный поворот декартвого vec2 на декартовый vec2
---@param veca vec2
---@param vecb vec2
function M.__v2rotv2(veca, vecb)
	return vnew(veca[1]*vecb[1] - veca[2]*vecb[2], veca[1]*vecb[2] + veca[2]*vecb[1])
end

---Комплексный поворот декартвого vec2 на декартовый vec2
---@param veca vec2 будет изменен
---@param vecb vec2
function M.v2rotv2(veca, vecb)
	local a1,a2, b1,b2 = veca[1], veca[2], vecb[1], vecb[2]
	veca[1] = a1*b1 - a2*b2
	veca[2] = a1*b2 + a2*b1
	return veca
end

return M
