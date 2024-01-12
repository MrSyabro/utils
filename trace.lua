---@class traceinfo : debuginfo
---@field id number
---@field start number вспомогательная переменная
---@field callers table<number|"C", {calls:number, clock: number, maxclock: number, fullclock: number}> количество вызовов из каждой функции

local M = {}

local tbc, tbi = table.concat, table.insert
local dgi, dsh = debug.getinfo, debug.sethook
local sf = string.format
local oc = os.clock
local mmax = math.max

local funcs_count = 0
---@type table<function, traceinfo> таблица данных трассировки
local funcs_list = {}
M.funcs_list = funcs_list

local function serialize_traceinfo(traceinfo)
	local out = {"{"}
	for k, v in pairs(traceinfo) do
		if k == "callers" then
			tbi(out, "callers={")
			for fid, backtrace in pairs(v) do
				for key, value in pairs(backtrace) do
					tbi(out, sf("%s=%d,", key, value))
				end
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
			local sid = 'C'
			if secondti then
				local second_sti = funcs_list[secondti.func]
				if second_sti then
					sid = second_sti.id
				end
			end
			local backtrace = storedinfo.callers[sid]
			if not backtrace then
				backtrace = {
					maxclock = 0,
					fullclock = 0,
					calls = 1
				}
				storedinfo.callers[sid] = backtrace
			end
			local calls = backtrace.calls
			backtrace.calls = calls + 1
			storedinfo.start = oc()
		else
			traceinfo.source = nil
			traceinfo.lastlinedefined = nil
			traceinfo.callers = {}
			local sid = 'C'
			if secondti then
				local storedinfo = funcs_list[secondti.func]
				if storedinfo then
					sid = storedinfo.id
				end
			end
			traceinfo.callers[sid] = {
				clock = 0,
				maxclock = 0,
				fullclock = 0,
				calls = 1
			}

			funcs_count = funcs_count + 1
			traceinfo.id = funcs_count
			funcs_list[curr_func] = traceinfo
			traceinfo.start = oc()
		end
	elseif hook_type == "return" then
		local storedinfo = funcs_list[curr_func]
		if storedinfo then
			local clock = oc() - storedinfo.start
			local sid = 'C'
			if secondti then
				local second_sti = funcs_list[secondti.func]
				if second_sti then
					sid = second_sti.id
				end
			end
			local backtrace = storedinfo.callers[sid]
			if not backtrace then
				backtrace = {
					clock = 0,
					maxclock = 0,
					fullclock = 0,
					calls = 1
				}
				storedinfo.callers[sid] = backtrace
			end
			backtrace.maxclock = mmax(backtrace.maxclock, clock)
			backtrace.clock = clock
			backtrace.fullclock = backtrace.fullclock + clock
		end
	end
	return dsh(hook, "cr")
end

---Запускает трассировки всех вызовов
function M.start()
	dsh(hook, "cr")
end

---Останавливает трассировку
function M.stop()
	dsh()
end

---Возвращает сериализованную таблицу трассировки
---@return string
function M.dump()
	return serialize_funcs(funcs_list)
end

---Сбрасывает статистику трассировщика
function M.reset()
	funcs_list = {}
	M.funcs_list = funcs_list
	funcs_count = 0
end

return M
