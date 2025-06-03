local function globalobjsearch(node, obj, looptables)
    local looptables = looptables or {}
    looptables[debug.getinfo(1, "f").func] = true
    local counter = 0
    local check_object
    local function iterate_table(tbl)
        local minout
        local minoutlen = math.maxinteger

        for k, v in pairs(tbl) do
            local out = check_object(k)
            if out then
                table.insert(out, "in key: " .. tostring(k))
                local outlen = #out
                if outlen < minoutlen then
                    minout = out
                end
            end

            local out = check_object(v)
            if out then
                table.insert(out, "in value with key: " .. tostring(k))
                local outlen = #out
                if outlen < minoutlen then
                    minout = out
                end
            end
        end

        return minout
    end

    ---@return table?
    check_object = function(iterobj)
        if iterobj == obj then return {} end
        if looptables[iterobj] then return end
        looptables[iterobj] = true
        local minout
        local minoutlen = math.maxinteger
        local kt = type(iterobj)
        if kt == "table" then
            local out = iterate_table(iterobj)
            if out then
                local outlen = #out
                if outlen < minoutlen then
                    minout = out
                end
            end
        elseif kt == "function" then
            local di = debug.getinfo(iterobj, "unS")
            for i = 1, di.nups do
                local upname, upvalue = debug.getupvalue(iterobj, i)
                if upvalue ~= nil then
                    local out = check_object(upvalue)
                    if out then
                        table.insert(out, "in upvalue '" .. upname .. "' with "..di.short_src..":"..di.linedefined)
                        local outlen = #out
                        if outlen < minoutlen then
                            minout = out
                        end
                    end
                end
            end
        elseif kt == "thread" then
            local deepcount = 1
            repeat
                local di = debug.getinfo(iterobj, deepcount, "f")
                if di and di.func then
                    local out = check_object(di.func)
                    if out then
                        table.insert(out, "in thread")
                        local outlen = #out
                        if outlen < minoutlen then
                            minout = out
                        end
                    end
                end
                deepcount = deepcount + 1
            until not di
        elseif kt == "userdata" then
            local n = 1
            repeat
                local value, isvalue = debug.getuservalue(iterobj, n)
                if value ~= nil then
                    local out = check_object(value)
                    if out then
                        table.insert(out, "in uvalue " .. n)
                        local outlen = #out
                        if outlen < minoutlen then
                            minout = out
                        end
                    end
                end
                n = n + 1
            until not isvalue
        end

        local mt = debug.getmetatable(iterobj)
        if mt then
            local out = check_object(mt)
            if out then
                table.insert(out, "in metatable")
                local outlen = #out
                if outlen < minoutlen then
                    minout = out
                end
            end
        end

        
        counter = counter + 1
        return minout
    end

    looptables[check_object] = true

    local out = iterate_table(node)
    if out then
        table.insert(out, "in start node")
        print(table.concat(out, "\n"))
    end
    print("Checked:", counter, "places")
end

return globalobjsearch
--globalobjsearch(debug.getregistry(), link)