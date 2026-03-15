
local attClass = require("include.classes.attribute")
local out = require("include.output")

---@class BlockClass
local BlockClass = {
    xenExclusive = false
}

BlockClass.__tostring = 
function (v)
    return "BlockClass"
end


BlockClass.__index = BlockClass


function BlockClass.new(parentBlock, classname, uniqueid)
    local self = setmetatable({}, BlockClass)
    self['meta'] = {
        ['parent'] = parentBlock,
        ['classname'] = classname,
        ['id'] = uniqueid
    }
    self['blocks'] = {}
    self['attributes'] = {}
    return self
end

---@param newBlock BlockClass
---@return nil
function BlockClass:Replace(newBlock)
    self['meta'] = newBlock['meta']
    self['blocks'] = newBlock['blocks']
    self['attributes'] = newBlock['attributes']
end

---@param attributeTable table Sets block list to table of attributes, without preserving the old attributes
function BlockClass:SetAttributesToTable(attributeTable)
    self['attributes'] = attributeTable
end

function BlockClass:GetAttributesOrBlocks(name)
    if self['attribute'] then
        local atts = self:GetAttributes(name)
        if atts then
            return atts
        end
    end
    if self['blocks'] then
        local blocks = self:GetAttributes(name)
        if blocks then
            return blocks
        end
    end
    return nil
end

-- Gets attributes from attribute name.
function BlockClass:GetAttributes(attributeName)
    if not self['attributes'] then
        out.warn("Attempt to get attribute " .. attributeName .. " in empty block!")
    end
    local atts = {}
    for _, attribute in pairs(self['attributes']) do
        if attribute.attribute == attributeName then
            table.insert(atts, attribute)
        end
    end
    return atts
end

function BlockClass:GetClassname()
    return self['meta']['classname']
end

function BlockClass:GetParent()
    return self['meta']['parent']
end

function BlockClass:GetUniqueId()
    return self['meta']['id']
end

-- Gets blocks from blocks classname.
function BlockClass:GetBlocks(blockName)
    if not self['blocks'] then
        out.warn("Attempt to get block " .. blockName .. " in empty block!")
    end
    local blocks = {}
    for _, block in pairs(self['blocks']) do
        ---@cast block BlockClass
        if block:GetClassname() == blockName then
            table.insert(blocks, block)
        end
    end
    return blocks
end

-- Adds block to another block. Both blocks must be initialized! (BlockClass.new())
-- Will set parent of parameter block to this block
---@param block BlockClass Block to add
---@param exclusive? boolean Makes block the only one of its name allowed, removes others of same name 
function BlockClass:AddBlock(block, exclusive)
    if exclusive then
        self:RemoveBlocks(block:GetClassname())
    end
    if not self['blocks'] then
        self['blocks'] = {}
    end     
    block.parent = self
    table.insert(self['blocks'], block)
end

-- Adds block to another attribute. Attributes must be initialized!
---@param attribute Attribute to add
---@param exclusive? boolean Makes attribute the only one of its name allowed, removes others of same name 
function BlockClass:AddAttribute(attribute, exclusive)
    if exclusive then
        self:RemoveAttributes(attribute.attribute)
    end
    if not self['attributes'] then
        self['attributes'] = {}  
    end
    table.insert(self['attributes'], attribute)
end

--- Removes all attributes with this name
function BlockClass:RemoveAttributes(attributeName)
    local atts = self:GetAllAttributes()
    if atts then
        for ind, att in pairs(atts) do
            ---@cast att Attribute
            if att.attribute == attributeName then
                self['attributes'][ind] = nil
                --print(att.attribute)
            end
        end
    end
end

--- Removes all blocks with this name
function BlockClass:RemoveBlocks(blockName)
    local matchingBlocks = self:GetBlocks(blockName)
    if matchingBlocks then
        for _, block in pairs(matchingBlocks) do
            ---@cast block BlockClass
            block:Destroy()
        end
    end
end

function BlockClass:GetAllAttributes()
    return self['attributes']
end

function BlockClass:GetAllBlocks()
    return self['blocks']
end

---@param id number
function BlockClass:SetUniqueId(id)
    self['meta']['id'] = id
end

-- Wipes instance from reality
function BlockClass:Destroy()
    self = nil
end 

return BlockClass