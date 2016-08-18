--
-- Author: wenqing
-- Date: 2016-04-30 14:13:10
--

local BmobCloud = import(".BmobObject")
local BmobCloud = class("BmobCloud",BmobCloud)

local EXEC_EXEC = "EXEC_EXEC"
local EXEC_CREATE = "EXEC_CREATE"
local EXEC_DELETE = "EXEC_DELETE"

local logger = wq.Logger.new("BmobCloud")

function BmobCloud:send(httpRequestType)
    logger:log("send httpRequestType = "..httpRequestType)
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

    if httpRequestType == HttpRequestType.POST or httpRequestType == HttpRequestType.PUT then
        local params = self:enJson()
        -- logger:log("send Data = "..params)
        xhr:send(params) -- 发送请求
    else
        xhr:send() -- 发送请求
    end
end

function BmobCloud:onHttpRequestCompleted(event)
    print("----------------onHttpRequestCompleted")
    local request = event.request
    if event.name == "failed" then
        logger:log("onHttpRequestCompleted failed")
        local code = request:getResponseStatusCode()
        logger:log("code = "..code)
        local string = request:getResponseString()
        logger:log("onHttpRequestCompleted string = "..string)

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

    elseif event.name == "progress" then
    end
end

function BmobCloud:execCloud(cloudName,param,execType,callback)

	logger:log("cloudName = "..cloudName)

    self.m_url = bmob.BmobSDKInit.CLOUD_CODE_URL
    self.m_url = self.m_url..cloudName
    -- logger:log("self.m_url = "..self.m_url)


	self.delegate = callback

    -- logger:log("sexecType = "..execType)
    if execType == EXEC_EXEC then
        if param then
            self.m_mapData = param
        end
        self:send("POST")
    elseif execType == EXEC_DELETE then
        self:send("DELETE")
    elseif execType == EXEC_CREATE then
        self.m_mapData = param
        self:send("PUT")
    end

end

function BmobCloud:onGetRoomId(data)
	local retData = json.decode(data.result)
	dump(retData)
    if retData.ret == 0 or retData.ret == "0" then
    	-- wq.DataStorage:setData(rl.DataKeys.CUR_ROOM_ID,retData.objectId)
    	rl.curRoomId = retData.objectId
    	cc.Director:getInstance():pushScene(import("app.scenes.RoomScene").new())
    else

    end
end


return BmobCloud
