local vec = require "vec"

local M = {}

---Создает новую матрицу и заполняет ее нолями
---@param w number
---@param h number
---@return table[table]
function M.newzero(w, h)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.newzero(h)
	end
	return newmat
end

---Создает новую единичную матрицу
---@param w number
---@param h number
---@return table[table]
function M.newsingle(w, h)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.newsingle(h)
	end
	return newmat
end

---Копирует заданную матрицу
---@param mat table[table]
---@return table[table]
function M.copy(mat)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		newmat[i] = vec.copy(mat[i])
	end
	return newmat
end

---Транспонирование матрицу
---@param mat table[table]
---@return table[table]
function M.transpos(mat)
	local newmat = M.newzero(#mat[1], #mat)
	for w, vec in ipairs(mat) do
		for h, num in ipairs(vec) do
			newmat[h][w] = num
		end
	end
	return newmat
end

---Сумма матриц
---@param mata table[table]
---@param matb table[table]
---@return table[table]
function M.add(mata, matb)
	local newmat = setmetatable({}, M)
	for i = 1, #mata do
		table.insert(newmat, vec.add(mata[i], matb[2]))
	end
	return newmat
end

---Сумма матрицы и числа
---@param mat table[table]
---@param n number
---@return table[table]
function M.addnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		table.insert(newmat, vec.addnum(mat[1], n))
	end
	return newmat
end

---Разница матриц
---@param mata table[table]
---@param matb table[table]
---@return table[table]
function M.sub(mata, matb)
	local newmat = setmetatable({}, M)
	for i = 1, #mata do
		table.insert(newmat, vec.sub(mata[i], matb[2]))
	end
	return newmat
end

---Вычитание числа из матрицы
---@param mat table[table]
---@param n number
---@return table[table]
function M.subnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		table.insert(newmat, vec.subnum(mat[1], n))
	end
	return newmat
end

---Умножение 2х матриц
---@param mata table[table]
---@param matb table[table]
---@return table[table]
function M.mul(mata, matb)
	local newmat = M.newzero(#mata, #mata[1])
	local matb = M.transpos(matb)
	for i = 1, #mata do
		for i2 = 1, #mata[1] do
			newmat[i][i2] = vec.sum(vec.mul(mata[i], matb[i2]))
		end
	end
	return newmat
end

---Умножение матрицы на вектор
---@param mat table[table]
---@param v table
---@return table
function M.mulvec(mat, v)
	local newvec = setmetatable({}, vec)
	for i = 1, #mat do
		newvec[i] = vec.sum(vec.mul(mat[i], v))
	end
	return newvec
end

---Умножение матрицы на число
---@param mat table[table]
---@param n number
---@return table[table]
function M.mulnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		table.insert(newmat, vec.mulnum(mat[1], n))
	end
	return newmat
end

---Деление матрицы на число
---@param mat table[table]
---@param n number
---@return table[table]
function M.divnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		table.insert(newmat, vec.divnum(mat[1], n))
	end
	return newmat
end


function M.tostring(mat)
	local out = {}
	for i = 1, #mat do
		table.insert(out, tostring(mat[i]))
	end
	return "{\n\t"..table.concat(out, ",\n\t").."\n}\n"
end

M.__add = M.add
M.__sub = M.sub
M.__mul = M.mul

M.__tostring = M.tostring

return M
