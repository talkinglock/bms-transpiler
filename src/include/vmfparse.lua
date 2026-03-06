--[[
    At the beginning of transpiling the file must be converted to a table from a string,
    and vis versa and the end.

]]

DISTANCE_BETWEEN_ATTRIBUTE_END_AND_VALUE_BEGIN = 3

local out = require("include.output")

local vmfp = {}

local function getWhitespace(depth)
    local strTable = {""}
    for i = 1,depth do
        table.insert(strTable, "\t")
    end
    return table.concat(strTable)
end

function vmfp.attributeOrTable(stringname, block)
    if block['stringname'] then
        return block['stringname']
    end
    for _, obj in pairs(block) do
        local metadata = obj["vmf_parser_metadata"]
        if metadata then
            if metadata['vmf_parser_blockname'] == stringname then
                return obj, metadata['vmf_parser_uniquename']
            end
        end
    end
end


function vmfp.tableToString(vmfTable)
    local tableForm = {}
    local depth = 0
    local function searchTables(block)
        local tableTemp = {}
        local lowerWhitespace = getWhitespace(depth)
        local whitespace = table.concat({lowerWhitespace, "\t"})
        table.insert(tableTemp, table.concat({"", block['vmf_parser_metadata']['vmf_parser_blockname']}))

        table.insert(tableTemp, table.concat({'\n', lowerWhitespace, "{\n"}))
        block['vmf_parser_metadata'] = nil

        local tableValues = {}
        local attributeValues = {}

        for att, value in pairs(block) do
            if type(value) == "table" then
                table.insert(tableValues, whitespace)
                depth = depth + 1
                table.insert(tableValues, table.concat(searchTables(value)))
            else
                --print(att, value)
                table.insert(attributeValues, table.concat({
                    whitespace,
                    [["]],
                    att,
                    [["]],
                    " ",
                    [["]],
                    value,
                    [["]],
                    '\n'
                }))
            end
        end
        table.insert(tableTemp, table.concat(attributeValues))
        table.insert(tableTemp, table.concat(tableValues))
        table.insert(tableTemp, lowerWhitespace)
        table.insert(tableTemp, "}\n")
        if (depth > 0) then
            depth = depth - 1
        end 
        
        return tableTemp
    end
    for key, block in pairs(vmfTable) do
        local metadata = block["vmf_parser_metadata"]
        local class = block["vmf_parser_blockname"]
        local parent = block["vmf_parser_parent"]
        local uniqueName = block["vmf_parser_uniquename"]

        table.insert(tableForm, table.concat(searchTables(block)))
    end
    local final = table.concat(tableForm)
    return final
end

function vmfp.parseFromFile(file)
    local vmfTable = {}
    local braceCount = 0
    local lastBraceCount = 0
    local depth = 0
    local currentID = 0     -- seperate from vmf ids, just to avoid overriding anything. Anythig sensitive should reference the vmf_parser_blockname attribute
    local currentBlock = {} -- Effectively a "pointer" to the current block being used.
    local blockList = {}    -- Temporary storage for all blocks

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

            local firstNonWhiteSpace = 0
            for index = 1,#lastLine do
                local char = string.byte(lastLine, index)
                if char ~= 32 and char ~= 9 and char ~= 10 and char ~= 13 then
                    firstNonWhiteSpace = index
                    goto finished
                end
            end
            ::finished::
            local className = string.sub(lastLine, firstNonWhiteSpace, #lastLine)
            local uniqueName = table.concat({ lastLine, "_", tostring(currentID) })
            local metadata = {
                ['vmf_parser_parent'] = currentBlock,
                ['vmf_parser_blockname'] = className,
                ['vmf_parser_uniquename'] = uniqueName
            }
            -- metadata is stored for the parser to know stuff like the parent of the block

            local baseTable = {
                ['vmf_parser_metadata'] = metadata,
            }
            if #blockList == 0 then
                blockList[uniqueName] = baseTable
                currentBlock = blockList[uniqueName]
            else
                currentBlock[uniqueName] = baseTable
                currentBlock = currentBlock[uniqueName]
            end
            depth = depth + 1
        elseif braceCount < lastBraceCount then
            -- Move our currentBlock "pointer" one dictionary back in depth
            local metadata = currentBlock['vmf_parser_metadata']
            local className = metadata['vmf_parser_blockname']
            local uniqueName = metadata['vmf_parser_uniquename']
            if not (depth == 1) then
                local parent = metadata['vmf_parser_parent']
                parent[uniqueName] = currentBlock
                currentBlock = parent
            else
                -- we are the only entity, so just set currentBlock to {}

                table.insert(vmfTable, currentBlock)
                blockList = {}
                currentBlock = {} -- "unpointerizes" currentBlock
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
                currentBlock[attribute] = value
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
