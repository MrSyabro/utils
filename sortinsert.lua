local function defcomp(v1, v2)
	return v1 < v2
end

---Вставляет `value` на место `n+1`, где `comp(list[n], value)` вернет `true`
---
---По умолчанию `comp => list[n] < value`
---@generic V
---@param list `V`[]
---@param value V
---@param comp? fun(v1: V, v2: V):boolean
function table.sortinsert(list, value, comp)
	comp = comp or defcomp
	for i = #list, 1, -1 do
		local ivalue = list[i]
		if comp(ivalue, value) then
			list[i+1] = value
			return
		else
			list[i+1] = ivalue
			list[i] = nil
		end
	end
	list[1] = value
end
