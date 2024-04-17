local obj = require "obj"
local Collector = require "log.collector"

---@class Logger : Object
---@field collector Collector
---@field service string
---@field debuging boolean
---@field verbosing boolean
local logger = obj:new "logger"
logger.service = "Main"
logger.debuging = false
logger.verbosing = false
logger.collector = Collector

---Вывод информационного сообщения
---@vararg any
function logger:info(...)
    self.collector:collect({service = self.service, level = "INFO"}, ...)
end

---Вывод сообщения внимание
---@vararg any
function logger:warn(...)
    self.collector:collect({service = self.service, level = "WARN"}, ...)
end

---Вывод ошибки. Автоматически выводит трассировку
---@vararg any
function logger:error(...)
    self.collector:collect_tb({service = self.service, level = "ERROR"}, ...)
end

---отладочный вывод
---@vararg any
function logger:debug(...)
    self.collector:collect({service = self.service, level = "DEBUG"}, ...)
end

---Дополнительный отладоный вывод
---@vararg any
function logger:verbose(...)
    self.collector:collect({service = self.service, level = "VERBOSE"}, ...)
end

function logger:new(service, collector)
    local newl = obj.new(self)
    newl.service = service
    newl.collector = collector

    return newl
end

return logger
