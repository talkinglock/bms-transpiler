---@class Attribute
---@field value string
---@field attribute string
local Attribute = {}
Attribute.__index = Attribute
Attribute.__tostring = 
function (v)
    return "Attribute"
end

function Attribute.new(attribute, value)
    local self = setmetatable({}, Attribute)
    self.value = value
    self.attribute = attribute
    return self
end



return Attribute