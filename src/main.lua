--[[
    The program entrance
]]--
local out = require("include.output")
local vmfparse = require("include.vmfparse")
local transpiler = require("include.transpiler")

function Main()

    out.info("################")
    out.info("BMSS TRANSPILER")
    out.info("################")
    io.write('\n')

    local validPath = false
    local xenMapPath
    local xenMap
    
    repeat
        out.good("Path to Black Mesa map: ")
        xenMapPath = "../" .. io.read()
        xenMap = io.open(xenMapPath)
        if xenMap then
            validPath = true
        else
            out.warn("\nPath invalid!")
        end
    until validPath == true
    local xenMapFileName = xenMapPath:match("[^/\\]+$")

    out.info("Parsing .vmf into table...")
    local parsedXenMap, linesParsed, timeTaken = vmfparse.parseFromFile(xenMap)
    out.good("Parsing completed! Parsing took " .. timeTaken .. " seconds, parsed " .. linesParsed .. " lines and recorded " .. #parsedXenMap .. " entities.")
    
    out.info("Transpiling...")
    local transpiledTable, incompats = transpiler.transpile(parsedXenMap)
    out.good("Transpiling completed! " .. #transpiledTable .. " entities transpiled, and there were " .. #incompats .. " incompatible *types* (not entities).")

    out.info("Reverse parsing...")
    local finalString = vmfparse.tableToString(transpiledTable)
    out.good("Reverse parse completed!")


    local output = io.open("../output/".. xenMapFileName, "w")
    output:write(finalString)
    local log = io.open("../output/" .. xenMapFileName .. ".log", "w")
    log:write(out.getLog())
    out.info("These were the incompatible types: ")

    out.table(incompats)

    out.good(".VMF written to '/output'! Have a very SAFE day :)")
    os.execute("pause")
    
end

Main()