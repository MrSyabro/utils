local vec = require "vec"

---Методы без префикса `__` изменяют первый операнд, иначе создают новый вектор
---Если размер второго операнда меньше первого, недостающие элементы будут заменены 0 или 1 векторами в зависимости от операции
---@class mat
---@operator add (number[]):mat
---@operator sub (number[]):mat
---@operator mul (number[]):vec
---@operator div (number[]):mat
---@operator unm (number[]):mat
local M = {}

---Создает пустую таблицу с метатаблицей матрицы
---@param ... vec
---@return mat
function M.new(...)
	return setmetatable({...}, M)
end

---Создает пустую матрицу векторов
---@param w integer
---@return mat
function M.newempty(w)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.new()
	end
	return newmat
end

---Создает новую матрицу и заполняет ее нолями
---@param w integer
---@param h integer
---@return mat
function M.newzero(w, h)
	local newmat = setmetatable({}, M)
	for cw = 1, w do
		newmat[cw] = vec.newzero(h)
	end
	return newmat
end

---Создает новую единичную матрицу
---@param w integer
---@param h integer
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

---Изменяет форму вектора в матрицу
---@param v any
---@param shape any
function M.reshape(v, shape)
	local vlen, s1, s2 = #v, shape[1], shape[2]
	assert((s1 * s2) == vlen, "Cannot reshape vec to mat")
	local newmat = setmetatable({}, M)
	for n = 1, s1 do
		newmat[n] = vec.copy(v, n*s2, (n-1)*s2 + 1)
	end
	return newmat
end

---Транспонирование матрицы
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

---Умножение функцией Адамана
---@param mata mat
---@param matb mat
---@return mat mata
function M.hada(mata, matb)
	local w = assert(#mata == #matb)
	for _w = 1, w do
		mata[_w] = vec.mul(mata[_w], matb[_w])
	end
	return mata
end

---Умножение функцией Адамана
---@param mata mat
---@param matb mat
---@return mat newmat
function M.__hada(mata, matb)
	local w = assert(#mata == #matb)
	assert(#mata > 0)
	local newmat = setmetatable({}, M)
	for _w = 1, w do
		newmat[_w] = vec.__mul(mata[_w], matb[_w])
	end
	return newmat
end

---Сумма матриц
---@param mata mat
---@param matb mat
---@return mat
function M.add(mata, matb)
	if type(matb) == "table" and type(matb[1]) == "table" then
		for i = 1, #mata do
			vec.add(mata[i], matb[i])
		end
	else
		for i = 1, #mata do
			vec.add(mata[i], matb)
		end
	end
	return mata
end

---Сумма матриц
---@param mata mat
---@param matb mat|vec|number
---@return mat
function M.__add(mata, matb)
	local newmat = setmetatable({}, M)
	if type(matb) == "table" and type(matb[1]) == "table" then
		for i = 1, #mata do
			newmat[i] = vec.__add(mata[i], matb[i])
		end
	else
		for i = 1, #mata do
			newmat[i] = vec.__add(mata[i], matb)
		end
	end
	return newmat
end

---Разница матриц
---@param mata mat
---@param matb mat|vec|number
---@return mat
function M.sub(mata, matb)
	if type(matb) == "table" and type(matb[1]) == "table" then
		for i = 1, #mata do
			vec.sub(mata[i], matb[i])
		end
	else
		for i = 1, #mata do
			vec.sub(mata[i], matb)
		end
	end
	return mata
end

---Разница матриц
---@param mata mat
---@param matb mat|vec|number
---@return mat
function M.__sub(mata, matb)
	local newmat = setmetatable({}, M)
	if type(matb) == "table" and type(matb[1]) == "table" then
		for i = 1, #mata do
			newmat[i] = vec.__sub(mata[i], matb[i])
		end
	else
		for i = 1, #mata do
			newmat[i] = vec.__sub(mata[i], matb)
		end
	end
	return newmat
end

---Умножение матрицы на матрицу, вектор или число
---@generic V : vec|mat
---@param mata mat
---@param matb V
---@return V
---@overload fun(mata: mat, matb: number): vec
function M.__mul(mata, matb)
	local rows = #mata
	local cols = #mata[1]
	local out
	if type(matb) == "table" and type(matb[1] == "table") then
		out = setmetatable({}, M)
		local matb = M.__transpos(matb)
		for i = 1, rows do
			local v = vec.new()
			for i2 = 1, cols do
				v[i2] = vec.sum(vec.__mul(mata[i], matb[i2]))
			end
			out[i] = v
		end
	else
		out = vec.new()
		for i = 1, rows do
			out[i] = vec.sum(vec.__mul(mata[i], matb))
		end
	end
	return out
end

---Умножение матрицы на матрицу, вектор или число
---@generic V : vec|mat
---@param mata mat если `matb` вектор, будет изменена
---@param matb V если матрица, будет изменена
---@return V
---@overload fun(mata: mat, matb: number): vec
function M.mul(mata, matb)
	local rows = #mata
	local cols = #mata[1]
	local out
	if type(matb) == "table" and type(matb[1] == "table") then
		out = setmetatable({}, M)
		local matb = M.transpos(matb)
		for i = 1, rows do
			local v = vec.new()
			for i2 = 1, cols do
				v[i2] = vec.sum(vec.mul(matb[i2], mata[i]))
			end
			out[i] = v
		end
	else
		out = vec.new()
		for i = 1, rows do
			out[i] = vec.sum(vec.mul(mata[i], matb))
		end
	end
	return out
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

function M.__serialize(mat)
	local ser = require "serialize".ser
	local out = {}
	for i = 1, #mat do
		out[i] = ser(mat[i])
	end
	return "{"..table.concat(out, ",").."}"
end

function M.tostring(mat)
	local out = {}
	for i = 1, #mat do
		out[i] = tostring(mat[i])
	end
	return "[\n\t"..table.concat(out, "\n\t").."\n]"
end

M.__index = M
M.__tostring = M.tostring

M = setmetatable(M, {__call = function(self, ...)
	return setmetatable(table.pack(...), self)
end})

return M
