--[[
Parsing the refab block unfortunately requires a lot of if-and-else's
so making it its own module for organization
]]

local std = require("include.std.standard")
local out = require("include.output")
local G = require("include.GLOBALS")

local AttClass = require("include.classes.attribute")
local BlockClass = require("include.classes.block")

local refabparser = {}

---@enum RefabEnum
local RefabEnum = {
    REPLACE = 0
}


---@param att Attribute
---@param block BlockClass
function refabparser.AttParser(att, block)
    local parsedValue = std.string.split(att.value, G.REFAB_PARSER_DELIMITER)
   
    if #parsedValue == 1 then
        return att
    end

    for _, subValue in pairs(parsedValue) do
        if subValue == "ORIGIN" then
            if not block:GetAttributes("origin") then 
                out.warn("origin called but no matching argument. Ignoring")
                goto continue 
            end
            att.value = block:GetAttributes("origin")[1].value
        end
        ::continue::
    end
end

---@param att Attribute
---@return Attribute updated attribute
function refabparser.ParseEntityAttribute(att)
    
end

---@param block BlockClass
function refabparser.ParseConBlock(block)
    if block:GetClassname() == "replace" then
        local replaceSignal = block:GetAttributes("replacesignal")[1].value
        local replacerAtt = block:GetAllAttributes()[2]
        ---@cast replacerAtt Attribute
        if not replaceSignal then
            out.fatal("Replace called without replace signal!")
        end
        if not replacerAtt then
            out.fatal("Replace called without replace attribute!")
        end
        
    end
end

---@param block BlockClass
---@return BlockClass updated block
function refabparser.ParseEntitySubblock(block)
    if block:GetClassname() == "inconnections" then
        for _, block in pairs(block:GetAllBlocks()) do
            refabparser.ParseConBlock(block)
        end
    end
end

---@param block BlockClass
---@return BlockClass updated block
function refabparser.ParseBlock(block)
    local blockType = block:GetClassname()
    for _, att in pairs(block:GetAllAttributes()) do
        ---@cast att Attribute
        local newAtt = refabparser.ParseEntityAttribute(att)
        att:Replace(newAtt)
    end
    for _, block in pairs(block:GetAllBlocks()) do
        ---@cast block BlockClass
        local newBlock = refabparser.ParseEntitySubblock(block)
        block:Replace(newBlock)
    end
    return block
end

return refabparser