local vec = require "vec"

---@class mat : vec[]
local M = {}

function M.newempty(w)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.new()
	end
	return newmat
end

---Создает новую матрицу и заполняет ее нолями
---@param w number
---@param h number
---@return mat
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
---@return mat
function M.newsingle(w, h)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.newsingle(h)
	end
	return newmat
end

---Копирует заданную матрицу
---@param mat mat
---@return mat
function M.copy(mat)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		newmat[i] = vec.copy(mat[i])
	end
	return newmat
end

---Трфнспонирование матрицы
---@param mat mat
---@return mat
function M.transpos(mat)
	local cols = #mat
	local rows = #mat[1]

	if cols == rows then
		for w = 1, cols do
			for h = w + 1, rows do
				mat[w][h], mat[h][w] = mat[h][w], mat[w][h]
			end
		end
		return mat
	else
		return M.__transpos(mat)
	end
end

---Транспонирование матрицу
---@param mat mat
---@return mat
function M.__transpos(mat, cols, rows)
	local newmat = M.newempty(#mat[1])
	for w, vec in ipairs(mat) do
		for h, num in ipairs(vec) do
			newmat[h][w] = num
		end
	end
	return newmat
end

---Сумма матриц
---@param mata mat
---@param matb mat
---@return mat
function M.add(mata, matb)
	for i = 1, #mata do
		vec.add(mata[i], matb[i])
	end
	return mata
end

---Сумма матриц
---@param mata mat
---@param matb mat
---@return mat
function M.__add(mata, matb)
	local newmat = setmetatable({}, M)
	for i = 1, #mata do
		newmat[i] = vec.__add(mata[i], matb[i])
	end
	return newmat
end

---Сумма матрицы и числа
---@param mat mat
---@param n number
---@return mat
function M.addnum(mat, n)
	for i = 1, #mat do
		vec.addnum(mat[i], n)
	end
	return mat
end

---Сумма матрицы и числа
---@param mat mat
---@param n number
---@return mat
function M.__addnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		newmat[i] = vec.__addnum(mat[i], n)
	end
	return newmat
end

---Разница матриц
---@param mata mat
---@param matb mat
---@return mat
function M.sub(mata, matb)
	for i = 1, #mata do
		vec.sub(mata[i], matb[i])
	end
	return mata
end

---Разница матриц
---@param mata mat
---@param matb mat
---@return mat
function M.__sub(mata, matb)
	local newmat = setmetatable({}, M)
	for i = 1, #mata do
		newmat[i] = vec.__sub(mata[i], matb[i])
	end
	return newmat
end

---Вычитание числа из матрицы
---@param mat mat
---@param n number
---@return mat
function M.subnum(mat, n)
	for i = 1, #mat do
		vec.subnum(mat[1], n)
	end
	return mat
end

---Вычитание числа из матрицы
---@param mat mat
---@param n number
---@return mat
function M.__subnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		table.insert(newmat, vec.__subnum(mat[1], n))
	end
	return newmat
end

---Умножение 2х матриц
---@param mata mat
---@param matb mat
---@return mat
function M.__mul(mata, matb)
	local rows = #mata
	local cols = #mata[1]
	local newmat = setmetatable({}, M)
	local matb = M.__transpos(matb)
	for i = 1, rows do
		local v = vec.new()
		for i2 = 1, cols do
			v[i2] = vec.sum(vec.__mul(mata[i], matb[i2]))
		end
		newmat[i] = v
	end
	return newmat
end

---Умножение матрицы на вектор
---@param mat mat
---@param v table
---@return table
function M.mulvec(mat, v)
	local newvec = setmetatable({}, vec)
	for i = 1, #mat do
		newvec[i] = vec.sum(vec.mul(mat[i], v))
	end
	return newvec
end

---Умножение матрицы на вектор
---@param mat mat
---@param v table
---@return table
function M.__mulvec(mat, v)
	local newvec = setmetatable({}, vec)
	for i = 1, #mat do
		newvec[i] = vec.sum(vec.__mul(mat[i], v))
	end
	return newvec
end

---Умножение матрицы на число
---@param mat mat
---@param n number
---@return mat
function M.mulnum(mat, n)
	for i = 1, #mat do
		vec.mulnum(mat[i], n)
	end
	return mat
end

---Умножение матрицы на число
---@param mat mat
---@param n number
---@return mat
function M.__mulnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		newmat[i] = vec.__mulnum(mat[i], n)
	end
	return newmat
end

---Деление матрицы на число
---@param mat mat
---@param n number
---@return mat
function M.divnum(mat, n)
	for i = 1, #mat do
		vec.divnum(mat[1], n)
	end
	return mat
end

---Деление матрицы на число
---@param mat mat
---@param n number
---@return mat
function M.__divnum(mat, n)
	local newmat = setmetatable({}, M)
	for i = 1, #mat do
		newmat[i] = vec.__divnum(mat[1], n)
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

M.__index = M
M.__tostring = M.tostring

M = setmetatable(M, {__call = function(self, ...)
	return setmetatable(table.pack(...), self)
end})

return M
