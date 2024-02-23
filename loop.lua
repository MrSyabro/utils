local obj = require "obj"

local cr, cs = coroutine.resume, coroutine.status
local tp, tu = table.pack, table.unpack

---@class Loop : Object
---@field pool table<thread, boolean>
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.005

function loopclass:step()
    local c = os.clock()
    for thread in pairs(self.pool) do
        local state, errmsg = cr(thread)
        if not state then
            warn(debug.traceback(thread, ("[%s] Callback error: %s"):format(self.name or "Loop", errmsg or "in coroutine")))
            self.pool[thread] = nil
        elseif cs(thread) == "dead" then
            self.pool[thread] = nil
        end
        if (os.clock() - c) > loopclass.time then return end
    end
end

---Регистрирует новую нить в пуле
---@param thread thread
function loopclass:register(thread)
    if type(thread) ~= "thread" then error("Bad thread type", 2) end
    self.pool[thread] = true
end

---Вызывает функцию с аргументами обернув в рутину. Возвращает результат первого вызова resume
---@param func function
---@param ... any
---@return boolean success успешен ли первый вызов resume
---@return any ...
function loopclass:acall(func, ...)
	local newth = coroutine.create(func)
	local out = tp(cr(newth, ...))
	if out[1] then
		if cs(newth) == "suspended" then
			self.pool[newth] = true
		end
		table.remove(out, 1)
		return tu(out)
	else
		return false, debug.traceback(newth, out[2])
	end
end

---Функция аналогична coroutine.wrap, возращает, которая вызовет loop:acall(func)
---@param func function
---@return function wrap
function loopclass:awrap(func)
	return function(...)
		return self:acall(func, ...)
	end
end

---Создает новый пул нитей
---@param data string|table?
---@return Loop
function loopclass:new(data)
    if type(data) == "string" then data = {name = data} end
    local loop = obj.new(loopclass, nil, data) --[[@as Loop]]

    loop.pool = {}

    return loop
end

return loopclass
