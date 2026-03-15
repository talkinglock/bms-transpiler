--[[
Basic functions
Inspired by C++
]]


local std = {}
std.string = require("include.std.string")
std.table = require("include.std.table")


-- Returns type of object (__tostring metamethod for classes)
---@param variable any
function std.type(variable)
    if type(variable) ~= "table" then
        return type(variable)
    else
        return tostring(variable)
    end
end
-- Returns true if variable is type t
---@param variable any
---@param t string
function std.isType(variable, t)
    local type = std.type(variable)
    if type == t then
        return true
    end
    return false
end
return std