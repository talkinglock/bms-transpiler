
local tbl = {}


---@param tableVar table More reliable table counting, accounting for nil values
function tbl.count(tableVar)
    local count = 0
    for _, _ in pairs(tableVar) do
        count = count + 1
    end
    return count
end


return tbl