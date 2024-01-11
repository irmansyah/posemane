local json = require("dkjson")

local formating = require("formating_list")
local request = require("request_download")
local fileArgument = require("file_argument")
local searchJsonKey = require("search_json_key")
local writeGlobalVar = require("write_global_var")

-- Parse command-line arguments
local args = fileArgument.parseArgs(arg)

-- Access the parsed arguments
local restName = args["name"] or ""
local globalPath = args["global_path"] or ""
local bodyPath = args["body_path"] or ""

local function collectKeyValuePairs(data, result)
    result = result or {}
    for key, value in pairs(data) do
        if key and value["name"] and value["req_type"] and value["url"] then
	    table.insert(result, {
	      id = key,
	      name = value["name"],
	      req_type = value["req_type"],
	      used_token = value["used_token"],
	      url = value["url"],
	      GLOBAL_ENV_DATA = value["GLOBAL_ENV_DATA"],
	    })
        end
    end
    return result
end

local baseRestFile = fileArgument.geRestFileSecondArg("REST_FILES", "BASE_REST_FILE")
local restFiles = fileArgument.geRestFileWithRestNameSecondArg("REST_FILES", restName)
local dataRestFiles = fileArgument.loadPublicJsonData(baseRestFile .. restFiles)
local keyValuePairs = collectKeyValuePairs(dataRestFiles)

print("\nChoose Request by Number :\n")

formating.formatKeyValueList(keyValuePairs)

io.write("\nEnter the Number : ")

local choice = tonumber(io.read())

if choice and choice >= 1 and choice <= #keyValuePairs then
    local item = keyValuePairs[choice]
    print("\n*** " .. item.name .. " ***\n");

    local dataToken = fileArgument.geRestFileWithRestNameSecondArg("GLOBAL_VARIABLE", "RESPONSE_ACCESS_TOKEN")
    local dataUrl = fileArgument.geRestFileFirstArg("BASE_URL") .. item.url

    local bodyName = fileArgument.geRestFileSecondArg("REST_FILES", restName)
    local bodyBody = fileArgument.geRestFileSecondArg("REST_FILES", bodyPath)
    local bodyData = searchJsonKey.getValueByKey(baseRestFile .. bodyBody, item.id)

    --print("bodyData : ", json.encode(bodyData))

    local sourceVarPath = item.id .. "." ..'GLOBAL_ENV_DATA'
    local responseVarPath = ""
    local globalVarPath = "GLOBAL_VARIABLE"

    -----Write Global Var Version later all should using this -------------
    -----------------------------------------------------------------------
    --local sourcePath = writeGlobalVar.readJsonFromFile(globalPath)

    request.downloadFileWithRequestData(
      baseRestFile .. bodyName, -- sourceFile
      globalPath,               -- globalFile
      sourceVarPath,            -- sourceVarPath
      responseVarPath,          -- sourceVarResponsePath
      globalVarPath,            -- globalVarPath
      item.name,
      item.req_type,
      item.used_token,
      dataUrl,
      dataToken,
      bodyData,
      item.GLOBAL_ENV_DATA
    );
else
    print("\nInvalid choice. Please enter a valid number.")
end


