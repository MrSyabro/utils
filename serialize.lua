local sf = string.format
local ti, tc = table.insert, table.concat
local dg = debug.getmetatable

local strfmt = "%q"
local str_mt = dg(strfmt) or {}
str_mt.__serialize = function(o) return sf(strfmt, o) end
debug.setmetatable(strfmt, str_mt)

local num_mt = dg(10) or {}
num_mt.__serialize = tostring
debug.setmetatable(10, num_mt)

local bool_mt = dg(true) or {}
bool_mt.__serialize = function(v) return v and "true" or "false" end
debug.setmetatable(true, bool_mt)

---@param o any
---@param r number #количество вложенных таблиц, которые стоит форматировать
---@param prefix string? #используется форматирования строк
---@param ts table? #таблица ссылок на таблицы в данных для предотвращения цикличностей
---@return string
local function fser(o, r, prefix, ts)
	local omt = dg(o)
	if omt and omt.__serialize then
		return omt.__serialize(o)
	end
	local ts = ts or {}
	local p = prefix or ""
	local t = type(o)
	local out
	if t == "table" then
		if ts[o] then
			return '"loop table"'
		end
		ts[o] = true
		local sep = (((r > 0) and "\n") or "")
		local tout = {}
		for i, k in pairs(o) do
			local lo = fser(k, r -1, (r > 0) and (p .. "\t"), ts)
			local lk = fser(i, r -1, (r > 0) and (p .. "\t"), ts)
			if lk and lo then
				ti(tout, "[" .. lk .. "] = " .. lo .. ", " .. sep)
			end
		end
		out = "{ " .. sep .. ((r > 0) and p or "") .. tc(tout, (r > 0) and p or nil) .. ((r > 0) and p:sub(1, -2) or "") .. "}"
	end
	return out
end

---@param o any
---@return string?
local function ser(o, ts)
	local omt = dg(o)
	if omt and omt.__serialize then
		return omt.__serialize(o)
	end
	local ts = ts or {}
	local t = type(o)
	local out
	if t == "table" then
		if ts[o] then
			return '"loop table"'
		end
		ts[o] = true
		local tout = {}
		for i, k in pairs(o) do
			local lo = ser(k, ts)
			if lo then
				ti(tout, '[' .. ser(i, ts) .. "]=" .. lo)
			end
		end
		return '{' .. tc(tout, ',') .. "}"
	end
end

local M = setmetatable({}, {__call = function(self, ...)
	self.serialize(...)
end})

---Serialize to file
---@param filepath string
---@param data any
---@param readable boolean?
---@return boolean success
---@return string? error
function M.file(filepath, data, readable)
	local file, err = io.open(filepath, "w")
	if not file then return false, err end
	file:write(M.serialize(data, readable))
	file:close()
	return true
end

---Serialize to string
---@param o any
---@param readable boolean|number|nil #число вложенных таблиц для форматирования или все
function M.serialize(o, readable)
	if readable then
		if type(readable) == "boolean" then readable = math.maxinteger end
		return fser(o, readable)
	else
		return ser(o)
	end
end

M.ser = ser
M.fser = fser

return M
