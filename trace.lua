---@class traceinfo : debuginfo
---@field id number
---@field callcount number количество вызовов
---@field start number вспомогательная переменная
---@field clock number время работы функции
---@field full_clock number полное время работы за все вызовы
---@field callers number[] количество вызовов из каждой функции

local M = {}

local tbc, tbi = table.concat, table.insert
local dgi, dsh = debug.getinfo, debug.sethook
local sf = string.format
local oc = os.clock

local funcs_count = 0
---@type table<function, traceinfo> таблица данных трассировки
local funcs_list = {}
M.funcs_list = funcs_list

local function serialize_traceinfo(traceinfo)
	local out = {"{"}
	for k, v in pairs(traceinfo) do
		if k == "callers" then
			tbi(out, "callers={")
			for fid, count in pairs(v) do
				tbi(out, sf("[%d]=%d,", fid, count))
			end
			tbi(out, "},")
		elseif k ~= "func" and k ~= "start" then
			tbi(out, sf("[%q]=%q,", k, v))
		end
	end
	tbi(out,"}")
	return tbc(out)
end

local function serialize_funcs(funcs)
	local out = {"{"}
	for _, traceinfo in pairs(funcs) do
		tbi(out, sf("[%d]=%s,", traceinfo.id, serialize_traceinfo(traceinfo)))
	end
	tbi(out, "}")
	return tbc(out)
end

local function hook(hook_type)
	dsh()
	local traceinfo = dgi(2,"nStuf") --[[@as traceinfo]]
	local curr_func = traceinfo.func
	local secondti = dgi(3, "f")
	if hook_type == "call" then
		local storedinfo = funcs_list[curr_func]
		if storedinfo then
			storedinfo.start = oc()
			if secondti then
				local second_sti = funcs_list[secondti.func]
				if second_sti then
					local sid = second_sti.id
					local calls = storedinfo.callers[sid] or 0
					storedinfo.callers[sid] = calls + 1
				end
			end
		elseif traceinfo.short_src ~= "[C]" then
			traceinfo.start = oc()
			traceinfo.full_clock = 0
			traceinfo.source = nil
			traceinfo.lastlinedefined = nil
			traceinfo.callers = {}
			if secondti then
				local ti2 = funcs_list[secondti.func]
				if ti2 then
					traceinfo.callers[ti2.id] = 1
				end
			end
			funcs_count = funcs_count + 1
			traceinfo.id = funcs_count
			funcs_list[curr_func] = traceinfo
		end
	elseif hook_type == "return" then
		local storedinfo = funcs_list[curr_func]
		if storedinfo then
			storedinfo.clock = oc() - storedinfo.start
			storedinfo.full_clock = storedinfo.full_clock + storedinfo.clock
		end
	end
	return dsh(hook, "cr")
end

---Запускает трассировки всех вызовов
---@return unknown
function M.start()
	return dsh(hook, "cr")
end

---Останавливает трассировку
function M.stop()
	return dsh()
end

---Возвращает сериализованную таблицу трассировки
---@return string
function M.dump()
	return serialize_funcs(funcs_list)
end

return M
