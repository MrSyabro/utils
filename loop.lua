local obj = require "obj"
local rst = require "relocsafetab"

local cr, cs, cy, cc = coroutine.resume, coroutine.status, coroutine.yield, coroutine.close
local tp, tu = table.pack, table.unpack
local osc = os.clock

---@class threaddata
---@field weight number
---@field paused boolean?
---@field args table
---@field returns table
---@field awaits table<thread, boolean>

---@class Loop : Object
---@field pool table<thread, threaddata>
---@field funcindexes table<function, thread>
---@field pausedpool table<thread, threaddata>
---@field removed table<thread, threaddata> слабая таблица удаленных, но не уничтоженных рутин
---@field weights number сумма весов всех задач
---@field thread thread
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.003
loopclass.weights = 0

---Регистрирует новую нить в пуле
---@param thread thread
---@param weight number?
function loopclass:register(thread, weight)
	if type(thread) ~= "thread" then error("Bad thread type", 2) end
	if not weight then
		local cth = coroutine.running()
		local cthd = self.pool[cth] or self.pool[cth] or self.pausedpool[cth]
		weight = cthd and cthd.weight or 5
	end
	self.pool[thread] = {
		weight = weight,
		clock = 0,
		awaits = {},
		args = {},
		returns = {},
	}
	self.weights = self.weights + weight
end

---Устанавливает вес уже добавленой задачи
---@param th thread
---@param weight integer
function loopclass:setwight(th, weight)
	local data = self:getdata(th)
	if data then
		self.weights = self.weights - data.weight + weight
		data.weight = weight
	end
end

---Удаляет рутину из пулов
---@param th thread
function loopclass:remove(th)
	local pool = self.pool
	local thd = pool[th]
	if thd then
		pool[th] = nil
		self.removed[th] = thd
		self.weights = self.weights - thd.weight
		for pth in pairs(thd.awaits) do
			self:run(pth, tu(thd.returns, 2))
		end
		return
	end
	local thd = self.pausedpool[th]
	if thd then
		self.pausedpool[th] = nil
		self.removed[th] = thd
		for pth in pairs(thd.awaits) do
			self:run(pth, tu(thd.returns, 2))
		end
		return
	end
	cc(th)
end

---Вызывает функцию с аргументами обернув в рутину. Возвращает результат первого вызова `coroutine.resume` или сообщяет об ошибке в `warn`
---@param func function
---@param ... any
---@return thread
function loopclass:acall(func, ...)
	if type(func) ~= "function" then error("Bad function type", 2) end
	local newth = coroutine.create(func)
	self:register(newth)
	local thdata = self.pool[newth]
	thdata.args = tp(...)
	return newth
end

---Ставит поток на паузу, пока выполняется другой
---@param th thread
---@param tth thread?
function loopclass:await(th, tth)
	local thd = self.pool[th] or self.pausedpool[th]
	if thd then
		local cth = tth or coroutine.running()
		thd.awaits[cth] = true
		self:pause(cth)
		return cy()
	else
		local thd = assert(self.removed[th], "Thread not found")
		return tu(thd.returns, 2)
	end
end

---Отправляет поток пока не будет вызвано `run`
---@param th thread если не указано, использует выполняющийся на данный момент поток
function loopclass:pause(th)
	local pool = self.pool
	local data = pool[th]
	if data and not data.paused then
		pool[th] = nil
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
	for th in pairs(self.pool) do cc(th) end
	for th in pairs(self.pausedpool) do cc(th) end
end

---@param th thread
---@return threaddata
function loopclass:getdata(th)
	return self.removed[th] or self.pausedpool[th] or self.pool[th]
end

---@param self Loop
---@param thread thread
---@param thread_data threaddata
local function process_thread(self, thread, thread_data)
	local maxclock = self.time / self.weights * thread_data.weight
	local cclock = 0
	repeat
		local c2 = osc()
		local ret = tp(cr(thread, tu(thread_data.args)))
		thread_data.returns = ret
		if not ret[1] then
			self:remove(thread)
			if ret[2] ~= "cannot resume dead coroutine" then
				warn(debug.traceback(thread,
					("[%s] Callback error: %s"):format(self.name or "Loop",
						ret[2] or "in coroutine")))
			end
			return
		elseif cs(thread) == "dead" then
			self:remove(thread)
			return
		end
		if #thread_data.args > 0 then thread_data.args = {} end
		cclock = cclock + (osc() - c2)
	until thread_data.paused or cclock > maxclock
end

---Перекидывает из отдыхающих в работающие, тут же выполняет поток при этом записав аргументы, если их > 0
---@param th thread
function loopclass:run(th, ...)
	local data = self.pausedpool[th]
	if data then
		self.pausedpool[th] = nil
		self.pool[th] = data
		data.paused = nil
		local args = tp(...)
		if args.n > 0 then
			data.args = args
		end
		self.weights = self.weights + data.weight

		process_thread(self, th, data)
	end
end

---@param self Loop
local function process_loop(self)
	while true do
		if self.weights > 0 then
			for thread, thread_data in pairs(self.pool) do
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

---Запускает луп как главный в бесконечном цикле. Также создает метод остановки `loopclass:exit`, останавливающий цикл.
function loopclass:main()
	local work = true
	function self:exit()
		work = false
	end
	while work do
		self:step()
	end
end

---Создает новый пул нитей
---@param data string|table?
---@return Loop
function loopclass:new(data)
	if type(data) == "string" then data = { __name = data } end
	local loop = obj.new(loopclass, nil, data) --[[@as Loop]]

	loop.pool = rst()
	loop.pausedpool = {}
	loop.removed = setmetatable({}, {__mode = "k"})
	loop.thread = coroutine.create(process_loop)

	return loop
end

return loopclass

