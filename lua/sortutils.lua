---@alias comparator<V> fun(v1: V, v2: V):boolean?

---@type comparator<any>
local function defcomp(v1, v2)
	if v1 == v2 then return end
	return v1 < v2
end

---Использует комбинацию сортированного поиска и вставки
---
---__Учти, что 2 одинаковых элемента ломают сортированность списка__
---
---в случае, если совпавший по `comp` элемент уже есть, вернет его индекс и не будет добавлять копию
---@generic V
---@param list `V`[]
---@param value V
---@param comp? fun(v1: V, v2: V):boolean?
---@return integer
function table.sortinsert(list, value, comp)
    local curn, n = table.sortsearch(list, value, comp)
    if not curn then 
		table.insert(list, n, value)
	end
	return curn or n
end

---Быстрый посик по отсортированному массиву
---
---Если не найдено точное совпадение, возвращает вторым значением номер элмента для
---которого `comp(list[n-1], value)` вернет `true`, а `comp(list[n], value)` - `false`.
---Т.е. туда можно вставить `value`
---@generic V
---@param list `V`[]
---@param value V
---@param comp? comparator<V>
---@param i integer?
---@param j integer?
---@return integer?
---@return V|integer
local function sortsearch(list, value, comp, i, j)
	comp = comp or defcomp
	i = i or #list
	j = j or 1
	if (i - j) < 0 then return nil, i+1 end

	local mid = j + (i - j) // 2
	local el = list[mid]
	local eq = comp(el, value)
	if eq == nil then
		return mid, el
	elseif eq then
		return sortsearch(list, value, comp, i, mid + 1)
	else
		return sortsearch(list, value, comp, mid - 1, j)
	end
end
table.sortsearch = sortsearch
