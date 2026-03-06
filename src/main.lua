--[[
    The heart and soul of the transpiler
]]
local out = require("include.output")
local vmfparse = require("include.vmfparse")

function Main()
    local validPath = false
    local xenMapPath
    local xenMap
    repeat
        out.info("Path to Black Mesa map (from current directory, or from bms-transpiler dir if your running batch script): ")
        xenMapPath = io.read()
        xenMap = io.open(xenMapPath)
        if xenMap then
            validPath = true
        else
            out.warn("\nPath invalid!")
        end
    until validPath == true
    

    out.info("Parsing .vmf into table...")
    local parsedXenMap, linesParsed, timeTaken = vmfparse.parseFromFile(xenMap)
    out.good("Parsing completed! Parsing took " .. timeTaken .. " seconds, parsed " .. linesParsed .. " lines and recorded " .. #parsedXenMap .. " entities.")
  
end

Main()