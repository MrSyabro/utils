local Event = require "event"
warn "@on"
Counter = 0

local function test_leak(mode)
	Counter = 0
	local e1 = Event:new("Test1", mode)
	local cbs_mt = getmetatable(e1.callback_fns)
	assert(cbs_mt.__mode == (mode and "kv" or "v"))

	local test_obj = {
		  data = 10
	}
	function test_obj:test_method()
		assert(self.data == 10)
		Counter = Counter + 1
		return self.data
	end
	e1:add_callback(test_obj, test_obj.test_method)

	local function test_func()
		Counter = Counter + 1
	end
	e1:add_callback(test_func)

	e1:add_callback(function(mess)
		assert(mess == "test")
		Counter = Counter + 1
		return true
	end)

	collectgarbage()
	e1:send "test"
	assert(Counter == (mode and 2 or 3))
	test_func = nil
	collectgarbage()
	e1()
	assert(Counter == (mode and 3 or 5))

	test_obj = nil
	collectgarbage()
	e1:send()
	assert(Counter == (mode and 3 or 7))
end
test_leak(true)
test_leak(false)

--Coroutine test
Counter = 0
local e1 = Event:new "test2"

e1:add_callback(function()
	Counter = Counter + 1
	coroutine.yield()
	Counter = Counter + 1
end)

e1:add_callback(function()
	Counter = Counter + 1
	coroutine.yield()
	Counter = Counter + 1
end)

local c = coroutine.create(function()
	Counter = Counter + 1
	e1()
	Counter = Counter + 1
end)

coroutine.resume(c)
assert(coroutine.status(c) == "suspended")
coroutine.resume(c)
coroutine.resume(c)
assert(Counter == 6, Counter)
assert(coroutine.status(c) == "dead")
