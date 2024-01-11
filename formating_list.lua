-- Function to format key-value pairs into a list with proportional alignment
local function formatKeyValueList(keyValuePairs)
    local maxNameLength = 20

    table.sort(keyValuePairs, function(a, b) return a.id > b.id end)

    for _, item in ipairs(keyValuePairs) do
	if #item.name > maxNameLength then
	    maxNameLength = #item.name
	end
    end

    -- Iterate through the table and print with index and proportional spacing
    for index, item in ipairs(keyValuePairs) do
	local spacing = maxNameLength + 3

	local formattedName = string.format("%-" .. spacing .. "s", item.name)
	local formattedUrl = string.format("%-" .. spacing .. "s", item.url)

	print(string.format("%-2d", index) .. ".  " .. formattedName .. " : " .. formattedUrl)
    end
end

return {
    formatKeyValueList = formatKeyValueList
}
