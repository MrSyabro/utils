local Event = require "event"
warn "@on"

local e1 = Event:new("Test1")

local counter = 0

local test_obj = {
    data = 10
}

local function test(self)
	assert(self.data == 10)
	counter = counter + 1
end

local function test2()
	counter = counter + 1
	return true
end

test_obj.mt = test

e1:add_callback(test_obj, test)
e1:add_callback(test2)
test2 = nil
test = nil

e1:send "test"
collectgarbage()
e1()
assert(counter == 3)

e1:rm_callback(test_obj)

local counter = 0
local e1 = Event:new "test2"

	e1:add_callback(function()
		print "Test1 1"
		counter = counter + 1
		coroutine.yield()
		print "Test1 2"
		counter = counter + 1
	end)

	e1:add_callback(function()
		print "Test2 1"
		counter = counter + 1
		coroutine.yield()
		print "Test2 2"
		counter = counter + 1
	end)

local c = coroutine.create(function()
	print "TestM 1"
	counter = counter + 1
	e1()
	print "TestM 2"
	counter = counter + 1
	print "Test2"
end)

print "First resume"
coroutine.resume(c)
assert(coroutine.status(c) == "suspended")
coroutine.resume(c)
coroutine.resume(c)
--assert(counter == 6)
assert(coroutine.status(c) == "dead")