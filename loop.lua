local obj = require "obj"

local cr, cs, cy = coroutine.resume, coroutine.status, coroutine.yield
local tp, tu = table.pack, table.unpack
local osc = os.clock

---@class ThreadData
---@field weight number
---@field clock number
---@field paused boolean?

---@class Loop : Object
---@field pool table<thread, ThreadData>
---@field pausedpool table<thread, ThreadData>
---@field weights number сумма весов всех задач
---@field current thread
---@field	thread thread
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.003
loopclass.weights = 0

function loopclass:step()
	local s, e = cr(self.thread, self)
	if s == false then
		log:error(e)
	end
end

---Регистрирует новую нить в пуле
---@param thread thread
---@param weight number
function loopclass:register(thread, weight)
	if type(thread) ~= "thread" then error("Bad thread type", 2) end
 	weight = weight or 5
	self.pool[thread] = {
		weight = weight,
		clock = 0,
	}
	self.weights = self.weights + weight
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
				weight = 5,
				clock = 0,
			}
			self.weights = self.weights + 5
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
		data.paused = true
		self.weights = self.weights - data.weight
	end
end

---Перекидывает из отдыхающих в работающие
---@param th thread
function loopclass:run(th)
	local data = self.pausedpool[th]
	if data then
		self.pausedpool[th] = nil
		self.pool[th] = data
		data.paused = nil
		self.weights = self.weights + data.weight
	end
end

local function process_thread(self, thread, thread_data)
	local weight = thread_data.weight
	while not thread_data.paused
		and thread_data.clock < (self.time / self.weights * weight)
	do
		local c2 = osc()
		local state, errmsg = cr(thread)
		if not state then
			warn(debug.traceback(thread,
				("[%s] Callback error: %s"):format(self.name or "Loop",
					errmsg or "in coroutine")))
			self.pool[thread] = nil
			self.weights = self.weights - weight
			return
		elseif cs(thread) == "dead" then
			self.pool[thread] = nil
			self.weights = self.weights - weight
			return
		end
		thread_data.clock = thread_data.clock + (osc() - c2)
	end
	thread_data.clock = 0
end

local function process_loop(self)
	while true do
		if self.weights > 0 then
			for thread, thread_data in pairs(self.pool) do
				self.current = thread
				process_thread(self, thread, thread_data)
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
	loop.pausedpool = {}
	loop.thread = coroutine.create(process_loop)

	return loop
end

return loopclass

