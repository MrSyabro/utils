local M = {}

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