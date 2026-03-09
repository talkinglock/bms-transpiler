--[[
Contains information for the transpiler to add refabs to the vmfTable,
such as connection mappings etc
]]

local RefabType = require("include.enums.RefabType")
local AttType = require("include.classes.attribute")

local out = require("include.output")

---@class RefabClass
local RefabClass = {
    xenBlock = nil,
    refabType = nil,
    inBlock = nil,
    outBlocks = {}
}
RefabClass.__index = RefabClass

RefabClass.__tostring = 
function (v)
    return "RefabClass"
end


---@param xenBlock BlockClass Constructor, xenBlock from corresponding file
---@param type RefabType Type of refab (DIRECT, FABBED)
---@param entityBlock BlockClass Original class to refabricate
function RefabClass.new(xenBlock, type, entityBlock)
    local self = setmetatable({}, RefabClass)
    ---@type BlockClass
    self.xenBlock = xenBlock
    self.inBlock = entityBlock
    self.outBlocks = {}
    ---@type RefabType
    self.refabType = type
    return self
end

---@return table<nil, BlockClass> All classes to create to match prefab
function RefabClass:GetAllOutputEntityBlocks()
    return self.outBlocks
end

---@return RefabClass|nil
function RefabClass:Initialize()
    if self.refabType == RefabType.DIRECT then
        return self:InitializeDirect()
    end
end

---@return RefabClass|nil
function RefabClass:InitializeDirect()
    ---@type BlockClass
    local xenBlock = self.xenBlock
    ---@type BlockClass
    local entityBlock = self.inBlock
    ---@type BlockClass
    local directBlock = xenBlock:GetBlocks("direct")[1]
    ---@type BlockClass
    local overrideBlock = xenBlock:GetBlocks("override")[1]

    if not directBlock then out.warn("Direct block not found") return nil end
    
    local originalName = entityBlock:GetAttributes("classname")[1]
   
    for _, attribute in pairs(directBlock:GetAllAttributes()) do
        ---@cast attribute Attribute
        if attribute.attribute == "name" then
            local newAttribute = AttType.new("classname", attribute.value)
            entityBlock:AddAttribute(newAttribute, true)
        end
    end
    if overrideBlock then
        --TODO
    end

    self:AddEntityBlock(entityBlock)
    out.good("Refab parsed [".. originalName.value .."] -> [".. entityBlock:GetAttributes("classname")[1].value .."]")
    return self
end

---@param entityBlock BlockClass Adds entity block to list of blocks to add
function RefabClass:AddEntityBlock(entityBlock)
    table.insert(self.outBlocks, entityBlock)
end


return RefabClass

