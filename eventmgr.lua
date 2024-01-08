local obj = require "obj"

local cs, cr = coroutine.status, coroutine.resume

local weak_mt = {__mode = "k"}

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
---@operator add(function|thread):Event
---@operator sub(function|thread):Event
---@field name string #имя менеджера для дебага
---@field private weak boolean?
---@field protected callback_fns table<function, boolean> #список функций колбеков
---@field protected callback_ths table<thread, boolean> #список рутин колбеков
---@field protected callback_objs table<any, fun(self:any, ...:any):boolean?> #список обьектов с методами
local eventmgr_class = obj:new "Event"
eventmgr_class.name = "Test"
eventmgr_class.enabled = true
eventmgr_class.weak = false

---Добавляет функцию, рутину или метод объекта в список рассылки `Event`
---@generic O
---@param callback O
---@param method fun(self: O, ...: any): boolean?
---@return Event self
---@overload fun(self:Event, callback:function|thread): Event
function eventmgr_class:addCallback(callback, method)
	local t = type(callback)
	if t == "function" then
		self.callback_fns[callback] = true
	elseif t == "thread" then
		self.callback_ths[callback] = true
	else
		if type(method) == "function" then
			self.callback_objs[callback] = method
		elseif type(getmetatable(callback).__call) == "function" then
			self.callback_fns[callback] = true
		else
			error("Bad callback type", 2)
		end
	end

	return self
end
eventmgr_class.__add = eventmgr_class.addCallback

---Удаляет функцию, рутину или метод объект из списка рассылки `Event`
---@param callback any
---@return Event self
function eventmgr_class:rmCallback(callback)
	self.callback_fns[callback] = nil
	self.callback_ths[callback] = nil
	self.callback_objs[callback] = nil

	return self
end
eventmgr_class.__sub = eventmgr_class.rmCallback

---Фильтр по умолчанию. Вызывается перед рассылкой сообщения. Если возвращает
---false, то сообщение не отправляется. Фильтр по умолчанию возвращает `enabled`
---
---При переопредилении этого метода стоит учесть работу `enabled` параметра.
---@return boolean
function eventmgr_class:filter(...)
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
			else
				if errmsg == true then
					self.callback_fns[callback_fn] = nil
				end
			end
		end

		for callback_obj, callback_mtd in pairs(self.callback_objs) do
			local state, errmsg = xpcall(callback_mtd, debug.traceback, callback_obj, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			else
				if errmsg == true then
					self.callback_objs[callback_obj] = nil
				end
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
	mgr.weak = weak
	if weak then
		mgr.callback_fns = setmetatable({}, weak_mt)
	else
		mgr.callback_fns = {}
	end
	mgr.callback_ths = {}
	mgr.callback_objs = setmetatable({}, weak_mt)

	return mgr
end

return eventmgr_class
