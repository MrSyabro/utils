local event = require "eventmgr"

---@class Data : table
---@field data_changed Event|fun(ket: any, data: any, old_data:any) #событие вызывается, когда данные в таблице меняются

--[[
		Функция создает таблицу, которая умеет сообщать об изменении данных внутри себя
	получить событие можно в поле `data_changed: EventManager` и ествественно оно
	защищено от записи. ]]
---@return Data
return function()
    local data = {}
    
    local obj = {
        data_changed = event("Data_changed"),
        __metatable = "Not protected with aboba",
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
        end
    }

    return setmetatable(obj, obj)
end