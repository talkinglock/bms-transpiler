---@class Vector3
local Vector3 = {
    x = nil,
    y = nil,
    z = nil
}
Vector3.__index = Vector3

local std = require('include.std.standard')
local out = require("include.output")


Vector3.__add = function (self, otherVec)
    ---@cast otherVec Vector3
    if otherVec['type'] == 'vec3' then
        local ourX, ourY, ourZ = self.x, self.y, self.z
        local theirX, theirY, theirZ = otherVec.x, otherVec.y, otherVec.z
        local resultX, resultY, resultZ = ourX + theirX, ourY + theirY, ourZ + theirZ
        local newVec = Vector3.new(resultX, resultY, resultZ)
        return newVec
    end
    out.fatal("Attempt to add Vector3 to type " .. type(otherVec) .. " (Vector3 expected!)")
    return nil
end


function Vector3.new(x, y, z)
    local self = setmetatable({}, Vector3)
    self.x = x
    self.y = y
    self.z = z
    self['type'] = 'vec3'
    return self 
end

function Vector3.fromText(text)
    local self = setmetatable({}, Vector3)
    
    local split = std.string.split(text, " ")

    local x = tonumber(split[1])
    local y = tonumber(split[2])
    local z = tonumber(split[3])

    if x and y and z then
        self.x = x
        self.y = y
        self.z = z
        return self 
    else
        out.error("Failed to create vector from text!")
    end
end

function Vector3:ToText()
    local text = tostring(self.x) .. " ".. tostring(self.y) .. " " .. tostring(self.z)
    return text
end



return Vector3