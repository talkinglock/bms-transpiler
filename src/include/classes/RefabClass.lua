--[[
Contains information for the transpiler to add refabs to the vmfTable,
such as connection mappings etc
]]

local RefabType = require("include.enums.RefabType")
local AttType = require("include.classes.attribute")

local BlockClass = require("include.classes.block")

local Vector3 = require("include.classes.vector3")

local connections = require("include.connections")
local out = require("include.output")

---@class RefabClass
local RefabClass = {
    xenBlock = nil,
    refabType = nil,
    inBlock = nil,
    deleteOriginalConnections = false,
    outBlocks = {},
    inConnections = {},
    outConnections = {}
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
    elseif self.refabType == RefabType.FABBED then
        return self:InitializeFabbed()
    end
end

-- returns a list of connector classes for targetname or nil if not found 
---@param targetName string
---@return table<nil, Connector>|nil
function RefabClass:GetConnectorListFromTargetName(targetName)
    local entities = self:GetAllOutputEntityBlocks()
    local returnList = {}
    for _, entity in pairs(entities) do
        local connectorBlock = entity:GetBlocks("connector")[1]
        if not connectorBlock then goto continue end
        local connectors = connections.deparseConnections(connectorBlock:GetAllAttributes())
        for _, connector in pairs(connectors) do
           ---@cast connector Connector
           if connector.targetName == targetName then
                table.insert(returnList, connector)
           end 
        end
        ::continue::
    end
    return returnList
end

-- The *real* refab, allowing for complex replacements.
---@return RefabClass|nil
function RefabClass:InitializeFabbed()
    ---@type BlockClass
    local xenBlock = self.xenBlock
    local name = xenBlock:GetAttributes("replacename")[1].value
    for _, block in pairs(xenBlock) do
        ---@cast block BlockClass
        local classname = block:GetClassname()
        ---@type Attribute
        local targetname = block:GetAttributes("targetname")[1]
        ---@type BlockClass
        local connections = block:GetBlocks("connections")[1]
        if targetname then
            targetname.value = targetname.value .. "_" .. name
        end
        if classname == "entity" then
            out.info("Added entity block to " .. name.value)
            self:AddEntityBlock(block)
        end
        if connections then
            self.deleteOriginalConnections = true
        end
    end
    return self
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
        for _, att in pairs(overrideBlock:GetAllAttributes()) do
            ---@cast att Attribute
           entityBlock:AddAttribute(att, true)
        end
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

