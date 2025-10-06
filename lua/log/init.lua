local obj = require "obj"
local Event = require "event"
local defhandler = require "log.handlers".human()

local loggers = {}

local tp, getmt = table.pack, getmetatable
local function parse_table(data)
	local out = { "" }
	for key, value in pairs(data) do
		table.insert(out, ("[%s] = %q"):format(tostring(key), tostring(value)))
	end
	return table.concat(out, "\n")
end
local function parse_args(args, level)
	for i, arg in ipairs(args) do
		local mt = getmt(arg)
		if mt and mt.__log then
			args[i] = mt.__log(arg, level)
		elseif type(arg) == "table" then
			args[i] = parse_table(arg)
		else
			args[i] = tostring(arg)
		end
	end
	return args
end


---@enum LogLevels
LogLevels = {
	"ERROR",
	"WARN",
	"INFO",
	"DEBUG",
	"TRACE",
	"VERBOSE",
}

---@class Logger : Object
---@field tags table<string, string|number>
---@field level LogLevels
---@field name string
---@field on_message Event
local logger_class = obj:new "Logger"
logger_class.on_message = Event:new "LoggerMain:on_message"
logger_class.tags = {}
logger_class.name = "Main"
logger_class.on_message:add_callback(defhandler, defhandler.send)
for i, key in ipairs(LogLevels) do
	LogLevels[key] = i
	logger_class[string.lower(key)] = function (self, ...)
		if i <= self.level then
			local args = parse_args(tp(...), i)
			args.level = i

			self:on_message(args)
		end
	end
end
logger_class.level = LogLevels.INFO

---@param name string
---@return Logger
function logger_class:new(name)
	local existed = loggers[name]
	if existed then return existed end

	local newlog = obj.new(self)
	newlog.name = name

	loggers[name] = newlog
	return newlog
end

loggers.Main = logger_class

return logger_class
