local obj = require "obj"
local Collector = require "log.collector"

---@enum LogLevels
LogLevels = {
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    DEBUG = 4,
    VERBOSE = 5,
    "INFO",
    "WARN",
    "ERROR",
    "DEBUG",
    "VERBOSE",
}

local function collector_filter(self, mess)
    return self.enabled and mess.tags.level <= self.level
end

---@class Logger : Object
---@field collector Collector
---@field service string
---@field debuging boolean
---@field verbosing boolean
local logger = obj:new "Logger"
logger.service = "Main"
logger.debuging = false
logger.verbosing = false
logger.collector = Collector
Collector.receive.filter = collector_filter
Collector.receive.level = LogLevels.ERROR

---Вывод информационного сообщения
---@vararg any
function logger:info(...)
    self.collector:collect({service = self.service, level = LogLevels.INFO}, ...)
end

---Вывод сообщения внимание
---@vararg any
function logger:warn(...)
    self.collector:collect({service = self.service, level = LogLevels.WARN}, ...)
end

---Вывод ошибки. Автоматически выводит трассировку
---@vararg any
function logger:error(...)
    self.collector:collect_tb({service = self.service, level = LogLevels.ERROR}, ...)
end

---отладочный вывод
---@vararg any
function logger:debug(...)
    self.collector:collect({service = self.service, level = LogLevels.DEBUG}, ...)
end

---Дополнительный отладоный вывод
---@vararg any
function logger:verbose(...)
    self.collector:collect({service = self.service, level = LogLevels.VERBOSE}, ...)
end

---Создает новый логгер
---@param service string
---@param collector Collector
---@return Logger
function logger:new(service, collector)
    local newl = obj.new(self)
    newl.service = service
    newl.collector = collector
    if collector then
        collector.receive.filter = collector_filter
    end

    return newl
end

return logger
