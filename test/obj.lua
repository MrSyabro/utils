local obj = require"obj"

c1 = obj:new "Test1"
function c1:test()
    return 1
end

c2 = c1:new "Test2"
function c2:test()
    return 2
end

o1 = c1:new()
o2 = c2:new()

assert(o1:test() == 1)
assert(o2:test() == 2)
assert(c1:is_child(o1))
assert(c1:is_child(o2) == false)
assert(c1:is_inherit(o2))
assert(c2:is_inherit(o1) == false)