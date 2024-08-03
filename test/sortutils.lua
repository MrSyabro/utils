require "sortutils"
assert(type(table.sortinsert) == "function")

local t = {2,3,5,6}

table.sortinsert(t, 4)
assert(t[3] == 4)

table.sortinsert(t, 1)
assert(t[1] == 1)

table.sortinsert(t, 2)
assert(t[3] == 2)

t = {5, 4, 2, 1}

table.sortinsert(t, 3, function(a,b)
    if a == b then return end
    return a > b end
)
assert(t[3] == 3)

t = {1, 3, 5, 6, 7, 10, 15, 20}

assert(table.sortsearch(t, 1) == 1)
assert(table.sortsearch(t, 15) == 7)
assert(table.sortsearch(t, 20) == 8)
assert(table.sortsearch(t, 8) == nil)
