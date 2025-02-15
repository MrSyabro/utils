local Event = require "eventmgr"

local e1 = Event:new("Test1")

local test_obj = {
    data = 10
}

local function test(self)
    print("Yes", self.data)
end

test_obj.mt = test

e1:addCallback(test_obj, test)
test = nil
collectgarbage()
e1:send "test"