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

local function collector_filter(self, collector, mess)
	return self.enabled and mess.level <= self.level
end

---@class Logger : Object
---@field collector Collector
---@field tags {service: string}|table
---@field debuging boolean
---@field verbosing boolean
local logger = obj:new "Logger"
logger.tags = {
	service = "Main"
}
logger.collector = Collector
Collector.receive.filter = collector_filter
Collector.receive.level = LogLevels.ERROR

local cache = {
	Main = logger
}

---Вывод информационного сообщения
---@vararg any
function logger:info(...)
	self.collector:collect(LogLevels.INFO, self.tags, ...)
end

---Вывод сообщения внимание
---@vararg any
function logger:warn(...)
	self.collector:collect(LogLevels.WARN, self.tags, ...)
end

---Вывод ошибки. Автоматически выводит трассировку
---@vararg any
function logger:error(...)
	self.collector:collect_tb(LogLevels.ERROR, self.tags, ...)
end

---отладочный вывод
---@vararg any
function logger:debug(...)
	self.collector:collect(LogLevels.DEBUG, self.tags, ...)
end

---Дополнительный отладоный вывод
---@vararg any
function logger:verbose(...)
	self.collector:collect(LogLevels.VERBOSE, self.tags, ...)
end

---Установить новый сборщик
---@param collector Collector?
function logger:setcollector(collector)
	self.collector = collector
	if collector then
		collector.receive.filter = collector_filter
		collector.receive.level = self.collector.receive.level
	end
end

---Создает новый логгер
---@param service string
---@param collector Collector?
---@return Logger
function logger:new(service, collector)
	local cached = cache[service]
	if cached then print("ABOBA") return cached end

	local newl = obj.new(self)
	newl.tags = setmetatable({ service = service }, { __index = self.tags })
	newl:setcollector(collector)

	cache[service] = newl
	return newl
end

return logger
