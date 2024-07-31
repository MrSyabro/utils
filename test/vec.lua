local vec = require "vec"

local v1 = assert(vec.newsingle(4))
assert(v1 == {1,1,1,1})
local v2 = assert(vec.new(1,"2",3))
assert(v2 == {1,"2",3})

assert((v1 + v2) == {2,3,4,1})
assert((v2 + v1) == {2,3,4})
assert((v1 * v2) == {1,2,3,1})
assert((v2 * v1) == {1,2,3})
assert((v1 ^ v2) == {1,1,1,1})
assert((v2 ^ v1) == {1,2,3})
assert(-v1 == {-1,-1,-1,-1})

local v3, l = v1:normalize("test")
assert(v3 == {0.5, 0.5, 0.5, 0.5})
assert(l == 2)

assert(v1:lerp(v2, 0.1, "test") == {1, 1.1, 1.2})
assert(v1:len("test") == 2)
assert(v1:copy("test") == {1,1,1,1})
assert(v1:copy(2) == {1,1})
assert(v2:copy(4) == {1,"2",3})

print(vec.new(1,2,3))

print("OK!")
