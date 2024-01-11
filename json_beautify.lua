local json = require("dkjson")

local colors = {
    Reset = "\27[0m",
    Red = "\27[31m",
    Green = "\27[32m",
    Yellow = "\27[33m",
    Blue = "\27[34m",
    Magenta = "\27[35m",
    Cyan = "\27[36m",
    White = "\27[37m"
}

-- Function to beautify JSON data from a file
local function beautifyJSONFromFile(encodedString)
    local jsonData = json.decode(encodedString, 1, nil)
    if jsonData then
        local formattedJSON = json.encode(jsonData, {indent = true})

        -- Apply different colors to keys and values
        formattedJSON = formattedJSON:gsub('"([^"]-)":', colors.Yellow .. '"%1":' .. colors.Reset)
        formattedJSON = formattedJSON:gsub('(":)([^,{}%[%]]-)"', '%1' .. colors.Magenta .. '%2' .. colors.Reset)

        io.write(formattedJSON, "\n")
    else
        io.write(colors.Red, "Error parsing JSON data", colors.Reset, "\n")
    end
end

local function beautifyJSONFromFileError(encodedString)
    local jsonData = json.decode(encodedString, 1, nil)
    if jsonData then
        local formattedJSON = json.encode(jsonData, {indent = true})

        -- Apply different colors to keys and values
        formattedJSON = formattedJSON:gsub('"([^"]-)":', colors.Red .. '"%1":' .. colors.Reset)
        formattedJSON = formattedJSON:gsub('(":)([^,{}%[%]]-)"', '%1' .. colors.Magenta .. '%2' .. colors.Reset)

        io.write(formattedJSON, "\n")
    else
        io.write(colors.Red, "Error parsing JSON data", colors.Reset, "\n")
    end
end

return {
    beautifyJSONFromFile = beautifyJSONFromFile,
    beautifyJSONFromFileError = beautifyJSONFromFileError
}
