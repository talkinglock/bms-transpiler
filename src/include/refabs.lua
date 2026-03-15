--[[
Refabs are by far the most important part of the transpiler.
What a refab does and what terminology is for can be found on the github repo:
"https://github.com/talkinglock/bms-transpiler/blob/master/src/resources/refabs/readme.md"

This script runs *before* the connections check and *during* the targtnames check
]]

local BlockClass = require("include.classes.block")
local AttClass = require("include.classes.attribute")
local RefabClass = require("include.classes.RefabClass")

local RefabType = require("include.enums.RefabType")

local vmfparse = require("include.vmfparse")

local out = require("include.output")
local G = require("include.GLOBALS")

---@class Refabs
local Refabs = {}

---@param xenName string Finds corresponding .bmst metadata block from a XenName. Returns nil if one isnt found
---@return BlockClass|nil Block
function Refabs.findRefabBlockFromXenName(xenName) 
    local refabPointerFile = io.open(G.REFAB_POINTER_FILE_PATH, "r")

    if not refabPointerFile then
        out.fatal("Could not find refab pointer file in '" .. G.REFAB_POINTER_FILE_PATH .. "'!")
    end
    local refabTable = vmfparse.parseFromFile(refabPointerFile)
    
    ---@type BlockClass
    local pointerBlock = refabTable[1]
    
    if not pointerBlock then
        out.fatal("Could not find refab pointer table in '" .. G.REFAB_FOLDER_FILE_PATH .. "'! Is the file empty?")
    end
    ---@type Attribute
    local xenNameAtt = pointerBlock:GetAttributes(xenName)[1]
    if not xenNameAtt then
        out.info("No refab detected for " .. xenName .. ". Expected behavior.")
        return nil
    end
    local xenFilePath = G.REFAB_FOLDER_FILE_PATH .. xenNameAtt.value
    local xenFile = io.open(xenFilePath, "r")

    if not xenFile then
        out.warn(xenFilePath .. " defined in refab pointer file, but not found in specified directory.")
        return nil
    end

    local xenParsed = vmfparse.parseFromFile(xenFile)
    ---@type BlockClass
    local xenBlock = xenParsed[1]
    if not xenBlock then
        out.warn(xenFilePath .. " defined in refab pointer file and found, but main block not found. Is the file empty?")
        return nil
    end
    return xenBlock
end

---@param str string String to check
---@return integer|nil Converted type
function Refabs.refabStringToType(str)
    if str == 'direct' then
        return RefabType.DIRECT
    elseif str == 'fabbed' then
        return RefabType.FABBED
    else
        return nil
    end
end

---@param block BlockClass Entity block for the XenEngine entity
---@return RefabClass|nil Refab found  
function Refabs.transpile(block)
    local classname = block:GetAttributes("classname")[1].value
    ---@type BlockClass|nil
    local refabBlock = Refabs.findRefabBlockFromXenName(classname)
    if not refabBlock then return nil end
    if refabBlock:GetAttributes("replacename")[1].value ~= classname then
        out.warn("Refab block doesn't contain correct replacename!")
        return nil
    end
    local typeString = refabBlock:GetAttributes("type")[1].value
    local type = Refabs.refabStringToType(typeString)
    if not typeString or not type then
        out.warn("Type not found!")
        return nil
    end
    
    local Refab = RefabClass.new(refabBlock, type, block)
    return Refab:Initialize()
end

return Refabs
