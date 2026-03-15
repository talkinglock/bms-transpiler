
local m = {}
local log = {}



function m.info(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[INFO] "..text.."\n")
    io.write(text.."\n")
end

function m.good(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[GOOD] " .. text .. "\n")
    io.write("\27[32m"..text.."\n\27[0m")
end

function m.bad(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[BAD] " .. text .. "\n")
    io.write("\27[31m"..text.."\n\27[0m")
end

function m.warn(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[WARN] " .. text .. "\n")
    io.write("\27[33m"..text.."\n\27[0m")
end

function m.fatal(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[FATAL] " .. text .. "\n")
    error("\27[31m".."[FATAL] " .. text.."\n\27[0m", 3)
end

function m.log(text)
    if type(text) ~= "string" then return end
    table.insert(log, "[INFO] "..text.."\n")
end



function m.table(tableVal)
    for _, obj in pairs(tableVal) do
        m.info(tostring(obj))
    end
end

function m.getLog()
    return table.concat(log)
end
return m
