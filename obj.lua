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

---Получает имя обьекта из метатблицы
---@return string?
function O:get_name()
	return self.__name
end

---Устанавливает имя обьекта в метатаблице
---@param name string?
function O:set_name(name)
	self.__name = name
end

---Возвращает родительский обьект
---@return Object
function O:parent()
	return self.__index
end

return O
