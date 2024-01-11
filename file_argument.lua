local json = require("dkjson")

-- Function to parse command-line arguments
function parseArgs(args)
    local parsedArgs = {}

    for _, arg in ipairs(args) do
        local name, value = arg:match("^%-%-(.-)%=(.-)$")
        if name and value then
            parsedArgs[name] = value
        end
    end

    return parsedArgs
end

local args = parseArgs(arg)
local globalPath = args["global_path"] or ""

local function loadJsonData(filePath)
    local file = io.open(filePath, "r")
    if not file then
	print("Unable to open file: " .. filePath)
	return
    end

    local content = file:read("*all")
    file:close()
    return content
end

local function initRequestDataGlobalVariable()
    local content = loadJsonData(globalPath)
    local data, _, err = json.decode(content)
    if err then
	print("Error content decoding JSON:", err)
	return
    end
    return data
end

function loadPublicJsonData(data)
    local content = loadJsonData(data)
    local newData, _, err = json.decode(content)
    if err then
	print("Error content decoding JSON:", err)
	return
    end
    return newData;
end

function loadPublicJsonDataWithEncode(data)
    local content = loadJsonData(data)
    local newData, _, err = json.decode(content)
    if err then
	print("Error content decoding JSON:", err)
	return
    end
    return json.encode(newData);
end

local function geRestFileFirstArg(restFileName)
    local rfContent = json.encode(initRequestDataGlobalVariable()[restFileName])
    local rfData, _, rfErr = json.decode(rfContent)
    if rfErr then
	print("Error rfContent decoding JSON:", rfErr)
	return
    end
    return rfData;
end

local function geRestFileWithRestNameSecondArg(firstArg, restName)
    local rfContent = json.encode(initRequestDataGlobalVariable()[firstArg][restName])
    local rfData, _, rfErr = json.decode(rfContent)
    if rfErr then
	print("Error rfContent decoding JSON:", rfErr)
	return
    end
    return rfData
end

local function geRestFileSecondArg(firstArg, secondArg)
    local rfContent = json.encode(initRequestDataGlobalVariable()[firstArg][secondArg])
    local rfData, _, rfErr = json.decode(rfContent)
    if rfErr then
	print("Error rfContent decoding JSON:", rfErr)
	return
    end
    return rfData
end

return {
    parseArgs = parseArgs,
    loadPublicJsonData = loadPublicJsonData,
    geRestFileFirstArg = geRestFileFirstArg,
    geRestFileSecondArg = geRestFileSecondArg,
    loadPublicJsonDataWithEncode = loadPublicJsonDataWithEncode,
    geRestFileWithRestNameSecondArg = geRestFileWithRestNameSecondArg,
}
