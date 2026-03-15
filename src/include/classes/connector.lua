---@class Connector
local Connector = {
    inEvent = nil,
    targetName = nil,
    outEvent = nil,
    parameterOverride = nil,
    delay = nil,
    fireOnce = nil,
    seperator = nil
}
Connector.__index = Connector
Connector.__tostring = 
function (v)
    return "Connector"
end

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
