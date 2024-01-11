local dkjson = require("dkjson")

-- Function to read data from a JSON file
local function readJSONFile(filename)
    local file = io.open(filename, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return nil
end

-- Function to search for a key and get its value from JSON data
local function getValueByKey(filename, key)
    local jsonString = readJSONFile(filename)
    if jsonString then
        local jsonData = dkjson.decode(jsonString, 1, nil)
        if jsonData then
            local value = jsonData[key]
            if value then
                return value
            else
                print("Key not found in the JSON data")
            end
        else
            print("Error parsing JSON data")
        end
    else
        print("Failed to read JSON file")
    end
    return nil
end

return {
    getValueByKey = getValueByKey
}

