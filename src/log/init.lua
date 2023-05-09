local obj = require "obj"
local handlers = require "log.handlers"

local logger_handlers_mt = {
    __call = function(self, level, logger, data)
        for _, handler in ipairs(self) do
            handler:write(level, logger.service, data)
        end
    end
}

---@class Logger : Object
---@field service string
---@field handlers Handler[]
---@field debuging boolean
---@field verbosing boolean
local logger = obj:new "logger"
logger.service = "LOG"
logger.debuging = false
logger.verbosing = false

---Вывод информационного сообщения
---@vararg any
function logger:info(...)
    self.handlers("INFO", self, table.pack(...))
end

---Вывод сообщения внимание
---@vararg any
function logger:warn(...)
    self.handlers("WARN", self, table.pack(...))
end

---Вывод ошибки. Автоматически выводит трассировку
---@vararg any
function logger:error(...)
    local args = table.pack(...)
    table.insert(args, debug.traceback("", 3))
    args.n = args.n + 1
    self.handlers("ERROR", self, args)
end

---отладочный вывод
---@vararg any
function logger:debug(...)
    if self.debuging then
        self.handlers("DEBUG", self, table.pack(...))
    end
end

---Дополнительный отладоный вывод
---@vararg any
function logger:verbose(...)
    if self.verbosing then
        self.handlers("VERBOSE", self, table.pack(...))
    end
end

---Добавляет обработчик сообщения
---@param handler Handler
function logger:add_handler(handler)
    if not handler then error("one argument required", 2) end
    if not handler.write then error("bad handler", 2) end

    table.insert(self.handlers, handler)
end

local M = {}
M.loggers = {}
M.default_handler = handlers.human()

---comment
---@param service string?
---@param handler Handler?
---@return Logger
function M.new(service, handler)
    if M.loggers[service] then return M.loggers[service] end
    local new = logger:new()
    new.handlers = setmetatable({ handler or M.default_handler }, logger_handlers_mt)
    if service then
        new.service = service
        M.loggers[service] = new
    end

    return new
end

return M
