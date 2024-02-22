local obj = require "obj"

local cr, cs = coroutine.resume, coroutine.status

---@class Loop : Object
---@field pool table<thread, boolean>
---@field name string?
local loopclass = obj:new "Loop"
loopclass.time = 0.005

function loopclass:step()
    local c = os.clock()
    for thread in pairs(self.pool) do
        local state, errmsg = cr(thread)
        if not state then
            warn(debug.traceback(thread, ("[%s] Callback error: %s"):format(self.name or "Loop", errmsg or "in coroutine")))
            self.pool[thread] = nil
        elseif cs(thread) == "dead" then
            self.pool[thread] = nil
        end
        if (os.clock() - c) > loopclass.time then return end
    end
end

---Регистрирует новую нить в пуле
---@param thread thread
function loopclass:register(thread)
    if type(thread) ~= "thread" then error("Bad thread type", 2) end
    self.pool[thread] = true
end

---Создает новый пул нитей
---@param data string|table?
---@return Loop
function loopclass:new(data)
    if type(data) == "string" then data = {name = data} end
    local loop = obj.new(loopclass, nil, data) --[[@as Loop]]

    loop.pool = {}

    return loop
end

return loopclass
