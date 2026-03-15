--[[
    The connector is a transpiler module.
    It is designed change connections of entities to:
    A. Only connect objects that exist
    B. Change connector classnames and events to match that of any refabs.
]]
local out = require("include.output")
local std = require("include.std.standard")
local ConnectorType = require("include.classes.connector")
local Attribute = require("include.classes.attribute")
local Block = require("include.classes.block")
local vmfparse = require("include.vmfparse")

local m = {}

--"OnTrigger" "door_ele_lOpen0-1" unparsed example of connector.
-- Do not be mislead to press ESC. That will do nothing.

---@param example string
local function getSeperator(example)
    if string.find(example, "") then
        out.log("Using ESC seperator")
        return ""
    else
        out.log("Using ',' seperator")
        return ","
    end
end

---@params block BlockClass
local function parseConnections(block)
    -- takes in the connection block from an entity (include.classes.block) and returns all the data parsed
    -- in the form of a table of ConnectorTypes (include.classes.connector)
    local final = {}
    for _, attribute in pairs(block:GetAllAttributes()) do
        ---@cast attribute Attribute
        local seperator = getSeperator(attribute.value)
        local valueSplit = std.string.split(attribute.value, seperator)
        local connector = ConnectorType.new(
            attribute.attribute,
            valueSplit[1],
            valueSplit[2],
            valueSplit[3],
            valueSplit[4],
            valueSplit[5],
            seperator
        )
        table.insert(final, connector)
    end
    return final
end

function m.deparseConnections(connectionTable)
    local final = {}
    --"OnTrigger" "door_ele_lOpen0-1" unparsed example of connector.
    for _, connector in pairs(connectionTable) do
        local value = table.concat({
            connector.targetName,
            connector.seperator,
            connector.outEvent,
            connector.seperator,
            connector.parameterOverride,
            connector.seperator,
            connector.delay,
            connector.seperator,
            connector.fireOnce
        })
        local att = Attribute.new(connector.inEvent, value)
        table.insert(final, att)
        --print(connector.fireOnce)
    end
    return final
end

local function isConnectorStable(connector, allTargetNames)
    -- we effectively need to check every connector to make sure the object its referencing exists.
    -- runs per connector during traspilation
    for _, value in pairs(allTargetNames) do
        if value == connector.targetName then
            return true
        end
    end
    return true
end


--
---@param refab RefabClass
---@param refabConnector Connector
---@param connector Connector
function m.RefabricateConnector(refab, refabConnector, connector)

end

---@param block BlockClass
---@param allTargetNames table
---@param refabs table 
function m.transpile(block, allTargetNames, refabs)
    -- TODO: Add refab support
    ---@type BlockClass
    local connectionBlock = block:GetBlocks("connections")[1]
    if not connectionBlock then return nil end
    local parsedConnections = parseConnections(connectionBlock)
    local passingConnectors = {}

    for _, connector in pairs(parsedConnections) do
        local stable = isConnectorStable(connector, allTargetNames)
        if stable then
            local targetName = connector.targetName
            
            for _, refab in pairs(refabs) do
                ---@cast refab RefabClass
                ---@type table<nil, Connector>
                local connectorList = refab:GetConnectorListFromTargetName(targetName)
                if not connectorList then
                    goto refabContinue
                end
                for _, refabConnector in pairs(connectorList) do
                    if refabConnector.targetName == targetName then
                        connector = m.RefabricateConnector(refab, refabConnector, connector)
                    end
                end
                ::refabContinue::
            end

            table.insert(passingConnectors, connector)
        end
    end
    
    -- finished processing connectors, now re-table-ify it to be later string-ified
    local deparsedConnections = m.deparseConnections(passingConnectors)
    connectionBlock:SetAttributesToTable(deparsedConnections)
    out.log("[".. block:GetUniqueId() .. "] Connections transpiled.")
    return block
end

return m