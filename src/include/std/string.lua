local str = {}

local out = require("include.output")

function str.split(inputStr, sep)
    local stringTable = {}
    local lastIndex = 1
    local currentIndex = 1
    while true do
        currentIndex = string.find(inputStr, sep, lastIndex, true)
        local toAdd
        if not currentIndex then
            toAdd = string.sub(inputStr, lastIndex)
            table.insert(stringTable, toAdd)
            break
        else
            toAdd = string.sub(inputStr, lastIndex, currentIndex - 1)
            table.insert(stringTable, toAdd)
        end
        
        lastIndex = currentIndex + 1
    end
    return stringTable
end


---@param stringParam string|table String/table to add whitespace to. Table will be concat!
---@param ammount number Amount of whitespace to add
---@return string
function str.addWhitespace(stringParam, ammount)
    local strTable = {}
    for _ = 1,ammount do
        table.insert(strTable, '\t')
    end
    local whitespace = table.concat(strTable)
    if type(stringParam) == "string" then
        return table.concat({whitespace, stringParam})
    else
        local workingTable = {whitespace}
        for i, v in pairs(stringParam) do
            workingTable[i+1] = v
        end
        return table.concat(workingTable)
    end
    
end


return str