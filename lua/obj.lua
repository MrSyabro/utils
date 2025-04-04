---Простейщая версия обьекта на основе метатаблице
---@class Object
---@field __name string
---@field __index table
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

---Проверяет, является ли обьект дочерным
---@param self Object
---@param obj Object
---@return boolean
function O.is_child(self, obj)
	return getmetatable(obj) == self
end

---Проверяет, наследуется ли класс обьектом
---@param self Object
---@param obj Object
---@return boolean
function O.is_inherit(self, obj)
	local parent = getmetatable(obj)
	while parent do
		if parent == self then return true end
		parent = getmetatable(parent)
	end
	return false
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
			if value == O then
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
