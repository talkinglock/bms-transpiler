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


local trans = {}


function trans.transpile(vmfTable)
    local postTranspileTable = {}
    local incompats = {}
    local sourceNamesFile = io.open("resources/lists/SourceClassnames.txt")
    if not sourceNamesFile then
        out.bad("Cannot continue transpiler. SourceClassnames.txt not found in resources/lists")
        return
    end
    local sourceNames = sourceNamesFile:read("a")

    -- go through all entities in the vmfTable 
    local function transpileEntity(block, metadata, class, uniqueName)
        -- is the entity a source entity?
        if not (string.find(sourceNames, block["classname"], 1, true)) then
            local found = false
            for _, val in pairs(incompats) do
                if val == block['classname'] then
                    found = true
                end
            end
            if found == false then
                table.insert(incompats, block['classname'])
            end
            return nil
        end
        
        -- any checks and modification on the entity go here 
        local obj, unqid = vmfparse.attributeOrTable("connections", block)
        if unqid then
           block[unqid] = nil 
        end
        
        return block
    end

    for _, block in pairs(vmfTable) do
        local metadata = block['vmf_parser_metadata']
        local class = metadata['vmf_parser_blockname']
        local uniqueName = metadata['vmf_parser_uniquename']

        if class == "world" then
            if block['comment'] then
                block['comment'] = table.concat({
                    block['comment'],
                    " and transpiled using Black Mesa Source Transpiler by talkinglock!"
                })
            end
        end
        if class ~= "entity" then
            table.insert(postTranspileTable, block)
            goto continue
        end

        local toBeAdded = transpileEntity(block, metadata, class, uniqueName)
        if not (toBeAdded == nil) then
            table.insert(postTranspileTable, toBeAdded)
        end
        ::continue::
    end
    return postTranspileTable, incompats
end


return trans;