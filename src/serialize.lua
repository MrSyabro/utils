---
---@param o any
---@param readable boolean?
---@return string?
local function ser(o, readable, prefix, ts)
	local ts = ts or {}
	local p = prefix or ""
	local r = readable or false
	local t = type(o)
	local out
	if t == "table" then
		if ts[o] then
			return [=["loop table"]=]
		end
		ts[o] = true
		local sep = ((r and "\n") or "") .. p
		local tout = { "{", sep }
		local c = 0
		for i, k in pairs(o) do
			local lo = ser(k, r, r and (p .. "\t"), ts)
			if lo then
				if type(i) == "string" then
					table.insert(tout, string.format("[%q]=", i))
				else
					table.insert(tout, "[" .. tostring(i) .. "]=")
				end

				table.insert(tout, string.format("%s,%s",
					lo,
					sep
				))
			end
		end
		table.insert(tout, "}")
		out = table.concat(tout)
	elseif t == "number"
		or t == "boolean"
	then
		out = tostring(o)
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

local M = setmetatable({}, { __call = function(self, ...) return ser(...) end })

---Serialize file
---@param filepath string
---@param data any
---@param readable boolean?
---@return boolean success
---@return string? error
function M.file(filepath, data, readable)
	local file, err = io.open(filepath, "w")
	if not file then return false, err end
	file:write(ser(data, readable))
	file:close()
	return true
end

M.serialize = ser

return M
