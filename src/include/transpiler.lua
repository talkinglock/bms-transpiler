--[[

#### BLACK MESA SOURCE TRANSPILER! ####

This is the heart and soul of the whole operation,
This script handles the process of sorting blocks based off of their compatibility with the Source engine, and then figuring out what to do with them.
This script isn't so much a single "machine" but more bunch of smaller machines connected, this script mainly just orchestrates the operation, where other
More purposeful modules handle the specifics.

#######################################

]]
local vmfparse = require("include.vmfparse")
local out = require("include.output")
local connections = require("include.connections")

local AttributeClass = require("include.classes.attribute")
local BlockClass = require("include.classes.block")

TRANSPILER_PASSES = 3

local trans = {}


function trans.transpile(vmfTable)
    local incompats = {}
    local allTargetNames = {}
    local pass = 0
    local sourceNamesFile = io.open("resources/lists/SourceClassnames.txt")
    if not sourceNamesFile then
        out.bad("Cannot continue transpiler. SourceClassnames.txt not found in resources/lists")
        return
    end
    local sourceNames = sourceNamesFile:read("a")

    -- go through all entities in the vmfTable
    ---@param block BlockClass
    local function transpileEntity(block)
        -- is the entity a source entity?
        if pass == 1 then
            --print("doing")
            local class = block:GetAttributes("classname")[1].value
            if not (string.find(sourceNames, class, 1, true)) then
                local found = false
                for _, val in pairs(incompats) do
                    if val == class then
                        found = true
                    end
                end
                if found == false then
                    table.insert(incompats, class)
                end
                return nil
            else
                ---@type Attribute
                local targetName = block:GetAttributes("targetname")[1]
                if targetName then
                    table.insert(allTargetNames, targetName.value)
                end
            end
        elseif pass == 2 then
            local obj = block:GetBlocks("connections")
            if obj then
                local newBlock = connections.transpile(block, allTargetNames)
                return block
            end
        end
        return block
    end

    
    for pass_i = 1, TRANSPILER_PASSES do
        pass = pass_i
        for ind, block in pairs(vmfTable) do
            ---@cast block BlockClass
            local class = block:GetClassname()
            local uniqueID = block:GetUniqueId()
            if class == "world" then
                ---@type Attribute|nil
                local comment = block:GetAttributes("comment") and block:GetAttributes("comment")[0] or nil
                if comment then
                    comment.value = table.concat({
                        comment.value,
                        " and transpiled using Black Mesa Source Transpiler by talkinglock!"
                    })
                end
            end
            if class ~= "entity" then
                goto continue
            end

            local toBeAdded = transpileEntity(block)
            if toBeAdded then
                vmfTable[uniqueID] = toBeAdded
            else
                vmfTable[uniqueID] = nil
            end

            ::continue::
        end
    end
    return vmfTable, incompats
end

return trans;
