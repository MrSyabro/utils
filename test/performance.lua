package.path = "src/?.lua;"..package.path
local ser = require "serialize"

local test_table = {}
for i = 1, 10000 do
    test_table[i] = {["type"] = "DEBUG", time = os.time(), data = i}
end

local start_t = os.clock()

ser(test_table)

local end_t = os.clock()
print("Serialization without readable:", end_t - start_t)

local start_t = os.clock()

ser(test_table, true)

local end_t = os.clock()
print("Serialization with readable:", end_t - start_t)
