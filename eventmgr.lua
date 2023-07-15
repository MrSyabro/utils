local obj = require "obj"

---@class Event : Object
---@operator call(...):nil #Рассылает событие по списку рассылки
---@field n number #кол-во функций менеджера
---@field name string #имя менеджера для дебага
---@field protected callback_fns table<function, boolean> #список функций колбеков
---@field protected callback_ths table<thread, boolean> #список рутин колбеков
---Менеджер событий для реализации подписки и рассылки на несколько функций
local eventmgr_class = obj:new "Event"
eventmgr_class.name = "Test"
eventmgr_class.enabled = true

---Добавляет функцию или рутину в список рассылки менеджера событий
---@param callback function|thread
function eventmgr_class:addCallback(callback)
	local t = type(callback)
	if t == "function" then
		self.callback_fns[callback] = true
	elseif t == "thread" then
		self.callback_ths[callback] = true
	else error("Bad callback type", 2) end
end

---Удаляет функцию или рутину из списка рассылки менеджера событий
---@param callback function|thread
function eventmgr_class:rmCallback(callback)
	local t = type(callback)
	if t == "function" then
		self.callback_fns[callback] = nil
	elseif t == "thread" then
		if coroutine.status(callback) == "dead" then error("Corutine already died", 2) end
		self.callback_ths[callback] = nil
	else error("Bad callback type", 2) end
end

---Рассылает событие по списку рассылки
---@vararg any?
function eventmgr_class:send(...)
	if self.enabled then
		for callback_fn in pairs(self.callback_fns) do
			local state, errmsg = xpcall(callback_fn, debug.traceback, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			end
		end

		for callback_th in pairs(self.callback_ths) do
			local state, errmsg = coroutine.resume(callback_th, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg or "in coroutine")
				self.callback_ths[callback_th] = nil
			elseif coroutine.status(callback_th) == "dead" then
				self.callback_ths[callback_th] = nil
			end
		end
	end
end
eventmgr_class.__call = eventmgr_class.send

---Создает новый менеджер событий
---@param name string #имя для обработчика (по умолчанию Test)
---@param weak boolean? #делает список колбеков слабой таблицей
---@return Event
return function(name, weak)
	local mgr = eventmgr_class:new()
	mgr.name = name
	if weak then
		mgr.__mode = "k"
		mgr.callback_fns = setmetatable({}, mgr)
		mgr.callback_ths = setmetatable({}, mgr)
	else
		mgr.callback_fns = {}
		mgr.callback_ths = {}
	end

	return mgr
end
