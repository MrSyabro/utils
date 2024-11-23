local ltn12 = require("ltn12")
local json = require("dkjson")
local url = require "socket.url"

---Конструктор rest запросов
---@class RESTclass
---@field url string
---@field urlctr string
---@field urlsufix string
---@field headers table<string, string|number>
---@field encoder fun(data: table):string
---@field lib http|https
local o = {}

---@enum Methods
local methods = {
	POST = true,
	GET = true,
	HEAD = true,
	PUT = true,
	DELETE = true,
	CONNECT = true,
	OPTIONS = true,
	TRACE = true,
	PATCH = true,
}

---Каждый ключ, кроме имени метода запроса, будет добавлен в URL запроса.
---
---Усли ключ - это таблица, она будет закодирована как `urlencoded` и добавлена в url запроса через `?`
---
---Вызов любого ключа инициирует запрос. Если передана строка, она будет записана как тело запроса,
---если передана таблица, она будет закодирована с помощью `encoder` функции
---и записана как тело запроса.
---
---Ожидается ответ в формате json, котрый будет декодирован и возвращен в ответе вызова.
---
---Имеется 2 стандартных энкодера:
--- * `REST.urlencoder`
--- * `REST.jsonencoder` выбирается по умолчанию
---@alias REST table<string, REST>|fun(req_data: table|string)|RESTclass|Methods

function o:__index(key)
	if methods[key] then
		self.method = key
	elseif type(key) == "table" then
		local req = o.urlencoder(key)
		if req then
			self.urlctr = self.urlctr .. "?" .. req
		end
	else
		self.urlctr = self.urlctr .. "/" .. key
	end
	return self
end

function o:__call(req_data)
	local resq_data = {}
	local req = {
		url = self.urlctr .. self.urlsufix,
		sink = ltn12.sink.table(resq_data),
		headers = self.headers
	}
	req.headers["Accept"] = "application/json"
	
	if type(req_data) == "table" then
		req_data = self.encoder(req_data)
	end
	if req_data then
		req.headers["Content-Type"] = (self.encoder == o.jsonencoder) and "application/json" or "application/x-www-form-urlencoded"
		req.headers["Content-Legth"] = #req_data
		req.method = self.method
		req.source = ltn12.source.string(req_data)
	end

	assert(self.lib.request(req))
	self.urlctr = self.url
	local out = table.concat(resq_data)
	return json.decode(out)
end

function o.urlencoder(data)
	local urlencoded = {}
	for k,v in pairs(data) do
		table.insert(urlencoded, string.format("%s=%s", url.escape(k), url.escape(v)))
	end
	if #urlencoded > 0 then
		return table.concat(urlencoded, "&")
	else
		return nil
	end
end

function o.jsonencoder(data)
	if not next(data) then
		return nil
	end
	return json.encode(data)
end

---Создает экземпляр для запросов на сервер
---@param url string
---@param headers? table<string, string>
---@param encoder? fun(data: table):string?
---@param urlsufix? string
---@return REST
function o:new(url, headers, encoder, urlsufix)
	local newoai = setmetatable({
		url = url,
		urlctr = url,
		headers = headers or {},
		urlsufix = urlsufix or "",
		method = "GET",
		encoder = encoder or o.jsonencoder,
		lib = string.match(url, "https") and require "ssl.https" or require "socket.http"
	}, self)

	return newoai
end

return o
