---@alias vec Vec|number[]
---@alias vec2 vec
---@alias vec3 vec2

---Методы без префикса `__` изменяют первый операнд, иначе создают новый вектор
---Если размер второго операнда меньше первого, недостающие элементы будут заменены 0 или 1 в зависимости от операции
---@class Vec : table
---@operator add (vec):vec
---@operator sub (vec):vec
---@operator mul (vec):vec
---@operator div (vec):vec
---@operator mod (vec):vec
---@operator pow (vec):vec
---@operator unm (vec):vec
---@operator concat (vec):vec
local M = {}

---Создает новый вектор
---@param ... number
---@return vec
function M.new(...)
	return setmetatable({...}, M)
end

---Создает нулевой вектор размера s
---@param s number
---@return vec
function M.newzero(s)
    local newvec = setmetatable({}, M)
    for i = 1, s do
        newvec[i] = 0
    end
    return newvec
end

---Создает единичный вектор размера s
---@param s number
---@return vec
function M.newsingle(s)
    local newvec = setmetatable({}, M)
    for i = 1, s do
        newvec[i] = 1
    end
    return newvec
end

---Преобразует hex строку в массив
---@param hexstring string
function M.fromhex(hexstring)
    local tn = tonumber
    local out = setmetatable({}, M)
    local i = 1
    for hexelement in hexstring:gmatch('%x%x') do
        out[i] = tn(hexelement, 16)
        i = i + 1
    end

    return out
end

---Создает массив заполненый от `start` дo `finish`
---@param start number
---@param finish number
---@param step number?
function M.range(start, finish, step)
    local newvec = setmetatable({}, M)
    step = step or 1
    local nelem = 1
    for i = start, finish, step do
        newvec[nelem] = i
        nelem = nelem + 1
    end
    return newvec
end

---Создает копию вектора
---@param vec vec
---@param i integer? последний элемент для копирования, размер вектора по умолчанию
---@param j integer? первый элемент, с которого начнется копирование, 1 по умолчанию
---@return vec
function M.copy(vec, i, j)
    local newvec = setmetatable({}, M)
    i = i or #vec
    j = j or 1
    local nelem = 1
    for n = j, i do
        newvec[nelem] = vec[n] or 0
        nelem = nelem + 1
    end
    return newvec
end

---Суммирует векторы
---@param veca vec будет изменен
---@param vecb vec|number
function M.add(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        for i = 1, #veca do
            veca[i] = veca[i] + vecb
        end
        return veca
    elseif btype == "table" then
        for i = 1, #veca do
            veca[i] = veca[i] + (vecb[i] or 0)
        end
        return veca
    else
        error("Bat second operand")
    end
end

---Суммирует векторы
---@param veca vec
---@param vecb vec|number
---@return vec
function M.__add(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] + vecb
        end
        return newvec
    elseif btype == "table" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] + (vecb[i] or 0)
        end
        return newvec
    else
        error("Bat second operand")
    end
end

---Вычитает вектор vecb из вектора veca
---@param veca vec будет изменен
---@param vecb vec|number
---@return vec
function M.sub(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        for i = 1, #veca do
            veca[i] = veca[i] - vecb
        end
        return veca
    elseif btype == "table" then
        for i = 1, #veca do
            veca[i] = veca[i] - (vecb[i] or 0)
        end
        return veca
    else
        error("Bat second operand")
    end
end

---Вычитает вектор vecb из вектора veca
---@param veca vec
---@param vecb vec|number
---@return vec
function M.__sub(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] - vecb
        end
        return newvec
    elseif btype == "table" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] - (vecb[i] or 0)
        end
        return newvec
    else
        error("Bat second operand")
    end
end

---Умножает вектор на вектор
---@param veca vec будет изменен
---@param vecb vec|number
---@return vec
function M.mul(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        for i = 1, #veca do
            veca[i] =  veca[i] * vecb
        end
        return veca
    elseif btype == "table" then
        for i = 1, #veca do
            veca[i] =  veca[i] * (vecb[i] or 1)
        end
        return veca
    else
        error("Bat second operand")
    end
end

---Умножает вектор на вектор
---@param veca vec
---@param vecb vec|number
---@return vec
function M.__mul(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] * vecb
        end
        return newvec
    elseif btype == "table" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] * (vecb[i] or 1)
        end
        return newvec
    else
        error("Bat second operand")
    end
end

---Делит вектор на вектор
---@param veca vec будет изменен
---@param vecb vec|number
---@return vec
function M.div(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        for i = 1, #veca do
            veca[i] =  veca[i] / vecb
        end
        return veca
    elseif btype == "table" then
        for i = 1, #veca do
            veca[i] =  veca[i] / (vecb[i] or 1)
        end
        return veca
    else
        error("Bat second operand")
    end
end

---Делит вектор на вектор
---@param veca vec
---@param vecb vec|number
---@return vec
function M.__div(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] / vecb
        end
        return newvec
    elseif btype == "table" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] / (vecb[i] or 1)
        end
        return newvec
    else
        error("Bat second operand")
    end
end

---Вознесение в степень vecb элементов vaca
---@param veca vec будет изменен
---@param vecb vec|number
---@return vec
function M.pow(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        for i = 1, #veca do
            veca[i] =  veca[i] ^ vecb
        end
        return veca
    elseif btype == "table" then
        for i = 1, #veca do
            veca[i] =  veca[i] ^ (vecb[i] or 1)
        end
        return veca
    else
        error("Bat second operand")
    end
end

---Вознесение в степень vecb элементов vaca
---@param veca vec
---@param vecb vec|number
---@return vec
function M.__pow(veca, vecb)
    local btype = type(vecb)
    if btype == "number" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] ^ vecb
        end
        return newvec
    elseif btype == "table" then
        local newvec = setmetatable({}, M)
        for i = 1, #veca do
            newvec[i] = veca[i] ^ (vecb[i] or 1)
        end
        return newvec
    else
        error("Bat second operand")
    end
end

---Одномесный минус элементов vec
---@param vec vec будет изменен
---@return vec
function M.unm(vec)
	for i = 1, #vec do
		vec[i] =  -vec[i]
	end
	return vec
end

---Одномесный минус элементов vec
---@param vec vec
---@return vec
function M.__unm(vec)
	local newvec = setmetatable({}, M)
	for i = 1, #vec do
		newvec[i] = -vec[i]
	end
	return newvec
end

---Поэлементно сравнивает 2 вектора
---@param veca vec
---@param vecb vec|number
---@return boolean
function M.eq(veca, vecb)
    local btype = type(vecb)
    if btype == "table" then
        local lena = #veca
        if lena ~= #vecb then return false end
        for i = 1, #veca do
            if veca[i] ~= vecb[i] then
                return false
            end
        end
        return true
    elseif btype == "number" then
        local lena = #veca
        for i = 1, #veca do
            if veca[i] ~= vecb then
                return false
            end
        end
        return true
    else
        error("Bad second operand")
    end
end

local ms, mmax, mmin  = math.sqrt, math.max, math.min
--[[ Спецефичные векторные операции ]]--

local tohex_fmt = "%02X"

---Преобразует массив цифр в HEX строку (начинается на `#`)
---@param vec vec
function M.tohex(vec)
    local ti, sf = table.insert, string.format
    local mf = math.floor
    local out = {'#'}
    for _, element in ipairs(vec) do
        ti(out, sf(tohex_fmt, mmin(mmax(mf(element), 0), 255)))
    end

    return table.concat(out)
end

---Геометрическая длина вектора
---@param vec vec
---@return number
function M.len(vec)
    return ms(M.lensqr(vec))
end

---Квадрат длинны вектора
---@param vec vec
---@return number
function M.lensqr(vec)
	return M.sum(M.__pow(vec, 2))
end

---Сумма всех элементов вектора
---@param vec vec
---@return number
function M.sum(vec)
    local sum = 0
    for i = 1, #vec do
        sum = sum + vec[i]
    end
    return sum
end

---Нормализует вектор до единичного
---@param vec vec
---@return vec
---@return number len
function M.normalize(vec)
    local len = M.len(vec)
    return M.div(vec, len), len
end

---Нормализует вектор до единичного
---@param vec vec будет изменен
---@return vec
---@return number len
function M.__normalize(vec)
    local len = M.len(vec)
    return M.__div(vec, len), len
end

---Выводит соотношение векторов
---@param veca vec
---@param vecb vec
---@return number
function M.dot(veca, vecb)
    local out = 0
    for i = 1, #veca do
        out = out + veca[i] * (vecb[i] or 0)
    end

    return out
end

---Возвращает вектор между veca vecb в соотношении param
---
---Изменяются и veca и vecb
---@param veca vec
---@param vecb vec
---@param param number from 0 to 1
---@return vec
function M.lerp(veca, vecb, param)
    local fromToVec = M.sub(vecb, veca)
    return M.add(veca, M.mul(fromToVec, param))
end

---Возвращает вектор между veca vecb в соотношении param
---@param veca vec будет изменен
---@param vecb vec будет изменен
---@param param number from 0 to 1
---@return vec
function M.__lerp(veca, vecb, param)
    local fromToVec = M.__sub(vecb, veca)
    return M.__add(veca, M.mul(fromToVec, param))
end


--[[ Метатабличные операции ]]--
local tc, sf = table.concat, string.format

---Выводит вектор как строку
---@param vec vec
---@return string
function M.tostring(vec)
	local out = {}
	for i = 1, #vec do
		out[i] = tostring(vec[i])
	end
	return("[" .. tc(out, ",") .. "]")
end

---Выводит вектор как строку
---@param vec vec
---@return string
function M.__serialize(vec)
	local out = "{"
	for i = 1, #vec do
		out = out .. sf("%q,", vec[i])
	end
	return(out .. "}")
end

M.__index   = M
M.__tostring = M.tostring
M.__name = "Vec"

return M
