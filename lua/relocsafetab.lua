local mt = {
	__index = function(pool, key)
		return pool[true][key] or pool[false][key]
	end,
	__newindex = function(pool, key, data)
		local next = pool.next
		local p = pool[not next]
		if p[key] then
			p[key] = data
		else
			pool[next][key] = data
		end
	end,
	__pairs = function(pool)
		local cur = true
		pool.next = false
		return function(pool, i)
			if i and not pool[i] then i = nil end
			local nkey, ndata = next(pool[cur], i)
			if nkey then
				return nkey, ndata
			elseif cur == false then
				return nil
			else
				pool.next = true
				cur = false
				return next(pool[cur])
			end
		end, pool
	end
}

---Создает таблицу, которая позволяет добавлять элементы вовремя `pairs`
---@return table<any, any>
local function relocatesafetytable()
	return setmetatable({
		[true] = {},
		[false] = {},
		next = false
	}, mt)
end

return relocatesafetytable
