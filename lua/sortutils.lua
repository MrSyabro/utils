local function defcomp(v1, v2)
	if v1 == v2 then return end
	return v1 < v2
end

---Вставляет `value` на место `n+1`, где `comp(list[n], value)` вернет `true`
---
---По умолчанию `comp => list[n] < value`
---@generic V
---@param list `V`[]
---@param value V
---@param comp? fun(v1: V, v2: V):boolean?
---@return integer
function table.sortinsert(list, value, comp)
	comp = comp or defcomp
	for i = #list, 1, -1 do
		local ivalue = rawget(list, i)
		if comp(ivalue, value) then
			list[i+1] = value
			return i+1
		else
			list[i+1] = ivalue
			list[i] = nil
		end
	end
	list[1] = value
	return 1
end

---Быстрый посик по отсортированному массиву
---@generic V
---@param list `V`[]
---@param value V
---@param comp? fun(v1: V, v2: V):boolean?
---@param i integer?
---@param j integer?
---@return integer?
---@return V?
function table.sortsearch(list, value, comp, i, j)
	comp = comp or defcomp
	i = i or #list
	j = j or 1
	if (i - j) < 0 then return end

	local mid = j + (i - j) // 2
	local el = rawget(list, mid)
	local eq = comp(el, value)
	if eq == nil then
		return mid, el
	elseif eq then
		return table.sortsearch(list, value, comp, i, mid + 1)
	else
		return table.sortsearch(list, value, comp, mid - 1, j)
	end
end
