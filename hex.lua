local M = {}

local tohex_fmt = "%02X"

---Преобразует массив цифр в HEX строку (начинается на `#`)
---@param inputarray integer[]
function M.tohex(inputarray)
    local ti, sf = table.insert, string.format
    local mf, mmax, mmin = math.floor, math.max, math.min
    local out = {'#'}
    for _, element in ipairs(inputarray) do
        ti(out, sf(tohex_fmt, mmin(mmax(mf(element), 0), 255)))
    end

    return table.concat(out)
end

---Преобразует hex строку в массив
---@param hexstring string
function M.fromhex(hexstring)
    local tn, ti = tonumber, table.insert
    local out = {}
    hexstring = hexstring:gsub('#', '')
    for hexelement in hexstring:gmatch('%x%x') do
        ti(out, tonumber(hexelement, 16))
    end

    return out
end

return M