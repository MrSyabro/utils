local ser = require "serialize"

local M = {}
---Std streams
M.stderr = io.stderr
M.stdout = io.stdout
M.debuging = false
M.level = "info" -- Default log function
M.assert_level = "warn" -- Default assert log function
M.stacktrace = false

local function write(input, type, service, data)
    local log_item = {
        time = os.time(),
        type = type,
        service = service,
        data = data,
    }
    local out = ser.ser(log_item) .. "\n"

    input:write(out)
end

function M.info(service, text)
    write(M.stdout, "INFO", service, text)
end

function M.debug(service, text)
    if M.debuging then
        write(M.stdout, "DEBUG", service, text)
    end
end

function M.warn(service, text)
    write(M.stdout, "WARN", service, text)
end

function M.error(service, text, stack)
    if M.stacktrace or stack then
        text = {
            mess = text,
            stack = {}
        }
        local n = 2
        local info
        repeat
            info = debug.getinfo(n, "nSl")
            table.insert(text.stack, info)
            n = n + 1
        until info
    end
    write(M.stderr, "ERROR", service, text)
end

function M.assert(service, ...)
    local args = table.pack(...)
    if args[1] then
        return table.unpack(args)
    else
        M.error(service, args[2] or "assertion failed!")
    end
end

function M.dofile(service, filename, ...)
    return M.assert(service,
        pcall(
            M.assert(service,
                loadfile(filename)
            ),
            ...
        )
    )
end

return M
