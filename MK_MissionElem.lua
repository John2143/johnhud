local tableA = managers.mission:script("default")
local file = io.open("fwb.txt", "w")
file:close()
local file = io.open("fwb.txt", "a+")
file:write("Mission : ".."\n")
file:write("[default]\n\t")
for k, v in pairs (tableA) do
    local val = tostring(k) 
    if tostring(v):sub(1,5) == 'table' then
        file:write("["..tostring(k).."]".."\n")
    else
        file:write("["..tostring(k).."]")
        file:write(" = ")
        file:write(tostring(v))
        file:write("\n")
    end
    if val:sub(1,9) == '_elements' and val:sub(1,15) ~= '_element_groups' then
        for k1, v1 in pairs (v) do
            local val1 = tostring(k1)
            if tostring(v1):sub(1,5) == 'table' then
                file:write("\t\t".."["..tostring(k1).."]".."\n")
            else
                file:write("\t\t")
                file:write("["..tostring(k1).."]")
                file:write(" = ")
                file:write(tostring(v1))
                file:write("\n")
            end
            if val1 ~= 'nil' then
                for k2, v2 in pairs (v1) do
                    local val2 = tostring(k2)
                    if tostring(v2):sub(1,5) == 'table' then
                        file:write("\t\t\t".."["..tostring(k2).."]".."\n")
                    else
                        file:write("\t\t\t")
                        file:write("["..tostring(k2).."]")
                        file:write(" = ")
                        file:write(tostring(v2))
                        file:write("\n")
                    end
                    if val2:sub(1,6) == '_value' then
                        for k3, v3 in pairs (v2) do
                            local val3 = tostring(k3)
                            if tostring(v3):sub(1,5) == 'table' then
                                file:write("\t\t\t\t".."["..tostring(k3).."]".."\n")
                            else
                                file:write("\t\t\t\t")
                                file:write("["..tostring(k3).."]")
                                file:write(" = ")
                                file:write(tostring(v3))
                                file:write("\n")
                            end
                            if val3:sub(1,12) == 'trigger_list' or val3:sub(1,11) == 'on_executed' or val3:sub(1,8) == 'elements' then
                                if val3:sub(1,11) == 'on_executed' and tostring(managers.mission:script("default")._elements[k1]._values.on_executed[1]) == 'nil' then
                                    file:write("\t\t\t\t\tnil\n")
                                end
                                for k4, v4 in pairs (v3) do
                                    local val4 = tostring(v4)                                                
                                    if tostring(v4):sub(1,5) == 'table' then
                                        file:write("\t\t\t\t\t".."["..tostring(k4).."]".."\n")
                                    else
                                        file:write("\t\t\t\t\t")
                                        file:write("["..tostring(k4).."]")
                                        file:write(" = ")
                                        file:write(tostring(v4))
                                        file:write("\n")
                                    end
                                    if val4:sub(1,5) == 'table' then
                                        for k5, v5 in pairs (v4) do
                                            file:write("\t\t\t\t\t\t")
                                            file:write("["..tostring(k5).."]")
                                            file:write(" = ")
                                            file:write(tostring(v5))
                                            file:write("\n")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
file:close()