local event = require "eventmgr"
--[[
		Функция создает таблицу, которая умеет сообщать об изменении данных внутри себя
	получить событие можно в поле `data_changed: EventManager` и ествественно оно
	защищено от записи.
--]]

---@return table
return function()
    local data = {
        data_changed = event("Data_changed"),
        __metatable = "aboba",
    }
    data.__index = data
    function data.__pairs(self) return pairs(data) end
    function data.__len(self)
    	return #data
    end
    function data.__newindex(self, key, new_data)
        if key == "__index"
        or key == "__newindex"
        or key == "__metatable"
        or key == "__pairs"
        or key == "__len"
        or key == "data_changed"
        then return end

        self.data_changed(key, new_data)
        data[key] = new_data
    end
    
    local obj = {}

    return setmetatable(obj, data)
end