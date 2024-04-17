local obj = require "obj"
local Event = require "eventmgr"
local defhandler = require "log.handlers".human()

local tp, dg, ti, ot = table.pack, debug.getinfo, table.insert, os.time

---@class Collector : Object
---@field tags table
---@field data table
---@field receive Event
local collector_class = obj:new "Collector"
collector_class.data = {}
collector_class.receive = Event:new "Collector_receive"
collector_class.receive:addCallback(defhandler, defhandler.send)

---Собирает данные сообщения
---@param tags table<string, string>[]
---@param ... unknown
function collector_class:collect(tags, ...)
    local mess_data = tp(...)
    local mess = dg(2, "Sln") --[[@as table]]
    mess.data = mess_data
    mess.tags = tags
    mess.time = ot()
    mess.source = nil
    local seld_data = self.data
    ti(seld_data, mess)
    self.receive(mess)
end

function collector_class:collect_tb(tags, ...)
    local mess_data = tp(...)
    local mess = dg(2, "Sln") --[[@as table]]
    mess.data = mess_data
    mess.tags = tags
    mess.time = ot()
    mess.source = nil
    local traceback = {}
    local lvl = 3
    repeat
        local di = dg(lvl, "Sln")
        if di then
            di.source = nil
            ti(traceback, di)
            lvl = lvl + 1
        end
    until not di
    mess.traceback = traceback
    local seld_data = self.data
    ti(seld_data, mess)
    self.receive(mess)
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