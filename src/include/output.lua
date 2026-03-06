
local m = {}
local log = {}
function m.info(text)
    table.insert(log, "[INFO] "..text.."\n")
    io.write(text.."\n")
end

function m.good(text)
    table.insert(log, "[GOOD] " .. text .. "\n")
    io.write("\27[32m"..text.."\n\27[0m")
end

function m.bad(text)
    table.insert(log, "[BAD] " .. text .. "\n")
    io.write("\27[31m"..text.."\n\27[0m")
end

function m.warn(text)
    table.insert(log, "[WARN] " .. text .. "\n")
    io.write("\27[33m"..text.."\n\27[0m")
end
function m.log(text)
    table.insert(log, "[INFO] "..text.."\n")
end

function m.table(tableVal, indent)
    indent = indent or "" -- Default to empty string if not provided

    for key, value in pairs(tableVal) do
        if type(value) == "table" then
            m.log(indent .. key .. " = {")
            -- Increase indentation for the next level
            m.table(value, indent .. "  ") 
            m.log(indent .. "}")
        else
            if not (type(value) == "string") then
                value = "not string"
            end
            m.log(indent .. key .. " = " .. tostring(value))
        end
    end
end

function m.getLog()
    return table.concat(log)
end
return m
