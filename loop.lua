local obj = require "obj"

local cr, cs, cy = coroutine.resume, coroutine.status, coroutine.yield
local tp, tu = table.pack, table.unpack

---@class ThreadData
---@field weight number
---@field curweight number

---@class Loop : Object
---@field pool table<thread, ThreadData>
---@field pausedpool table<thread, ThreadData>
---@field	thread thread
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.005

function loopclass:step()
	assert(cr(self.thread, self))
end

---Регистрирует новую нить в пуле
---@param thread thread
---@param weight number
function loopclass:register(thread, weight)
	if type(thread) ~= "thread" then error("Bad thread type", 2) end
	self.pool[thread] = {
		weight = weight or 0,
		curweight = weight or 0,
	}
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
			self.pool[newth] = {
				weight = 0,
				curweight = 0,
			}
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

---Перекидывает из работающих в отдыхающие
---@param th thread
function loopclass:pause(th)
	local data = self.pool[th]
	if data then
		self.pool[th] = nil
		self.pausedpool[th] = data
	end
end

---Перекидывает из отдыхающих в работающие
---@param th thread
function loopclass:run(th)
	local data = self.pausedpool[th]
	if data then
		self.pausedpool[th] = nil
		self.pool[th] = data
	end
end

local function process_loop(self)
	while true do
		local c = os.clock()
		local time = self.time
		for thread, thread_data in pairs(self.pool) do
			local curw = thread_data.curweight
			if curw > 0 then
				thread_data.curweight = curw - 1
			else
				local state, errmsg = cr(thread)
				if not state then
					warn(debug.traceback(thread,
						("[%s] Callback error: %s"):format(self.name or "Loop",
							errmsg or "in coroutine")))
					self.pool[thread] = nil
				elseif cs(thread) == "dead" then
					self.pool[thread] = nil
				end
				thread_data.curweight = thread_data.weight
			end
			if (os.clock() - c) > time then
				cy()
				c = os.clock()
			end
		end
		cy()
	end
end

---Создает новый пул нитей
---@param data string|table?
---@return Loop
function loopclass:new(data)
	if type(data) == "string" then data = { name = data } end
	local loop = obj.new(loopclass, nil, data) --[[@as Loop]]

	loop.pool = {}
	loop.thread = coroutine.create(process_loop)

	return loop
end

return loopclass

