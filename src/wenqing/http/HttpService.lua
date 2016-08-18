local HttpService = {}
local logger = wq.Logger.new("HttpService")

HttpService.requestId_    = 0
HttpService.requests      = {}
HttpService.defaultUrl    = ""
HttpService.defaultParams = {}

function HttpService.setDefaultUrl(url)
	HttpService.defaultUrl = url
end

function HttpService.clearDefaultParams()
	HttpService.defaultParams = {}
end

function HttpService.setDefaultParam(key, value)
	HttpService.defaultParams[key] = value;
end

function HttpService.copyDefaultParams(params)
	if params then
		table.merge(params, HttpService.defaultParams)
		return params
	end
    return clone(HttpService.defaultParams)
end

function HttpService.onResponse(event, requestId)
    local resultListener = HttpService.requests[requestId][2]
    local errorListener = HttpService.requests[requestId][3]

    local request = event.request
    if event.name == "completed" then
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            logger:logf("[%d] code=%s", requestId, code)
            if errorListener then
                errorListener(code)
            end
        else
            local response = request:getResponseString()
            logger:logf("[%d] response=%s", requestId, response)
            if resultListener then
                resultListener(response)
            end
        end
    elseif event.name ~= "progress" then
        logger:logf("[%d] errCode=%s errmsg=%s", requestId, request:getErrorCode(), request:getErrorMessage())
        if errorListener then
            errorListener(request:getErrorCode(), request:getErrorMessage())
        end
    end
end

local function createRequest(method, url, params, resultListener, errorListener, hasDefaultParams)
	if url == nil or url == "" then
		logger:log("url nil")

    	wq.HttpService.PostUrl(appConfig.ROOT_URL.."/index.php/login/config" or "http://gameth.iwormgame.com/index.php/login/index",
        {},
        function(data)
            local retData = json.decode(data)
            wq.DataStorage:setData(rp.DataKeys.CONFIG_DATA, retData, true)
            wq.HttpService.setDefaultUrl(retData.url_root)

            wq.HttpService.setDefaultParam("uid", rp.userData.uid)
            wq.HttpService.setDefaultParam("ckey", rp.userData.ckey)
            wq.HttpService.setDefaultParam("skey", rp.userData.skey)
        end,
        function()
        end)

		return
	end

	local tmpParams = nil
	local typeAndapply = ""
    if hasDefaultParams then
    	if params.isExtends then
			if params.type1 and params.apply1 then
				typeAndapply = string.format("[%s_%s]", params.type1, params.apply1)
				url = url .. params.type1 .. "/" .. params.apply1
			end
			params.type1 = nil
			params.apply1 = nil
			params.isExtends = nil
    	else
	 		if params.type and params.apply then
				typeAndapply = string.format("[%s_%s]", params.type, params.apply)
				url = url .. params.type .. "/" .. params.apply
			end
			params.type = nil
			params.apply = nil
    	end

		tmpParams = HttpService.copyDefaultParams()
		table.merge(tmpParams, params)
	else
		tmpParams = params
	end

    HttpService.requestId_ = HttpService.requestId_ + 1
    local requestId = HttpService.requestId_
	local request = network.createHTTPRequest(function(evt)
        HttpService.onResponse(evt, requestId)
	end, url, "GET")

	for key, value in pairs(tmpParams) do
		if method == "POST" then
			request:addPOSTValue(tostring(key), tostring(value))
		end
	end

	logger:logf("[%s][%s][%s]%s %s", requestId, method, url, typeAndapply, json.encode(tmpParams))
    HttpService.requests[requestId] = {request, resultListener, errorListener}
	request:start()

	return requestId
end

function HttpService.Cancel(requestId)
    if HttpService.requests[requestId] then
--        HttpService.requests[requestId][1]:cancel()
--        HttpService.requests[requestId][1] = nil
        HttpService.requests[requestId][2] = nil
        HttpService.requests[requestId][3] = nil
    end
end

function HttpService.Post(params, resultListener, errorListener)
    return createRequest("POST", HttpService.defaultUrl, params, resultListener, errorListener, true)
end

function HttpService.PostUrl(url, params, resultListener, errorListener, hasDefaultParams)
    return createRequest("POST", url, params, resultListener, errorListener, hasDefaultParams)
end

function HttpService.Get(params, resultListener, errorListener)
    return createRequest("GET", HttpService.defaultUrl, params, resultListener, errorListener, true)
end

function HttpService.GetUrl(url, params, resultListener, errorListener, hasDefaultParams)
	return createRequest("GET", url, params, resultListener, errorListener, hasDefaultParams)
end

function HttpService.UploadFile(filePath, resultListener, errorListener, url, extra)
	logger:log("")
	local uploadUrl = rp.configData.url_root.."user/uploadIcon" or "http://gameth.iwormgame.com/index.php/user/uploadIcon"
	if url then
		uploadUrl = url
    end

    local uploadExtra = {
        {"uid", rp.userData.uid},
        {"ckey", rp.userData.ckey},
        {"skey", rp.userData.skey},
    }
    if extra then
        uploadExtra = extra
    end

	network.uploadFile(function(evt)
		if evt.name == "completed" then
			local request = evt.request
			logger:logf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
			logger:logf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
 			logger:logf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
            logger:logf("REQUEST getResponseString() =\n%s", request:getResponseString())
            if resultListener then
            	resultListener(request:getResponseString())
            end
        else
        	if errorListener then
        		errorListener()
        	end
		end
	end, uploadUrl,
	{
		fileFieldName = "filepath",
		filePath = filePath,
		contentType = "Image/jpeg",
		extra = uploadExtra
	})
end

return HttpService
