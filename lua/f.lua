local function subber(str)
	local code = "return " .. str:match("{(.-)}")
	local func = assert(load(code, "F", "t", _ENV))
	return tostring(func())
end

---Возвращает строку, в котороый все вхождения `{code}` заменяются на результат выполнения кода `code`
---@param str string
---@return string
---@return number count колличество замененных вхождений
local function F(str)
	return str:gsub("%b{}", subber)
end

return F
