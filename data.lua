local event = require "eventmgr"

---@class Data : table
---@field data_changed Event|fun(ket: any, data: any, old_data:any) #событие вызывается, когда данные в таблице меняются

---Фильтр для данных. Блокирует отправку, если старые данные и новые равны
local function data_changed_filter(self, k, v, ov)
    if self.enabled and v ~= ov then
        return true
    else
        return false
    end
end

--[[Функция создает таблицу, которая умеет сообщать об изменении данных внутри себя
	получить событие можно в поле `data_changed: EventManager` и ествественно оно
	защищено от записи. ]]
---@return Data
return function()
    local data = {}
    
    local obj = {
        data_changed = event:new("Data_changed"),
        __pairs = function (self)
            return pairs(data)
        end,
        __newindex = function (self, key, new_data)
            self.data_changed(key, new_data, data[key])
            data[key] = new_data
        end,
        __index = data,
        __len = function(self)
            return #data
        end,
        __tostring = function (self)
            local serialize = require "serialize"
            return serialize.fser(data, 3)
        end
    }

    obj.data_changed.filter = data_changed_filter

    return setmetatable(obj, obj)
end