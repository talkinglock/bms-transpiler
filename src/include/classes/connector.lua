---@class Connector
local Connector = {}
Connector.__index = Connector


function Connector.new(
        inEvent,
        targetName,
        outEvent,
        parameterOverride,
        delay,
        fireOnce,
        seperator
    )
    local self = setmetatable({}, Connector)
    self.inEvent = inEvent
    self.targetName = targetName
    self.outEvent = outEvent
    self.parameterOverride = parameterOverride
    self.delay = delay
    self.fireOnce = fireOnce
    self.seperator = seperator
    return self
end

return Connector
