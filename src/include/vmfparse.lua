--[[
    At the beginning of transpiling the file must be converted to a table from a string,
    and vis versa and the end.

]]

DISTANCE_BETWEEN_ATTRIBUTE_END_AND_VALUE_BEGIN = 3

local out = require("include.output")

local vmfp = {}

function vmfp.parseFromFile(file)
    local vmfTable = {}
    local colonCount = 0
    local lastColonCount = 0
    local depth = 0
    local currentID = 0 -- seperate from vmf ids, just to avoid overriding anything. Anythig sensitive should reference the vmf_parser_blockname attribute
    local currentBlock = {} -- Effectively a "pointer" to the current block being used.
    local blockList = {} -- Temporary storage for all blocks

    local lastLine = ""

    local startTime = os.clock()

    local function analyseLine(line)
        currentID = currentID + 1
        if string.find(line, "{", 1, true) then
            colonCount = colonCount + 1
        end
        if string.find(line, "}", 1, true) then
            colonCount = colonCount - 1
        end
        if colonCount > lastColonCount then
            -- in every case, the line before exclusively contains the name of the block.
            -- Migrate forward in depth, add a new dictionary to our last dictionary 

            local className = lastLine
            local uniqueName = table.concat({lastLine, "_", tostring(currentID)})
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
        elseif colonCount < lastColonCount then
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
                local attEnd = string.find(line, [["]], attStart+1, true)
                local valStart = attEnd + DISTANCE_BETWEEN_ATTRIBUTE_END_AND_VALUE_BEGIN -- fixed
                local valEnd = string.find(line, [["]], valStart, true)

                local attribute = string.sub(line, attStart+1, attEnd-1)
                local value = string.sub(line, valStart, valEnd-1)
                currentBlock[attribute] = value
            end
        end
        lastLine = line
        lastColonCount = colonCount
    end

    local lineCount = 0
    for line in file:lines() do
        lineCount = lineCount + 1
        analyseLine(line)
    end
    return vmfTable, lineCount, (os.clock() - startTime)
end

return vmfp