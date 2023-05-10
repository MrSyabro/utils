---@param o any
---@param readable number? #количество вложенных таблиц, которые стоит форматировать
---@return
local function fser(o, r, prefix, ts)
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
				table.insert(tout, "[" .. lk .. "] = " .. lo .. ", " .. sep)
			end
		end
		out = "{ " .. sep .. ((r > 0) and p or "") .. table.concat(tout, (r > 0) and p or nil) .. ((r > 0) and p:sub(1, -2) or "") .. "}"
	elseif t == "function"
		or t == "thread"
		or t == "userdata"
	then
		out = nil
	else
		out = string.format("%q", o)
	end
	return out
end

---@param o any
---@return string?
local function ser(o, ts)
	local ts = ts or {}
	local t = type(o)
	local out
	if t == "table" then
		if ts[o] then
			return [=["loop table"]=]
		end
		ts[o] = true
		local tout = { "{" }
		for i, k in pairs(o) do
			local lo = ser(k, ts)
			if lo then
				table.insert(tout, "[")
				table.insert(tout, ser(i, ts))
				table.insert(tout, "]=")
				table.insert(tout, lo .. ",")
			end
		end
		table.insert(tout, "}")
		out = table.concat(tout)
	elseif t == "function"
		or t == "thread"
		or t == "userdata"
	then
		out = nil
	else
		out = string.format("%q", o)
	end
	return out
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
