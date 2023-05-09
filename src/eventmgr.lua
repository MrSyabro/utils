local obj = require "obj"

---@class Event : Object
---@operator call(...):nil 
---@field n number #кол-во функций менеджера
---@field name string #имя менеджера для дебага
---@field callbacks table<function, boolean> #список функций колбеков
---Менеджер событий для реализации подписки и рассылки на несколько функций
local eventmgr_class = obj:new "Event"
eventmgr_class.name = "Test"
eventmgr_class.enabled = true

---Добавляет функцию в список рассылки менеджера событий
---@param callback_fn function
function eventmgr_class:addCallback(callback_fn)
	assert(type(callback_fn) == "function", "Bad callback type")
	self.callbacks[callback_fn] = true
end

---Удаляет функцию из списка рассылки менеджера событий
---@param callback_fn function
function eventmgr_class:rmCallback(callback_fn)
	assert(type(callback_fn) == "function", "Bad callback type")

	self.callbacks[callback_fn] = nil
end

---Рассылает событие по списку рассылки
---@vararg any?
function eventmgr_class:send(...)
	if self.enabled then
		for callback_fn in pairs(self.callbacks) do
			local state, errmsg = xpcall(callback_fn, debug.traceback, ...)
			if not state then
				warn(self.name, " Callback error: ", errmsg)
			end
		end
	end
end
eventmgr_class.__call = eventmgr_class.send

---Создает новый менеджер событий
---@param name string #имя для обработчика (по умолчанию Test)
---@return Event
return function(name)
	local mgr = eventmgr_class:new()
	mgr.name = name
	mgr.callbacks = {}

	return mgr
end
