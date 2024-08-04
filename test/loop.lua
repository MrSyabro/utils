local loop = require "loop":new()
local mat = require "matrix"
warn "@on"

local function matfibonaci(SIZE, count, sym)
    local m1 = mat.newsingle(SIZE, SIZE)
    local m2 = mat.newsingle(SIZE, SIZE)
    for i = 1, count do
        m2, m1 = m1, m2 * m1
        io.write(sym)
        coroutine.yield()
    end
    return m2
end

-- [[ Главная рутина (Main thread)
loop:acall(function()
    local t1 = loop:acall(matfibonaci, 100, 100, '-')
    local t2 = loop:acall(matfibonaci, 50, 500, '#')
    local t3 = loop:acall(matfibonaci, 50, 500, '*')
    local t4 = loop:acall(matfibonaci, 10, 1000, '|')
    local t5 = loop:acall(matfibonaci, 10, 1000, '\\')
    local t6 = loop:acall(matfibonaci, 10, 1000, '/')

    loop:await(t1)
    loop:await(t2)
    loop:await(t3)
    loop:await(t4)
    loop:await(t5)
    loop:await(t6)

    loop:exit()
end)--]]

print("Starting mainloop")
loop:main()
print()