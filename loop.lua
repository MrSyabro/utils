local obj = require "obj"

local cr, cs, cy, cc = coroutine.resume, coroutine.status, coroutine.yield, coroutine.close
local tp, tu = table.pack, table.unpack
local osc = os.clock

---@class ThreadData
---@field weight number
---@field paused boolean?
---@field awaits table<thread, boolean>

---@class Loop : Object
---@field pools table<thread, ThreadData>[]
---@field funcindexes table<function, thread>
---@field next_pool number указывает на следующий рабочий пул
---@field pausedpool table<thread, ThreadData>
---@field weights number сумма весов всех задач
---@field thread thread
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.003
loopclass.weights = 0
loopclass.next_pool = 1

---Регистрирует новую нить в пуле
---@param thread thread
---@param weight number?
function loopclass:register(thread, weight)
	if type(thread) ~= "thread" then error("Bad thread type", 2) end
	if not weight then
		local cth = coroutine.running()
		local cthd = self.pools[1][cth] or self.pools[2][cth] or self.pausedpool[cth]
		weight = cthd and cthd.weight or 5
	end
	self.pools[self.next_pool][thread] = {
		weight = weight,
		clock = 0,
		awaits = {},
	}
	self.weights = self.weights + weight
end

---Удаляет рутину из пулов
---@param th thread
function loopclass:remove(th)
	local pools = self.pools
	local thd = pools[1][th] or pools[2][th]
	if thd then
		pools[1][th] = nil
		pools[2][th] = nil
		self.weights = self.weights - thd.weight
		for pth in pairs(thd.awaits) do
			self:run(pth)
		end
		return
	end
	local thd = self.pausedpool[th]
	if thd then
		self.pausedpool[th] = nil
		for pth in pairs(thd.awaits) do
			self:run(pth)
		end
		return
	end
	cc(th)
end

---Вызывает функцию с аргументами обернув в рутину. Возвращает результат первого вызова `coroutine.resume` или сообщяет об ошибке в `warn`
---@param func function
---@param ... any
---@return any ... если до первого пререключения контекста произойдет ошибка, первый результат будет false, второй - ошибка, иначе все, что вернет первый `coroutine.resume`
function loopclass:acall(func, ...)
	if type(func) ~= "function" then error("Bad function type", 2) end
	local newth = coroutine.create(func)
	self:register(newth)
	local out = tp(cr(newth, ...))
	if out[1] then
		if cs(newth) == "dead" then
			self:remove(newth)
		end
		table.remove(out, 1)
		return tu(out)
	else
		self:remove(newth)
		warn(debug.traceback(newth, out[2]))
	end
end

---Функция аналогична coroutine.wrap, возращает функцию, которая вызовет loop:acall(func)
---@param func function
---@return function wrap
function loopclass:awrap(func)
	return function(...)
		return self:acall(func, ...)
	end
end

---Ставит поток на паузу, пока выполняется другой
---@param th thread
function loopclass:await(th)
	local thd = assert(self.pools[1][th] or self.pools[2][th], "Thread not registered or paused")
	local cth = coroutine.running()
	thd.awaits[cth] = true
	self:pause(cth)
	cy()
end

---Отправляет поток пока не будет вызвано `run`
---@param th thread если не указано, использует выполняющийся на данный момент поток
function loopclass:pause(th)
	local pools = self.pools
	local data = pools[1][th] or pools[2][th]
	if data and not data.paused then
		pools[1][th] = nil
		pools[2][th] = nil
		self.pausedpool[th] = data
		data.paused = true
		self.weights = self.weights - data.weight
	elseif not self.pausedpool[th] then
		error("Thread not register")
	end
end

---Возвращает состояние пуаузы потока
---@param th thread
---@return boolean
function loopclass:ispause(th)
	local data = self.pausedpool[th]
	return(data ~= nil)
end

---Закрываает все потоки всех пулов
function loopclass:destroy()
	for th in pairs(self.pools[1]) do cc(th) end
	for th in pairs(self.pools[2]) do cc(th) end
	for th in pairs(self.pausedpool) do cc(th) end
end

---@param self Loop
---@param thread thread
---@param thread_data ThreadData
local function process_thread(self, thread, thread_data)
	local maxclock = self.time / self.weights * thread_data.weight
	local cclock = 0
	repeat
		local c2 = osc()
		local state, errmsg = cr(thread)
		cclock = cclock + (osc() - c2)
		if not state then
			self:remove(thread)
			if errmsg ~= "cannot resume dead coroutine" then
				warn(debug.traceback(thread,
					("[%s] Callback error: %s"):format(self.name or "Loop",
						errmsg or "in coroutine")))
			end
			return
		end
	until thread_data.paused or cclock > maxclock
end

---Перекидывает из отдыхающих в работающие, тут же выполняет поток
---@param th thread
function loopclass:run(th)
	local data = self.pausedpool[th]
	if data then
		self.pausedpool[th] = nil
		self.pools[self.next_pool][th] = data
		data.paused = nil
		self.weights = self.weights + data.weight

		process_thread(self, th, data)
	end
end

---@param self Loop
local function process_loop(self)
	while true do
		if self.weights > 0 then
			self.next_pool = 2
			for thread, thread_data in pairs(self.pools[1]) do
				process_thread(self, thread, thread_data)
			end

			self.next_pool = 1
			for thread, thread_data in pairs(self.pools[2]) do
				process_thread(self, thread, thread_data)
			end
		end
		cy()
	end
end

function loopclass:step()
	local s, e = cr(self.thread, self)
	if s == false then
		warn(debug.traceback(self.thread, e))
		self.thread = coroutine.create(process_loop)
	end
end

---Создает новый пул нитей
---@param data string|table?
---@return Loop
function loopclass:new(data)
	if type(data) == "string" then data = { __name = data } end
	local loop = obj.new(loopclass, nil, data) --[[@as Loop]]

	loop.pools = {{},{}}
	loop.pausedpool = {}
	loop.thread = coroutine.create(process_loop)

	return loop
end

return loopclass

