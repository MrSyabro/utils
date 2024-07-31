local REST = require "rest"
local ser = require "serialize".serialize

local cmc = REST:new("https://api.mobula.io/api/1")

local response = cmc.market.data.GET[{
    symbol = "0x3affcca64c2a6f4e3b6bd9c64cd2c969efd1ecbe",
}]()

print(ser(response, true))