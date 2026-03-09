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
local std = require("include.std.standard")
local G = require("include.GLOBALS")

local connections = require("include.connections")
local refabs = require("include.refabs")

local AttributeClass = require("include.classes.attribute")
local BlockClass = require("include.classes.block")
local RefabClass = require("include.classes.RefabClass")


TRANSPILER_PASSES = 2

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
    ---@return table<nil, BlockClass>|BlockClass|nil Block classes to add after transpilation to next pass
    local function transpileEntity(block)
        -- is the entity a source entity?
        if pass == 1 then
            --print(#incompats)
            local class = block:GetAttributes("classname")[1].value
            if not (string.find(sourceNames, G.SOURCETEXT_DELIMITER .. class, 1, true)) then
                local found = false
                for _, val in pairs(incompats) do
                    if val == class then
                        found = true
                    end
                end
                if found == false then
                    table.insert(incompats, class)
                end
                -- try to save the block by looking for a refab
                local refabToAdd = refabs.transpile(block)
                if not refabToAdd then
                    return nil -- the block is genuinely unsavable
                end
                
                return refabToAdd:GetAllOutputEntityBlocks()
            else
                ---@type Attribute
                local targetName = block:GetAttributes("targetname")[1]
                if targetName then
                    table.insert(allTargetNames, targetName.value)
                    return block
                end
            end
        elseif pass == 2 then
            local obj = block:GetBlocks("connections")[1]
            if obj then
                local newBlock = connections.transpile(block, allTargetNames)
                if newBlock then
                    return block
                end
            end
            return block
        end
        return block
    end

    
    for pass_i = 1, TRANSPILER_PASSES do
        pass = pass_i
        local newList = {}
        for _, block in pairs(vmfTable) do
            ---@cast block BlockClass
            local class = block:GetClassname()
            local uniqueID = block:GetUniqueId()
            if class == "world" then
                ---@type Attribute|nil
                local comment = block:GetAttributes("comment") and block:GetAttributes("comment")[1] or nil
                if comment then
                    comment.value = table.concat({
                        comment.value,
                        " and transpiled using Black Mesa Source Transpiler by talkinglock!"
                    })
                end
            end
            if class ~= "entity" then
                table.insert(newList, block)
                goto continue
            end
            
            ---@type table<nil, BlockClass>|nil
            local toBeAdded = transpileEntity(block)
            if toBeAdded then
                if toBeAdded['meta'] then
                    table.insert(newList, toBeAdded)
                else
                    for _, blockToPass in pairs(toBeAdded) do
                        if tostring(blockToPass) ~= "BlockClass" then
                            print("ERR!")
                        end
                        table.insert(newList, blockToPass)
                    end
                end
            end
            ::continue::
        end
        vmfTable = newList
    end
    return vmfTable, incompats
end

return trans;
