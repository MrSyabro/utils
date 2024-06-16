local obj = require "obj"
local Event = require "eventmgr"
local defhandler = require "log.handlers".human()
local ser  = require("serialize").serialize
local tp, dg, getmt, ti, ot = table.pack, debug.getinfo, getmetatable, table.insert, os.time

local function parse_table(data, level)
	local out = { "" }
	for key, value in pairs(data) do
		local mt = getmt(value)
		if mt and mt.__log then
			value = mt.__log(value, level)
		end
		table.insert(out, ("[%s] = %q"):format(tostring(key), tostring(value)))
	end
	return table.concat(out, "\n")
end

---@class CollectorMessage : debuginfo
---@field level number
---@field data table<integer, string|number|table>
---@field tags table<string, string|number>
---@field traceback debuginfo[]?
---@field source nil
---@field time integer

---@class Collector : Object
---@field data CollectorMessage[]
---@field receive Event|fun(self: Collector, msg: CollectorMessage)
local collector_class = obj:new "Collector"
collector_class.data = {}
collector_class.receive = Event:new "Collector_receive"
collector_class.receive:addCallback(defhandler, defhandler.send)

---Собирает данные сообщения
---@param level number
---@param tags table<string, string>[]
---@param ... any сообщение
function collector_class:collect(level, tags, ...)
	local mess_data = tp(...)
	for i, t in ipairs(mess_data) do
		local mt = getmt(t)
		if mt and mt.__log then
			mess_data[i] = mt.__log(t, level)
		elseif type(t) == "table" then
			if level == LogLevels.VERBOSE then
				mess_data[i] = ser(t, 2)
			else
				mess_data[i] = parse_table(t, level)
			end
		end
	end
	local mess = dg(2, "Sln") --[[@as CollectorMessage]]
	mess.data = mess_data
	mess.tags = tags
	mess.level = level
	mess.time = ot()
	mess.source = nil
	ti(self.data, mess)
	self:receive(mess)
end

---Собрать данные сообщения с обратной трассировкой вызовов
---@param level number
---@param tags table<string, string>[]
---@param ... any сообщене
function collector_class:collect_tb(level, tags, ...)
	local mess_data = tp(...)
	for i, t in ipairs(mess_data) do
		local mt = getmt(t)
		if mt and mt.__log then
			mess_data[i] = mt.__log(t, level)
		elseif type(t) == "table" then
			if level == LogLevels.VERBOSE then
				mess_data[i] = ser(t, 2)
			else
				mess_data[i] = parse_table(t)
			end
		end
	end
	local mess = dg(2, "Sln") --[[@as table]]
	mess.data = mess_data
	mess.tags = tags
	mess.level = level
	mess.time = ot()
	mess.source = nil
	local traceback = {}
	local lvl = 3
	repeat
		local di = dg(lvl, "Slnuf")
		if di then
			di.source = nil
			di.vars = {}
			for i = 1, di.nups do
				local varname, varvalue = debug.getupvalue(di.func, i)
				di.vars[varname] = tostring(varvalue)
			end
			di.func = nil
			di.nups = nil
			di.isvararg = nil
			di.nparams = nil
			ti(traceback, di)
			lvl = lvl + 1
		end
	until not di
	mess.traceback = traceback
	ti(self.data, mess)
	self:receive(mess)
end

---Имитирует повторную отправку всех сообщений лога
function collector_class:outall()
	self.receive.enabled = true
	for _, mess in ipairs(self.data) do
		self:receive(mess)
	end
end

---Создает новый сборщик
---@param handlers LogHandler[]? если не указано, то ставится дефолтный обработчик
---@return Collector
function collector_class:new(handlers)
	local instance = obj.new(collector_class)

	instance.data = {}
	instance.receive = Event:new "Collector_receive"

	if handlers then
		for _, handler in ipairs(handlers) do
			instance.receive:addCallback(handler, handler.send)
		end
	else
		instance.receive:addCallback(defhandler, defhandler.send)
	end

	return instance
end

return collector_class
