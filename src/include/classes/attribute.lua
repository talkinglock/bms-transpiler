---@class Attribute
---@field value string
---@field attribute string
local Attribute = {}
Attribute.__index = Attribute


function Attribute.new(attribute, value)
    local self = setmetatable({}, Attribute)
    self.value = value
    self.attribute = attribute
    return self
end

--- Wipes instance from reality
function Attribute:Destroy()
    self = nil
end

return Attribute