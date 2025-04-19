local obj = require "obj"

local dtb = debug.traceback

local metatables = {
	[false] = {__mode = "v"},
	[true] = {__mode = "vk"},
}

---@class _ph
local _ph = {}

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
---@field private weak boolean?
---@field protected callback_fns table<any, _ph|function> #список функций колбеков
local eventmgr_class = obj:new "Event"
eventmgr_class.placeholder = _ph
eventmgr_class.metatables = metatables
eventmgr_class.name = "Default"
eventmgr_class.enabled = true

---Добавляет функцию или объект в список рассылки `Event`.
---Ссылки на методы обьектов не будут удерживаться в независимости от слабости указаной в конструкторе,
---поэтому не ленитесь и сохраняйте методы в самих обьектах.
---@generic O : any
---@param callback O
---@param method fun(self: O, ...: any): boolean?
---@return O
---@overload fun(self: Event, callback: (fun(...:any):boolean?)): function
function eventmgr_class:addCallback(callback, method)
	self.callback_fns[callback] = method or _ph
	return callback
end
function eventmgr_class:__add(callback, method)
	return self:addCallback(callback, method)
end

---Удаляет функцию, рутину или метод объект из списка рассылки `Event`
---@generic O
---@param callback O
---@return Event self
---@overload fun(self: Event, callback: function): Event
function eventmgr_class:rmCallback(callback)
	self.callback_fns[callback] = nil
	return self
end
function eventmgr_class:__sub(callback)
	return self:rmCallback(callback)
end

---Фильтр по умолчанию. Вызывается перед рассылкой сообщения. Если возвращает
---`false`, то сообщение не отправляется. Фильтр по умолчанию возвращает поле `enabled`
---
---При переопредилении этого метода стоит учесть работу `enabled` параметра.
---@return boolean
function eventmgr_class:filter(...)
	return self.enabled
end

---Рассылает событие по списку рассылки, если `filter(...)` вернет `true`
---@param ... any?
---@return Event self
function eventmgr_class:send(...)
	if self:filter(...) then
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
function eventmgr_class:__call(...)
	return self:send(...)
end

function eventmgr_class:__tostring()
	return self.__name .. " `" .. self.name .. "`"
end

---Создает экземпляр `Event`
---@param name string? имя для обработчика (по умолчанию Test)
---@param weak boolean? если передано `true`, `Event` не будет удерживать ссылки на колбеки-функции
---@return Event
function eventmgr_class:new(name, weak)
	local mgr = obj.new(self)
	if name then mgr.name = name end
	mgr.callback_fns = setmetatable({}, metatables[weak or false])

	return mgr
end

return eventmgr_class
