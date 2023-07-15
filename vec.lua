---Если размер второго операнда меньше первого, недостающие элементы будут заменены 0 или 1 в зависимости от операции
---@class vec : number[]
---@operator add (number[]):vec
---@operator sub (number[]):vec
---@operator mul (number[]):vec
---@operator div (number[]):vec
---@operator mod (number[]):vec
---@operator pow (number[]):vec
---@operator unm (number[]):vec
---@operator idiv (number[]):vec
---@operator band (number[]):vec
---@operator bor (number[]):vec
---@operator bxor (number[]):vec
---@operator bnot (number[]):vec
---@operator shl (number[]):vec
---@operator shr (number[]):vec
---@operator concat (number[]):vec
local M = {}

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

---Создает копию вектора
---@param vec number[]
---@return vec
function M.copy(vec)
    local newvec = setmetatable({}, M)
    for i = 1, #vec do
        newvec[i] = vec[i]
    end
    return newvec
end

---Суммирует векторы
---@param veca any
---@param vecb any
---@return vec
function M.add(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] + (vecb[i] or 0))
    end

    return newvec
end

---Суммирует вектор и число
---@param vec number[]
---@param n number
---@return vec
function M.addnum(vec, n)
    local newvec = setmetatable({}, M)
    for _, value in ipairs(vec) do
        table.insert(newvec, value + n)
    end

    return newvec
end

---Вычитает вектор vecb из вектора veca
---@param veca number[]
---@param vecb number[]
---@return vec
function M.sub(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] - (vecb[i] or 0))
    end

    return newvec
end

---Вычитает число из вектора
---@param vec number[]
---@param n number
---@return vec
function M.subnum(vec, n)
    local newvec = setmetatable({}, M)
    for _, value in ipairs(vec) do
        table.insert(newvec, value - n)
    end

    return newvec
end

---Умножает вектор на вектор
---@param veca number[]
---@param vecb number[]
---@return vec
function M.mul(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] * (vecb[i] or 1))
    end

    return newvec
end

---Умножает вектор на число
---@param vec number[]
---@param n number
---@return vec
function M.mulnum(vec, n)
    local newvec = setmetatable({}, M)
    for _, value in ipairs(vec) do
        table.insert(newvec, value * n)
    end

    return newvec
end

---Делит вектор на вектор
---@param veca number[]
---@param vecb number[]
---@return vec
function M.div(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] / (vecb[i] or 1))
    end

    return newvec
end

---Делит вектор на число
---@param vec number[]
---@param n number
---@return vec
function M.divnum(vec, n)
    local newvec = setmetatable({}, M)
    for _, value in ipairs(vec) do
        table.insert(newvec, value / n)
    end

    return newvec
end

---Остаток от деления элементов veca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.mod(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] % (vecb[i] or 1))
    end

    return newvec
end

---Остаток от деления элементов veca на n
---@param vec number[]
---@param n number
---@return vec
function M.modnum(vec, n)
    local newvec = setmetatable({}, M)
    for _, value in ipairs(vec) do
        table.insert(newvec, value % n)
    end

    return newvec
end

---Вознесение в степень vecb элементов vaca
---@param veca number[]
---@param vecb number[]
---@return vec
function M.pow(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] ^ (vecb[i] or 1))
    end

    return newvec
end

---Вознесение в степень элементов вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.pownum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value ^ n)
	end

	return newvec
end

---Одномесный минус элементов vec
---@param vec number[]
---@return vec
function M.unm(vec)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, -value)
	end

	return newvec
end

---Целочисленное деление элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.idiv(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] // (vecb[i] or 1))
    end

    return newvec
end

---Целочисленное деление вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.idivnum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value // n)
	end

	return newvec
end

---битовое И элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.band(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] & (vecb[i] or 1))
    end

    return newvec
end

---битовое И вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.bandnum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value & n)
	end

	return newvec
end

---битовое ИЛИ элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.bor(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] | (vecb[i] or 1))
    end

    return newvec
end

---битовое ИЛИ вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.bornum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value | n)
	end

	return newvec
end

---битовое ИЛИ-НЕ элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.bxor(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] ~ (vecb[i] or 1))
    end

    return newvec
end

---битовое ИЛИ-НЕ вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.bxornum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value ~ n)
	end

	return newvec
end

---битовое одноместное НЕ элементов vac
---@param vec number[]
---@return vec
function M.bnot(vec)
	local newvec = setmetatable({}, M)
    for i = 1, #vec do
        table.insert(newvec, ~vec[i])
    end

    return newvec
end

---битовый сдвиг влево элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.shl(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] << (vecb[i] or 1))
    end

    return newvec
end

---битовый сдвиг влево вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.shlnum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value << n)
	end

	return newvec
end

---битовый сдвиг вправо элементов vaca на vecb
---@param veca number[]
---@param vecb number[]
---@return vec
function M.shr(veca, vecb)
	local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, veca[i] ~ (vecb[i] or 1))
    end

    return newvec
end

---битовый сдвиг вправо вектора на число
---@param vec number[]
---@param n number
---@return vec
function M.shrnum(vec, n)
	local newvec = setmetatable({}, M)
	for _, value in ipairs(vec) do
		table.insert(newvec, value ~ n)
	end

	return newvec
end

---Поэлементно сравнивает 2 вектора
---@param veca number[]
---@param vecb number[]
---@return boolean
function M.eq(veca, vecb)
	for i = 1, #veca do
		if veca[i] ~= vecb[i] then
			return false
		end
	end
	return true
end

---Поэлементно сравнивает 2 вектора
---@param vec number[]
---@param n number
---@return boolean
function M.eqnum(vec, n)
	for i = 1, #vec do
		if vec[i] ~= n then
			return false
		end
	end
	return true
end

---Ставить vecb в конец veca
---@param veca number[]
---@param vecb number[]
---@return vec
function M.concat(veca, vecb)
	local newvec = setmetatable({}, M)
	for i = 1, #veca do
		table.insert(newvec, veca[i])
	end
	for i = 1, #vecb do
		table.insert(newvec, vecb[i])
	end

	return newvec
end


--[[ Спецефичные векторные операции ]]--

---Геометрическая длина вектора
---@param vec number[]
---@return number
function M.len(vec)
    local sum = M.sum(M.pownum(vec, 2))
    return math.sqrt(sum)
end

---Сумма всех элементов вектора
---@param vec number[]
---@return number
function M.sum(vec)
    local sum = 0
    for i = 1, #vec do
        sum = sum + vec[i]
    end
    return sum
end

---Нормализует вектор до единичного
---@param vec number[]
---@return vec
---@return number len
function M.normalize(vec)
    local len = M.len(vec)
    return M.divnum(vec, len), len
end

---Выводит средний вектор
---@param veca number[]
---@param vecb number[]
---@return vec
function M.mean(veca, vecb)
    local newvec = setmetatable({}, M)
    for i = 1, #veca do
        table.insert(newvec, (veca[i] + (vecb[i] or 0)) / 2)
    end

    return newvec
end

---Выводит соотношение векторов
---@param veca number[]
---@param vecb number[]
---@return number
function M.dot(veca, vecb)
    local out = 0
    for i = 1, #veca do
        out = out + veca[i] * (vecb[i] or 0)
    end

    return out
end

-- возвращает вектор между veca vecb в соотношении param
---@param veca number[]
---@param vecb number[]
---@param param number --from 0 to 1
function M.lerp(veca, vecb, param)
    param = math.clamp(param, 0, 1)
    local fromToVec = M.sub(vecb, veca)
    return M.add(veca, M.mulnum(fromToVec, param))
end


--[[ Метатабличные операции ]]--

---Выводит вектор как строку
---@param vec any
---@return string
function M.tostring(vec)
	local out = {}
	for i = 1, #vec do
		table.insert(out, string.format("%g", vec[i]))
	end
	return("{" .. table.concat(out, ",") .. "}")
end

M.__add		= M.add
M.__sub		= M.sub
M.__mul		= M.mul
M.__div		= M.div
M.__pow		= M.pow
M.__mod		= M.mod
M.__unm		= M.unm
M.__idiv	= M.idiv
M.__band	= M.band
M.__bor		= M.bor
M.__bxor	= M.bxor
M.__bnot	= M.bnot
M.__shl		= M.shl
M.__shr		= M.shr
M.__eq		= M.eq
M.__concat= M.concat

M.__tostring = M.tostring

M.__name = "Vec"

return setmetatable(M, {
    __call = function(self, ...)
	    return setmetatable({...}, self)
    end
})
