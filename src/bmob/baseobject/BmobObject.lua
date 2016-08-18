local BmobObject = class("BmobObject", cc.Object)

local logger = wq.Logger.new("BmobObject")

HTTP_OP_Type = {
    _bHTTP_SAVE = 0,
    _bHTTP_UPDATE = 1,
    _bHTTP_DELETE = 2,
    _bHTTP_RESET = 3,
    _bHTTP_REQUEST_CODE = 4,
    _bHTTP_RESET_BY_CODE = 5,
    _bHTTP_EMAIL_VERIFY = 6,
    _bHTTP_LOGIN = 7
}

HttpRequestType = {POST = "POST",GET = "GET",PUT = "PUT",DELETE = "DELETE"}

function BmobObject:ctor(tableNmae)
    self.m_tableName = tableName

    self.m_pSaveDelegate = nil
    self.m_pUpdateDelegate = nil
    self.m_pSaveDelegate = nil
end

function BmobObject:save(delegate)
	if not bmob.BmobSDKInit.isInitialize() then return end

    self._opType = HTTP_OP_Type._bHTTP_SAVE

	self.m_pSaveDelegate = delegate

    self.m_url = bmob.BmobSDKInit.URL..self.m_tableName

	self:send()
end

function BmobObject:increment(column,value)
   -- this->addParams(column,CCInteger::create(value));
end

function BmobObject:setValue(key,obj)
    self:enParamsToHttp(key,object);
end

function BmobObject:setValueArray(key,array)
    --'{"skills":{"__op":"AddUnique","objects":["flying","kungfu"]}}'
    local dict = {}
    dict.__op = "AddUnique"
    dict.objects = array

    self:enParamsToHttp(key,dict);
end

function BmobObject:setObjectId(id)
    self.m_objectId = id
end

function BmobObject:getObjectId()
    return self.m_objectId
end

function BmobObject:update(delegate)
    self:update(self:getObjectId(),delegate)
end


function BmobObject:update(objectId,delegate)
    if not objectId then return end

    self._opType = HTTP_OP_Type._bHTTP_UPDATE
    self.m_pUpdateDelegate = delegate

    self.m_url = bmob.BmobSDKInit.URL..self.m_tableName

    if objectId then
        self.m_url = self.m_url.."/"..objectId
    end

    self:send(HttpRequestType.PUT)
end

function BmobObject:remove(name)
    if not name then return end

    self:clear()

    local dist = {}
    dist.__op = "Delete"

    self:enParamsToHttp(name,dist);
end

function BmobObject:removeAll(name,array)
    if not array then return end

    local dist = {}

    dist.__op = "Remove"
    dist.objects = array

    self:enParamsToHttp(name,dict)
end

function BmobObject:del(delegate)
    self._opType = HTTP_OP_Type._bHTTP_DELETE
    self.m_pDeleteDelegate = delegate

    self.m_url = bmob.BmobSDKInit.URL..self.m_tableName.."/"..self.m_objectId
    self:send(HttpRequestType.DELETE)
end

function BmobObject:del(objectId,delegate)
    self.m_objectId = objectId
    self:del(delegate);
end

function BmobObject:add(column,object)
    --{"list":{"__op":"Add","objects":["person1","person2"]}}
    if not object then return end

    local dict = {}
    dict.__op = "Add"
    local array = {}
    table.insert(array,object)
    dict.objects = array

    self:enParamsToHttp(column,dict)
end

function BmobObject:add(column,array)
    if not column then return end
    local dict = {}
    dict.__op = "Add"
    dict.objects = array

    self:enParamsToHttp(column,dict)
end

function BmobObject:enParamsToHttp(key,obj)
    self.m_mapData[key] = obj
end

function BmobObject:getParams(key)
    if self.m_mapData[key] then
        return self.m_mapData[key]
    end

    return nil
end

function BmobObject:setHeader(v)
	self.m_header = v
end

function BmobObject:getHeader(contentType)
    -- -- if self.m_header == null then
    --     local header_list = {}
    --     table.insert(header_list,"X-Bmob-Application-Id:"..bmob.BmobSDKInit.APP_ID)
    --     table.insert(header_list,"X-Bmob-REST-API-Key:"..bmob.BmobSDKInit.APP_KEY)
    --     --header_list.insert("Accept-Encoding:gzip,deflate")
    --
    --     if self.m_tableName == bmob.BmobSDKInit.USER_TABLE then
    --         if self.m_session then
    --             local se = "X-Bmob-Session-Token:"..self.m_session
    --             table.insert(header_list,se)
    --         end
    --     end
    --
    --     table.insert(header_list,"Content-Type:"..contentType)
    --     self.m_header = header_list
    -- -- end
    --
    -- return self.m_header

    local header_list = {}
    header_list["X-Bmob-Application-Id"] = bmob.BmobSDKInit.APP_ID
    header_list["X-Bmob-REST-API-Key"] = bmob.BmobSDKInit.APP_KEY
    if self.m_tableName == bmob.BmobSDKInit.USER_TABLE then
        if self.m_session then
            header_list["X-Bmob-Session-Token"] = self.m_session
        else
            logger:log("self.m_session is nil")
        end
    end
    header_list["Content-Type"] = contentType
    return header_list
end

function BmobObject:enJson()
    return json.encode(self.m_mapData)
end

function BmobObject:deJson(value)
    self:clear()

    local jsonValue = json.decode(value)

    self.m_objectId =jsonValue["objectId"]
    self.m_createdAt = jsonValue["createdAt"]
    self.m_updatedAt = jsonValue["updatedAt"]
end

function BmobObject:send(httpRequestType)
    -- logger:log("send httpRequestType = "..httpRequestType)
    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xhr:open(httpRequestType, self.m_url) -- 打开链接
    -- logger:log("send m_url = "..self.m_url)

    local headers = self:getHeader("application/json")
    for k,v in pairs(headers) do
        xhr:setRequestHeader(k,v)
        -- logger:log("setRequestHeader k = "..k..",v = "..v)
    end

    -- 状态改变时调用
    local function onReadyStateChange()
        -- 显示状态文本
        -- logger:log("Http readyState:"..xhr.readyState)
        -- logger:log("Http Status Code:"..xhr.status)
        -- logger:log("xhr.response = "..xhr.response)

        if xhr.status == 200 or xhr.status == 201 then
            local retData = json.decode(xhr.response)
            self.delegate(retData)
        end
    end

      -- 注册脚本回调方法
    xhr:registerScriptHandler(onReadyStateChange)

    if httpRequestType == HttpRequestType.POST or httpRequestType == HttpRequestType.PUT then
       local params = self:enJson()
        -- logger:log("send Data = "..params)
        xhr:send(params) -- 发送请求
    else
       xhr:send() -- 发送请求
    end


    -- local request = network.createHTTPRequest(function(evt)
    --     self:onHttpRequestCompleted(evt)
    -- end,self.m_url,httpRequestType)
    --
    -- request:setRequestUrl(self.m_url)
    -- logger:log("send m_url = "..self.m_url)
    --
    -- local headers = self:getHeader("application/json")
    -- for _,v in pairs(headers) do
    --     request:addRequestHeader(v)
    --     logger:log("addRequestHeader = "..v)
    -- end
    --
    -- local params = self:enJson()
    --
    -- if httpRequestType == HttpRequestType.POST or httpRequestType == HttpRequestType.PUT then
    --     request:setPOSTData(params)
    --     logger:log("send setPOSTData = "..params)
    -- end
    -- request:setTimeout(3000)

    -- request:start()
end

function BmobObject:sendFile(fullpath)
    local xhr = cc.XMLHttpRequest:new()

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING -- 响应类型
    xhr:open("POST", self.m_url) -- 打开链接
    logger:log("send m_url = "..self.m_url)

    local headers = self:getHeader("application/octet-stream")
    for k,v in pairs(headers) do
        xhr:setRequestHeader(k,v)
        -- logger:log("setRequestHeader k = "..k..",v = "..v)
    end

    -- 状态改变时调用
    local function onReadyStateChange()
        -- 显示状态文本
        logger:log("Http readyState:"..xhr.readyState)
        logger:log("Http Status Code:"..xhr.status)
        logger:log("xhr.response = "..xhr.response)

        if xhr.status == 200 or xhr.status == 201 then
            local retData = json.decode(xhr.response)
            self.delegate(retData)
        end
    end

    -- 注册脚本回调方法
    xhr:registerScriptHandler(onReadyStateChange)
    local file = io.open(fullpath, "r")
    assert(file)
    local data = file:read("*a") -- 读取所有内容
    file:close()
    xhr:send(data) -- 发送请求
end

function BmobObject:onHttpRequestCompleted(event)
    print("onHttpRequestCompleted -----")
    local request = event.request
    if event.name == "failed" then
        logger:log("onHttpRequestCompleted failed")
        local code = request:getResponseStatusCode()
        logger:log("code = "..code)
		local string = request:getResponseString()
        logger:log("onHttpRequestCompleted string = "..string)
        -- if self._opType == HTTP_OP_Type._bHTTP_SAVE then
        --     if self.m_pSaveDelegate then
        --         self.m_pSaveDelegate.onSaveError(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_UPDATE then
        --     if self.m_pUpdateDelegate then
        --         self.m_pUpdateDelegate.onUpdateError(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_DELETE then
        --     if self.m_pDeleteDelegate then
        --         self.m_pDeleteDelegate.onDeleteError(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_RESET then
        --     if self.m_pResetDelegate then
        --         self.m_pResetDelegate.onResetError(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_REQUEST_CODE then
        --     if self.m_pRequestSMSCodeDelegate then
        --         self.m_pRequestSMSCodeDelegate.onRequestDone(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_RESET_BY_CODE then
        --     if self.m_pResetByMSMCodeDelegate then
        --         self.m_pResetByMSMCodeDelegate.onResetDone(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_EMAIL_VERIFY then
        --     if self.m_pEmailVerifyDelegate then
        --         self.m_pEmailVerifyDelegate.onEmailVerifyError(code,string)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_LOGIN then
        --     if self.m_pLoginDelegate then
        --         self.m_pLoginDelegate.onLoginDone(code,string)
        --     end
        -- end
    elseif event.name == "completed" then
        logger:log("onHttpRequestCompleted completed")
        local code = request:getResponseStatusCode()
		local string = request:getResponseString()
        local retData = json.decode(string)
        logger:log("code = "..code)
        logger:log("string = "..string)

        if code == 404 then
            logger:log("errCode = "..retData.code..",errMsg = "..retData.error)
            return
        end
        self.delegate(retData)
        -- if self._opType == HTTP_OP_Type._bHTTP_SAVE then
        --     if self.m_tableName == bmob.BmobSDKInit.USER_TABLE then
        --         local objectId = retData.objectId
        --         local sessionToken = retData.sessionToken
        --         cc.UserDefault:getInstance():setStringForKey("user_id",objectId)
        --         cc.UserDefault:getInstance():setStringForKey("user_session",sessionToken)
        --         cc.UserDefault:getInstance():flush()
        --     end
        --     if self.m_pSaveDelegate then
        --         self.m_pSaveDelegate.onSaveSucess(retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_UPDATE then
        --     if self.m_pUpdateDelegate then
        --         self.m_pUpdateDelegate.onUpdateSucess(retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_DELETE then
        --     if self.m_pDeleteDelegate then
        --         self.m_pDeleteDelegate.onDeleteSucess(retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_RESET then
        --     if self.m_pResetDelegate then
        --         self.m_pResetDelegate.onResetSucess(retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_REQUEST_CODE then
        --     if self.m_pRequestSMSCodeDelegate then
        --         self.m_pRequestSMSCodeDelegate.onRequestDone(200,retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_RESET_BY_CODE then
        --     if self.m_pResetByMSMCodeDelegate then
        --         self.m_pResetByMSMCodeDelegate.onResetDone(200,retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_EMAIL_VERIFY then
        --     if self.m_pEmailVerifyDelegate then
        --         self.m_pEmailVerifyDelegate.onEmailVerifySucess(retData)
        --     end
        -- elseif self._opType == HTTP_OP_Type._bHTTP_LOGIN then
        --     if self.m_pLoginDelegate then
        --         self.m_pLoginDelegate.onLoginDone(200,retData)
        --     end
        -- end
    elseif event.name == "progress" then
    end
end

function BmobObject:clear()
    self.m_mapData = nil
    self.m_mapData = {}
end

return BmobObject
