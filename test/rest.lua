local REST = require "rest"
local ser = require "serialize".serialize

local cmc = REST:new("https://api.mobula.io/api/1")

local response = cmc.market.data.GET[{
    symbol = "BTC",
}]()

print(ser(response, true))