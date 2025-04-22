local obj = require "obj"

---@class _ph

--[[ ### Event
Предназначен для множественного вызова функций с переданными аргументами.

Функции экранированы и вызывают `warn` с названием ивента
и сообщением ошибки. Учтите, что систему `warn` нужно включить,
что бы увидеть сообщения.
]]
---@class Event : Object
---@operator call(...):Event #Рассылает событие по списку рассылки
---@operator add(any):any
---@operator sub(any):Event
---@field name string #имя менеджера для дебага
---@field traceback fun(message: any): string
---@field protected metatables table<boolean, {__mode: 'v'|'vk'}>
---@field protected placeholder _ph
---@field protected callback_fns table<any, _ph|function> #список функций колбеков
local event_class = obj:new "Event"
event_class.placeholder = {} --[[@as _ph]]
event_class.metatables = {
	[false] = {__mode = "v"},
	[true] = {__mode = "kv"},
}
event_class.name = "Default"
event_class.enabled = true
event_class.traceback = debug.traceback

---Добавляет функцию или объект в список рассылки `Event`.
---Ссылки на методы обьектов не будут удерживаться в независимости от слабости указаной в конструкторе,
---поэтому не ленитесь и сохраняйте методы в самих обьектах.
---@generic O : any
---@param callback O
---@param method fun(self: O, ...: any): boolean?
---@return O
---@overload fun(self: Event, callback: (fun(...:any):boolean?)): function
function event_class:add_callback(callback, method)
	self.callback_fns[callback] = method or self.placeholder
	return callback
end
function event_class:__add(callback, method)
	return self:add_callback(callback, method)
end

---Удаляет функцию или метод объекта из списка рассылки `Event`
---@generic O
---@param callback O
---@return Event self
---@overload fun(self: Event, callback: function): Event
function event_class:rm_callback(callback)
	self.callback_fns[callback] = nil
	return self
end
function event_class:__sub(callback)
	return self:rm_callback(callback)
end

---Фильтр по умолчанию. Вызывается перед рассылкой сообщения. Если возвращает
---`false`, то сообщение не отправляется. Фильтр по умолчанию возвращает поле `enabled`
---
---При переопредилении этого метода стоит учесть работу `enabled` параметра.
---@return boolean
function event_class:filter(...)
	return self.enabled
end

---Рассылает событие по списку рассылки, если `filter(...)` вернет `true`
---@param ... any?
---@return Event self
function event_class:send(...)
	if self:filter(...) then
		local dtb, _ph = self.traceback, self.placeholder
		for callback_obj, callback_mtd in pairs(self.callback_fns) do
			local state, errmsg
			if callback_mtd == _ph then
				state, errmsg = xpcall(callback_obj, dtb, ...)
			else ---@cast callback_mtd function
				state, errmsg = xpcall(callback_mtd, dtb, callback_obj, ...)
			end
			if not state then
				warn("In ", self:__tostring(), " callback error: ", errmsg)
			elseif errmsg == true then
				self.callback_fns[callback_obj] = nil
			end
		end
	end
	return self
end
function event_class:__call(...)
	return self:send(...)
end

function event_class:__tostring()
	return self.__name .. " `" .. self.name .. "`"
end

---Создает экземпляр `Event`
---@param name string? имя для обработчика (по умолчанию Test)
---@param weak boolean? если передано `true`, `Event` не будет удерживать ссылки на колбеки-функции
---@return Event
function event_class:new(name, weak, traceback_handler)
	local mgr = obj.new(self)
	if name then mgr.name = name end
	mgr.traceback = traceback_handler
	mgr.callback_fns = setmetatable({}, self.metatables[weak or false])

	return mgr
end

return event_class
