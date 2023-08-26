---@class traceinfo : debuginfo
---@field id number
---@field callcount number количество вызовов
---@field start number вспомогательная переменная
---@field clock number время работы функции
---@field full_clock number полное время работы за все вызовы
---@field callers number[] количество вызовов из каждой функции

local M = {}

local funcs_count = 0
---@type table<function, traceinfo> таблица данных трассировки
M.funcs_list = {}

local serialize_funcs
local function serialize_traceinfo(traceinfo)
	local out = {"{"}
	for k, v in pairs(traceinfo) do
		if k == "callers" then
			table.insert(out, "callers={")
			for fid, count in pairs(v) do
				table.insert(out, string.format("[%d]=%d,", fid, count))
			end
			table.insert(out, "},")
		elseif k ~= "func" and k ~= "start" then
			table.insert(out, string.format("[%q]=%q,", k, v))
		end
	end
	table.insert(out,"}")
	return table.concat(out)
end

serialize_funcs = function(funcs)
	local out = {"{"}
	for _, traceinfo in pairs(funcs) do
		table.insert(out, string.format("[%d]=%s,", traceinfo.id, serialize_traceinfo(traceinfo)))
	end
	table.insert(out, "}")
	return table.concat(out)
end

local function hook(hook_type)
	debug.sethook()
	local traceinfo = debug.getinfo(2,"nStuf") --[[@as traceinfo]]
	local secondti = debug.getinfo(3, "f")
	if hook_type == "call" then
		local storedinfo = M.funcs_list[traceinfo.func]
		if storedinfo then
			storedinfo.start = os.clock()
			if secondti then
				local second_sti = M.funcs_list[secondti.func]
				if second_sti then
					local sid = second_sti.id
					local calls = storedinfo.callers[sid] or 0
					storedinfo.callers[sid] = calls + 1
				end
			end
		elseif traceinfo.short_src ~= "[C]" then
			traceinfo.start = os.clock()
			traceinfo.full_clock = 0
			traceinfo.source = nil
			traceinfo.lastlinedefined = nil
			traceinfo.callers = {}
			if secondti then
				local ti2 = M.funcs_list[secondti.func]
				if ti2 then
					traceinfo.callers[ti2.id] = 1
				end
			end
			funcs_count = funcs_count + 1
			traceinfo.id = funcs_count
			M.funcs_list[traceinfo.func] = traceinfo
		end
	elseif hook_type == "return" then
		local storedinfo = M.funcs_list[traceinfo.func]
		if storedinfo then
			storedinfo.clock = os.clock() - storedinfo.start
			storedinfo.full_clock = storedinfo.full_clock + storedinfo.clock
		end
	end
	return debug.sethook(hook, "cr")
end

---Запускает трассировки всех вызовов
---@return unknown
function M.start()
	return debug.sethook(hook, "cr")
end

---Останавливает трассировку
function M.stop()
	return debug.sethook()
end

---Возвращает сериализованную таблицу трассировки
---@return string
function M.dump()
	return serialize_funcs(M.funcs_list)
end

return M
