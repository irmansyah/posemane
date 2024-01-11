local json = require("dkjson")

-- Function to check if a string starts with a specific prefix (case-sensitive)
local function startsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

-- Function to read JSON data from a file
local function readJsonFromFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil, "Failed to open file"
    end

    local content = file:read("*all")
    file:close()
    return content
end

-- Function to write JSON data to a file
local function writeJsonToFile(filePath, jsonData)
    local file = io.open(filePath, "w")
    if not file then
        return false, "Failed to open file for writing"
    end

    file:write(json.encode(jsonData))
    file:close()

    local success, writeError  = json.encode(jsonData)
    if not success then
	print("Failed to write to Json :", writeError)
    end
    return success
end

-- Function to update nested values based on nested keys
local function updateNestedValue(data, key, value)
    local current = data
    local keys = {}
    for k in key:gmatch("[^.]+") do
        table.insert(keys, k)
    end

    for i = 1, #keys - 1 do
        current[keys[i]] = current[keys[i]] or {}
        current = current[keys[i]]
    end

    current[keys[#keys]] = value

    --local success, writeError  = json.encode(current[keys[#keys]])
    --if not success then
	--print("Failed to update value :", writeError)
    --end
end

-- Function to get value from nested keys based on a string path
local function getValueFromPath(data, path)
    local value = data
    for key in path:gmatch("[^.]+") do
        value = value[key]
        if not value then
            break
        end
    end
    return value
end

local function readFileAndCopyToOtherFileWith(
  filePathSource,
  filePathResultResponse,
  filePathGlobal,
  pathVarSource,
  pathVarResponse,
  pathVarGlobal
)

    -- Read data from source.json
    local jsonData1, readError1 = readJsonFromFile(filePathSource)
    if jsonData1 == nil then
	print("Failed to read JSON from source.json:", readError1)
	return
    end

    ---- Read data from response.json
    --local jsonData2, readError2 = readJsonFromFile(filePathResponse)
    --if jsonData2 == nil then
	--print("Failed to read JSON from response.json:", readError2)
	--return
    --end

    -- Read data from global.json
    local jsonData3, readError3 = readJsonFromFile(filePathGlobal)
    if jsonData3 == nil then
	print("Failed to read JSON from global.json:", readError3)
	return
    end

    -- Decode JSON data
    local decodedDataSource = json.decode(jsonData1)
    local decodedDataResponse = json.decode(filePathResultResponse)
    local decodedDataGlobal = json.decode(jsonData3)

    -- Get the values from specified paths
    local dataValueSource   = getValueFromPath(decodedDataSource, pathVarSource)
    local dataValueResponse = getValueFromPath(decodedDataResponse, pathVarResponse)
    local dataValueGlobal   = getValueFromPath(decodedDataGlobal, pathVarGlobal)

    if dataValueGlobal then
	if type(dataValueGlobal) == "table" then
	    for key, value in pairs(dataValueGlobal) do
		if type(dataValueSource) == "table" then
		    for key1, value1 in pairs(dataValueSource) do
			if type(dataValueResponse) == "table" then
			    local dataValueResponse2 = getValueFromPath(decodedDataResponse, value1)
			    if startsWith(key, "RESPONSE") and dataValueResponse2 then
				updateNestedValue(decodedDataGlobal, pathVarGlobal .. "." .. key1, dataValueResponse2)
				writeJsonToFile(filePathGlobal, decodedDataGlobal)
			    else
				for key2, value2 in pairs(dataValueResponse) do
				    if  key == key1 and key1 == key2 then
					updateNestedValue(decodedDataGlobal, value1, value2)
					writeJsonToFile(filePathGlobal, decodedDataGlobal)
				    end
				end
			    end
			elseif type(dataValueResponse) == "string" then
			    print("dataValueResponse  : " .. json.encode(dataValueResponse))
			    updateNestedValue(decodedDataGlobal, value1, dataValueResponse)
			    writeJsonToFile(filePathGlobal, decodedDataGlobal)
			else
			    print(pathVarResponse .. " doesn't exist, skipping update")
			end
		    end
		elseif type(dataValueSource) == "string" then
		    updateNestedValue(decodedDataGlobal, value, dataValueResponse)
		    writeJsonToFile(filePathGlobal, decodedDataGlobal)
		else
		    print(pathVarSource .. " doesn't exist, skipping update")
		end
	    end
	elseif type(dataValueGlobal) == "string" then
	    updateNestedValue(decodedDataGlobal, decodedDataGlobal, dataValueResponse)
	    writeJsonToFile(filePathGlobal, decodedDataGlobal)
	    print(pathVarGlobal .. " doesn't exist in json file, skipping update in other.json")
	end
    else
	print(pathVarGlobal .. " doesn't exist in json file, skipping update in other.json")
    end
end

return {
    readFileAndCopyToOtherFileWith = readFileAndCopyToOtherFileWith
}

