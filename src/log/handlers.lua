local obj = require "obj"
local to_json, json = pcall(require, "dkjson")
local to_lua, ser = pcall(require, "serialize")

local handler_streams_mt = {
    __call = function(self, data)
        for _, stream in ipairs(self) do
            stream:write(data)
        end
    end
}

---@class Handler : Object
---@field streams table?
---@field write fun(level: string, service: string, args: table): string
local handler = obj:new "Handler"
function handler:add_stream(stream)
    if not stream then error("required one argument", 2) end
    table.insert(self.streams, stream)
end

function handler:remove_stream(id_stream)
    if not id_stream then error("required ine argument", 2) end
    table.remove(self.streams, id_stream)
end

local M = {}
M.default_stream = io.stdout

local function parse_table(data)
    local out = { "" }
    for key, value in pairs(data) do
        table.insert(out, ("[%s] = %q"):format(tostring(key), tostring(value)))
    end
    return table.concat(out, "\n")
end

---Обработчик, который вываливает данные в читаемом виде
---@param streams {number: file* | {write: fun(data: string)}}?
---@return Handler
function M.human(streams)
    local new_handler = handler:new() --[[@as Handler]]
    new_handler.streams = setmetatable(streams or { M.default_stream }, handler_streams_mt)

    function new_handler:write(level, service, args)
        local word
        if #args > 1 then
            local words = {}
            for i = 1, args.n do
                if type(args[i]) == "table" then
                    table.insert(words, parse_table(args[i]))
                else
                    table.insert(words, tostring(args[i]))
                end
            end
            word = table.concat(words, "\t")
        else
            if type(args[1]) == "table" then
                word = parse_table(args[1])
            else
                word = tostring(args[1])
            end
        end
        self.streams(("[%s][%s] %s: %s\n"):format(os.date "!%d.%m %H:%M:%S UTC", level, service, word))
    end

    return new_handler
end

if to_json then
    ---Обработчик, который вываливает данные в json
    ---@param streams {number: file* | {write: fun(data: string)}}}
    ---@return Handler
    function M.json(streams)
        local new_handler = handler:new()
        new_handler.streams = setmetatable({ streams or M.default_stream }, handler_streams_mt)

        function new_handler:write(level, service, args)
            local out = {
                level = level,
                time = os.time(),
                service = service,
                data = args,
            }
            self.streams(json.encode(out) .. "\n")
        end

        return new_handler
    end
end

if to_lua then
    ---Обработчик, который вываливает данные в lua таблице
    ---@param streams {number: file* | {write: fun(data: string)}}}
    ---@return Handler
    function M.lua(streams)
        local new_handler = handler:new()
        new_handler.streams = setmetatable(streams or { M.default_stream }, handler_streams_mt)

        function new_handler:write(level, service, args)
            local out = {
                level = level,
                time = os.time(),
                service = service,
                data = args,
            }
            self.streams(ser(out) .. "\n")
        end

        return new_handler
    end
end

return M
