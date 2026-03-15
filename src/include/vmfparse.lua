--[[
    At the beginning of transpiling the file must be converted to a table from a string,
    and vis versa and the end.

]]

DISTANCE_BETWEEN_ATTRIBUTE_END_AND_VALUE_BEGIN = 3

local out = require("include.output")
local AttType = require("include.classes.attribute")
local BlockType = require("include.classes.block")
local std = require("include.std.standard")
local vmfp = {}

local function getWhitespace(depth)
    local strTable = { "" }
    for i = 1, depth do
        table.insert(strTable, "\t")
    end
    return table.concat(strTable)
end

function vmfp.tableToString(vmfTable)
    local tableForm = {}

    ---@param block BlockClass Block to search
    local function searchBlock(block, depth)
        local tableTemp = {}

        table.insert(tableTemp,
            std.string.addWhitespace(block:GetClassname() .. "\n", depth)
        )
        table.insert(tableTemp,
            std.string.addWhitespace("{\n", depth)
        )
        local name = block:GetClassname()
        local tableValues = {}
        local attributeValues = {}
        local counter = 0
        for _, attribute in pairs(block:GetAllAttributes()) do
            ---@cast attribute Attribute
            table.insert(attributeValues, std.string.addWhitespace({
                [["]],
                attribute.attribute,
                [["]],
                " ",
                [["]],
                attribute.value,
                [["]],
                '\n'
            }, depth + 1))
        end
        for _, metablock in pairs(block:GetAllBlocks()) do
            ---@cast metablock BlockClass
            local stringSearched, newDepth = searchBlock(metablock, depth + 1)
            --depth = newDepth
            table.insert(
                tableValues,

                table.concat(
                    stringSearched
                )
            )
        end

        table.insert(tableTemp, table.concat(attributeValues))
        table.insert(tableTemp, table.concat(tableValues))
        table.insert(tableTemp, std.string.addWhitespace("}\n", depth))

        return tableTemp, depth - 1
    end

    for _, block in pairs(vmfTable) do
        local finalBlock = searchBlock(block, 0)

        table.insert(tableForm, table.concat(finalBlock))
    end

    local final = table.concat(tableForm)
    return final
end

function vmfp.parseFromFile(file)
    local vmfTable = {}
    
    
    local braceCount = 0
    local lastBraceCount = 0
    local depth = 0
    local currentID = 0
    ---@type BlockClass|nil
    local currentBlock
    local blockList = {} -- Temporary storage for all blocks
    local lastLine = ""
    local startTime = os.clock()
    local function analyseLine(line)
        currentID = currentID + 1
        if string.find(line, "{", 1, true) then
            braceCount = braceCount + 1
        end
        if string.find(line, "}", 1, true) then
            braceCount = braceCount - 1
        end
        if braceCount > lastBraceCount then
            -- in every case, the line before exclusively contains the name of the block.
            -- Migrate forward in depth, add a new dictionary to our last dictionary

            local className = lastLine:gsub("%s+", "")
            if depth == 0 then
                currentBlock = BlockType.new(nil, className, -1)
            else
                currentBlock = BlockType.new(currentBlock, className, -1)
            end
            depth = depth + 1
        elseif braceCount < lastBraceCount then
            -- Move our currentBlock "pointer" one dictionary back in depth
            if not (depth == 1) then
                local parent = currentBlock:GetParent()
                --print(parent)
                parent:AddBlock(currentBlock)
                currentBlock = parent
            else
                -- we are the only entity, so just set currentBlock to {}
                currentBlock:SetUniqueId(#vmfTable + 1)
                table.insert(vmfTable, currentBlock)
                blockList = {}
                currentBlock:Destroy()
            end
            depth = depth - 1
        else
            -- We are not changing block scope
            local attStart = string.find(line, [["]], 1, true) -- end isnt important, its one character

            if attStart then
                -- there is a attribute value pair on this line. They go like this
                -- "attribute" "value"
                -- Thank you lord Gaben
                local attEnd = string.find(line, [["]], attStart + 1, true)
                local valStart = attEnd + DISTANCE_BETWEEN_ATTRIBUTE_END_AND_VALUE_BEGIN -- fixed
                local valEnd = string.find(line, [["]], valStart, true)

                local attribute = string.sub(line, attStart + 1, attEnd - 1)
                local value = string.sub(line, valStart, valEnd - 1)
                local AttClass = AttType.new(attribute, value)
                currentBlock:AddAttribute(AttClass)
            end
        end
        lastLine = line
        lastBraceCount = braceCount
    end
    local lineCount = 0
    for line in file:lines() do
        lineCount = lineCount + 1
        analyseLine(line)
    end
    return vmfTable, lineCount, (os.clock() - startTime)
end

return vmfp
