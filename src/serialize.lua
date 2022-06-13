local M = {}

local function ser (o, readable, prefix)
	local p = prefix or ""
	local r = readable or false
	local out = {}
	if type(o) == "table" then
		table.insert(out, "{"..((r and "\n") or ""))
		local c = 0
		for i, k in pairs(o) do
			local lo = ser(k, r, r and (p.."\t"))
			if lo then
				table.insert(out, (p.."[%q]="):format(i))
				table.insert(out, lo..","..((r and "\n") or ""))
			end
		end
		table.insert(out, p.."}")
	else
		out[1] = string.format("%q", o)
	end

	return table.concat(out)
end

---Serialize file
---@param filepath string
---@param data any
---@param readable boolean
---@return nil
---@return string?
function M.ser_file(filepath, data, readable)
	local file, err = io.open(filepath, "w")
	if not file then return nil, err end
	file:write(ser(data, readable))
	file:close()
end

---Serialize to bin format
---@param obj any
---@return string
function M.to_bin(obj)
	local ser_obj = ser(obj)
	return string.dump(load("return "..ser_obj), true)
end

M.ser = ser

return M
