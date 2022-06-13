local M = {}

local function ser (o, readable, prefix)
	local p = prefix or ""
	local r = readable or false
	local out
	if type(o) == "table" then
	    local sep = ((r and "\n") or "")..p
	    local tout = {"{", sep}
		local c = 0
		for i, k in pairs(o) do
			local lo = ser(k, r, r and (p.."\t"))
			if lo then
				table.insert(tout, string.format("[%q]=%s,%s",
				    i,
				    lo,
				    sep
				))
			end
		end
		table.insert(tout, "}")
		out = table.concat(tout)
	else
		out = string.format("%q", o)
	end
	return out
end

---Serialize file
---@param filepath string
---@param data any
---@param readable boolean
---@return nil
---@return string?
function M.file(filepath, data, readable)
	local file, err = io.open(filepath, "w")
	if not file then return nil, err end
	file:write(ser(data, readable))
	file:close()
end

---Serialize to bin format
---@param obj any
---@return string
function M.bin(obj)
	local ser_obj = ser(obj)
	return string.dump(load("return "..ser_obj), true)
end

return setmetatable(M, {__call = function (self, ...) return ser(...) end})
