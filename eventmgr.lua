local obj = require "obj"

local cs, cr = coroutine.status, coroutine.resume

--[[ ### Event - эмитатор событий
`Event` принимает колбеки типов:
- `function`
- `thread`

Вызов `Event:send(...)` рассылает всем колбекам переданные
аргументы.

Опционально список **колбеков-функций** может быть слабым
(не держать ссылки на функции)

Функции экранированы и вызывают `warn` с сообщением ошибки
и названием эмитатора указанного при создании.

Для отправки в рутину используется `resume` соответственно
они поддерживают вечные цикли внутри также они могут сами
уничтожатся в отличии от функций.]]
---@class Event : Object
---@operator call(...):nil #Рассылает событие по списку рассылки
---@field name string #имя менеджера для дебага
---@field protected callback_fns table<function, boolean> #список функций колбеков
---@field protected callback_ths table<thread, boolean> #список рутин колбеков
local eventmgr_class = obj:new "Event"
eventmgr_class.name = "Test"
eventmgr_class.enabled = true

---Добавляет функцию или рутину в список рассылки `Event`
---@param callback function|thread
function eventmgr_class:addCallback(callback)
	local t = type(callback)
	if t == "function" then
		self.callback_fns[callback] = true
	elseif t == "thread" then
		self.callback_ths[callback] = true
	else error("Bad callback type", 2) end
end

---Удаляет функцию или рутину из списка рассылки `Event`
---@param callback function|thread
function eventmgr_class:rmCallback(callback)
	local t = type(callback)
	if t == "function" then
		self.callback_fns[callback] = nil
	elseif t == "thread" then
		if cs(callback) == "dead" then error("Corutine already died", 2) end
		self.callback_ths[callback] = nil
	else error("Bad callback type", 2) end
end

---Фильтр по умолчанию. Вызывается перед рассылкой сообщения. Если возвращает
---false, то сообщение не отправляется. Фильтр по умолчанию возвращает `enabled`
---
---При переопредилении этого метода стоит учесть работу `enabled` параметра.
---@return boolean
function eventmgr_class:filter()
	return self.enabled
end

---Рассылает событие по списку рассылки, если `filter(...)` вернет `true`
---@param ... any?
function eventmgr_class:send(...)
	if self:filter(...) then
		for callback_fn in pairs(self.callback_fns) do
			local state, errmsg = xpcall(callback_fn, debug.traceback, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			end
		end

		for callback_th in pairs(self.callback_ths) do
			local state, errmsg = cr(callback_th, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg or "in coroutine")
				self.callback_ths[callback_th] = nil
			elseif cs(callback_th) == "dead" then
				self.callback_ths[callback_th] = nil
			end
		end
	end
end
eventmgr_class.__call = eventmgr_class.send

---Создает экземпляр `Event`
---@param name string #имя для обработчика (по умолчанию Test)
---@param weak boolean? #делает список колбеков слабой таблицей
---@return Event
function eventmgr_class:new(name, weak)
	local mgr = obj.new(self)
	mgr.name = name
	if weak then
		mgr.__mode = "k"
		mgr.callback_fns = setmetatable({}, mgr)
	else
		mgr.callback_fns = {}
	end
	mgr.callback_ths = {}

	return mgr
end

return eventmgr_class