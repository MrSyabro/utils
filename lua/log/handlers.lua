local Event = require "event"
local to_json, json = pcall(require, "dkjson")
local to_lua, ser = pcall(require, "serialize")

---@class LogHandler : Event
---@field send fun(self: LogHandler, logger: Logger, mess: string)

local M = {}
M.default_stream = io.stdout

---Обработчик, который вываливает данные в читаемом виде
---@param streams table<number, file*|{write: fun(data: string)}>?
---@return LogHandler
function M.human(streams)
	local new_handler = Event:new "HumanLogHandler" --[[@as LogHandler]]
	if streams then
		for _, stream in ipairs(streams) do
			new_handler:addCallback(function(mess)
				stream:write(mess)
			end)
		end
	else
		new_handler:addCallback(io.write)
	end

	---@param logger Logger
	---@param args table
	function new_handler:send(logger, args)
		local tags = logger.tags
		local word
		if args.n > 1 then
			local words = {}
			for i = 1, args.n do
				table.insert(words, tostring(args[i]))
			end
			word = table.concat(words, "\t")
		else
			word = tostring(args[1])
		end
		if args.level == LogLevels.ERROR then
			word = debug.traceback(word, 5)
		end
		Event.send(self,
			("[%s][%s] %s: %s\n"):format(os.date("!%d.%m %H:%M:%S UTC"), LogLevels[args.level], logger.name, word))
	end

	return new_handler
end

if to_json then
	---Обработчик, который вываливает данные в json
	---@param streams table<number, file*|{write: fun(data: string)}>?
	---@return LogHandler
	function M.json(logger, streams)
		local new_handler = Event:new "JSONLogHandler" --[[@as LogHandler]]
		if streams then
			for _, stream in ipairs(streams) do
				new_handler:addCallback(function(mess)
					stream:write(mess)
				end)
			end
		else
			new_handler:addCallback(function(mess)
				io.write(mess)
			end)
		end

		function new_handler:send(mess)
			Event.send(self, json.encode(mess) .. "\n")
		end

		return new_handler
	end
end

if to_lua then
	---Обработчик, который вываливает данные в lua таблице
	---@param streams table<number, file*|{write: fun(data: string)}>?
	---@return LogHandler
	function M.lua(logger, streams)
		local new_handler = Event:new "LuaLogHandler" --[[@as LogHandler]]
		if streams then
			for _, stream in ipairs(streams) do
				new_handler:addCallback(function(mess)
					stream:write(mess)
				end)
			end
		else
			new_handler:addCallback(function(mess)
				io.write(mess)
			end)
		end

		function new_handler:send(mess)
			Event.send(self, ser(mess) .. "\n")
		end

		return new_handler
	end
end

return M
