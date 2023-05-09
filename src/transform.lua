local M = {}

---Переводит угловой вектор направления в декартовый
---@param v number[]
---@return number[]
function M.rad2dec(v)
	local sin2 = math.sin(v[2])
	local dir = {
		sin2 * math.cos(v[1]),
		sin2 * math.sin(v[1]),
		math.cos(v[2]),
	}

	return dir
end

---Переводит декартовый вектор направления в угловой
---@param v number[]
---@return number[] angles
---@return number len
function M.dec2rad(v)
	local len = M.len(v)
	local out = {
		math.atan(v[1], v[2]),
		math.atan(len, v[3])
	}

	return out, len
end

return M
