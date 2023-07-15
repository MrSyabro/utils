---Простейщая версия обьекта на основе метатаблице
---@class Object
local O = {}
O.__index = O
O.__name = "Object"

---Создает новый унследованный обьект
---@generic O : Object
---@param self O #обьект от которого производится наследование
---@param name `O`? #имя класса нового экземпляра (если не указано, экземпляр не может создавать новые экземпляры)
---@param data table? #таблица взятая за основу
---@return O new_object
function O.new(self, name, data)
	local data = data or {}
	if name then
		data.__index = data
		data.__name = name
	end
	return setmetatable(data, self)
end

---Рекурсивно копирует обьект включая метатаблицу.
---Если метатаблицы нет, устанавливает `Object`
---@generic O : Object
---@param self O
---@param data table?
---@return O
function O.copy(self, data)
	local data = setmetatable(data or {}, getmetatable(self) or O)

	for key, value in pairs(self) do
		if type(value) == "table" then
			if value ~= O then
				data[key] = O
			else
				data[key] = O.copy(value)
			end
		else
			data[key] = value
		end
	end
	
	return data
end

---Сериализует обьект
---@param self Object
function O.dump(self)
	local ser = require "serialize"
	return ser.ser(self, {[O] = true})
end


return O
