local vec = require "vec"

local v1 = assert(vec.newsingle(4))
assert(v1:eq {1,1,1,1})
local v2 = assert(vec.new(1,4,8))
assert(v2:eq {1,4,8})
assert(vec.range(1, 3, 0.5):eq {1, 1.5, 2, 2.5, 3})
assert(vec.range(3, 1, -0.5):eq {3, 2.5, 2, 1.5, 1})
local v3 = vec.range(1,6)

assert((v1 + v2):eq {2,5,9,1})
assert((v2 + v1):eq {2,5,9})
assert((v1 * v2):eq {1,4,8,1})
assert((v2 * v1):eq {1,4,8})
assert((v1 ^ v2):eq {1,1,1,1})
assert((v2 ^ v1):eq {1,4,8})
assert((-v1):eq {-1,-1,-1,-1})

assert(v1:len() == 2)
local v3, l = v1:__normalize()
assert(v3:eq {0.5, 0.5, 0.5, 0.5})
assert(l == 2)

--assert(v1:__lerp(v2, 0.1) == {1.0,2.5,4.5,1})
assert(v1:copy(2):eq {1,1})
assert(v2:copy(4):eq {1,4,8,0})
--assert(v3:copy(5, 2):eq {2,3,4,5})

-- Операции изменяющие начальный вектор
v1:normalize()
assert(v1:eq {0.5,0.5,0.5,0.5})
v1:add(0.5)
assert(v1:eq {1,1,1,1})
v1:sub(0.5)
assert(v1:eq {0.5,0.5,0.5,0.5})
v1:mul(2)
assert(v1:eq {1,1,1,1})
v1:div(2)
assert(v1:eq {0.5,0.5,0.5,0.5})
v1:unm()
assert(v1:eq {-0.5,-0.5,-0.5,-0.5})
v1:pow(2)
assert(v1:eq {0.25,0.25,0.25,0.25})

assert(v2:eq(vec.fromhex(v2:tohex())))

print("tostring", vec.new(1,2,3))
assert(vec.__serialize {1,2,3} == "{1,2,3,}") --serialize

print("OK!")
