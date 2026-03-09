local tbl = {}


---@param tableVar table More reliable table counting, accounting for nil values
function tbl.count(tableVar)
    local count = 0
    for _, _ in pairs(tableVar) do
        count = count + 1
    end
    return count
end

---@param ... table Tables to combine
function tbl.combine(...)
    local args = {...}
    local endTable = {}
    for _, tableVar in ipairs(args) do
        for _, entry in ipairs(tableVar) do
            table.insert(endTable, entry)
        end
    end
    return endTable
end

return tbl
