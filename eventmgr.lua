local obj = require "obj"

local dtb = debug.traceback

local weak_mt = {__mode = "k"}

--[[ ### Event - эмитатор событий
`Event` принимает колбеки типов:
- `function`
- `table`

Вызов `Event:send(...)` рассылает всем колбекам переданные
аргументы.

Функции экранированы и вызывают `warn` с сообщением ошибки
и названием эмитатора указанного при создании.

Ивент хранит 3 списка колбеков отдельно:

* обычный для лямбд, которые будут жить вечно до rmCallback
* слабый для функций, которые живут в других обьектах и могут быть уничтожены сборщиком
* слабый для обьектов и их методов
]]
---@class Event : Object
---@operator call(...):nil #Рассылает событие по списку рассылки
---@operator add(function|thread):Event
---@operator sub(function|thread):Event
---@field name string #имя менеджера для дебага
---@field private weak boolean?
---@field protected callback_fns table<function, boolean> #список функций колбеков
---@field protected callback_weak_fns table<function, boolean> #слабый список функций колбеков
---@field protected callback_objs table<any, fun(self:any, ...:any):boolean?> #список обьектов с методами
local eventmgr_class = obj:new "Event"
eventmgr_class.name = "Test"
eventmgr_class.enabled = true
eventmgr_class.weak = false

---Добавляет функцию, рутину или метод объекта в список рассылки `Event`
---
---Список колбеков по умолчанию выбирается в зависимости от `self.weak`
---или из 2го аргумента
---@generic O
---@param callback O
---@param method fun(self: O, ...: any): boolean?
---@return O
---@overload fun(self: Event, callback: (fun(...:any):boolean?), weak: boolean?): function
function eventmgr_class:addCallback(callback, method)
	local t = type(callback)
	if t == "function" then
		if method == nil then
			method = self.weak
		end
		local fns_list = method and self.callback_weak_fns or self.callback_fns
		fns_list[callback] = true
	else
		if type(method) == "function" then
			self.callback_objs[callback] = method
		elseif type(getmetatable(callback).__call) == "function" then
			self.callback_fns[callback] = true
		else
			error("Bad callback type", 2)
		end
	end

	return callback
end
eventmgr_class.__add = eventmgr_class.addCallback

---Добавляет колбек в слабый список
---@param callback function
function eventmgr_class:addWeakCb(callback)
	self:addCallback(callback, true)
end

---Добавляет колбек в сильный список
---@param callback function
function eventmgr_class:addStrongCb(callback)
	self:addCallback(callback, false)
end

---Удаляет функцию, рутину или метод объект из списка рассылки `Event`
---@generic O
---@param callback O
---@return Event self
---@overload fun(self: Event, callback: function): Event
function eventmgr_class:rmCallback(callback)
	self.callback_weak_fns[callback] = nil
	self.callback_fns[callback] = nil
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
			local state, errmsg = xpcall(callback_fn, dtb, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			else
				if errmsg == true then
					self.callback_fns[callback_fn] = nil
				end
			end
		end

		for callback_fn in pairs(self.callback_weak_fns) do
			local state, errmsg = xpcall(callback_fn, dtb, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			else
				if errmsg == true then
					self.callback_weak_fns[callback_fn] = nil
				end
			end
		end

		for callback_obj, callback_mtd in pairs(self.callback_objs) do
			local state, errmsg = xpcall(callback_mtd, dtb, callback_obj, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			else
				if errmsg == true then
					self.callback_objs[callback_obj] = nil
				end
			end
		end
	end
end

function eventmgr_class:__call(...)
	self:send(...)
end

function eventmgr_class:__tostring()
	return self.__name .. ": " .. self.name
end

---Создает экземпляр `Event`
---@param name string #имя для обработчика (по умолчанию Test)
---@param weak boolean? #делает список колбеков слабой таблицей
---@return Event
function eventmgr_class:new(name, weak)
	local mgr = obj.new(self)
	mgr.name = name
	mgr.weak = weak
	mgr.callback_weak_fns = setmetatable({}, weak_mt)
	mgr.callback_fns = {}
	mgr.callback_objs = setmetatable({}, weak_mt)

	return mgr
end

return eventmgr_class
