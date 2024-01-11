local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

local beautify = require("json_beautify")
local globalVar = require("write_global_var")

local function downloadFileWithRequestData(
    sourceFile,
    globalFile,
    sourceVarPath,
    responseVarPath,
    globalVarPath,
    filename,
    reqType,
    usedToken,
    url,
    token,
    reqBody,
    globalEnvData
)

    print("reqBody : ", json.encode(reqBody))

    if filename and reqType and url then
	local request_headers = {}
	if usedToken == true then
	    request_headers["Content-Type"] = "application/json"
	    request_headers["Authorization"] = token
	else
	    request_headers["Content-Type"] = "application/json"
	end

	local requestBodyJson
	if reqBody then
	    local success, encodedRequestBody = pcall(json.encode, reqBody)
	    if success then
		requestBodyJson = encodedRequestBody
	    else
		print("Error encoding requestBody to JSON:", encodedRequestBody)
	    end
	end

	if token and token ~= "" then
	    request_headers["Authorization"] = token
	end

	local response_body = {}


	if requestBodyJson then
	    print("")
	    print("************************************************");
	    print("                 Request Body                   ");
	    print("************************************************");
	    beautify.beautifyJSONFromFile(requestBodyJson)
	    print("");
	end

	-- Make the HTTP request
	local _, status_code, _, _ = http.request {
	    url = url,
	    method = reqType,
	    headers = request_headers,
	    source = requestBodyJson and ltn12.source.string(requestBodyJson),
	    sink = ltn12.sink.table(response_body)
	}

	if status_code then
	    local responseBodyString = table.concat(response_body)
	    if type(responseBodyString) == "table" or type(responseBodyString) == "string" then
		if status_code == 200 or status_code == 201 then
		    --local result = assignAndGetNestedValue(responseBodyString, status_code)
		    print("")
		    print("************************************************");
		    print("                 Response Body                  ");
		    print("************************************************");
		    beautify.beautifyJSONFromFile(responseBodyString)
		    print("")


		    globalVar.readFileAndCopyToOtherFileWith(
		      sourceFile,
		      responseBodyString,
		      globalFile,
		      sourceVarPath,
		      responseVarPath,
		      globalVarPath
		    )
		else
		    if responseBodyString then
			print("")
			print("************************************************");
			print("                   ERROR Body                   ");
			print("************************************************");
			beautify.beautifyJSONFromFileError(responseBodyString)
			print("")
		    end
		end
	    else
		if responseBodyString then
		    beautify.beautifyJSONFromFileError(responseBodyString)
		    --print("Response Body : " .. responseBodyString)
		end
	    end
	else
	    print("Error occurred while making the request")
	end
    else
        print("URL, RequestType, or AuthHeader missing or invalid in request_file")
    end
end

return {
    downloadFileWithRequestData = downloadFileWithRequestData
}














