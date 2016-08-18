--
-- Author: viking@iwormgame.com
-- Date: 2015-03-31 16:11:58
--

local LoginController = class("LoginController")

local logger = wq.Logger.new("LoginController")

function LoginController:ctor(view)
    self.view_  = view

    --获取版本号
    self.appVersion = "1.0.0"
    if  device.platform == "android" or device.platform == "ios" then
        rl.Native:getVersion(function(result)
            hotUpdateVersion = hotUpdateVersion or result
            print("login rl.Native:getVersion version = "..result..",hotupdateVer:"..hotUpdateVersion)
            rl.schedulerFactory:delayGlobal(function()
                self.appVersion = result
            end, 0.2)
        end)
    end
end

function LoginController:guestLogin()
    self.firstTime = wq.getTime()

    rl.Facebook:logout()

    rl.userDefault:setStringForKey(rl.StorageKeys.LAST_LOGIN, "GUEST")
    rl.userDefault:flush()
    wq.HttpService.PostUrl(appConfig.ROOT_URL.."/index.php/login/index" or "http://codeigniter.iwormgame.com/index.php/login/index",
        {
            logintype = "visitor",
            platform = (device.platform == "windows" and "android" or device.platform),
            uniqID = rl.Native:getLoginId(),
            appVersion = hotUpdateVersion or self.appVersion,
        },
        handler(self, self.onLoginSuccessListener_),
        handler(self, self.onLoginFailListener_))
end

function LoginController:fbLogin()
    rl.userDefault:setStringForKey(rl.StorageKeys.LAST_LOGIN, "FACEBOOK")
    rl.userDefault:flush()

    rl.Facebook:login(function(result)
        if result == "canceled" then
            logger:log("canceled")
            --todo
            self:onLoginFailListener_()
        elseif result == "failed" then
            logger:log("failed")
            --todo
            self:onLoginFailListener_()
        else
            logger:log("success access token:"..result)
            self:onloginFacebook_(result)
        end
    end)
end

function LoginController:onloginFacebook_(accessToken)
    self.firstTime = wq.getTime()

    rl.userDefault:setStringForKey(rl.StorageKeys.FACEBOOK_ACCESS_TOKEN, accessToken)--自动登录需要token，判断是否为空
    rl.userDefault:flush()

    wq.HttpService.PostUrl(appConfig.ROOT_URL.."/index.php/login/index" or "http://gameth.iwormgame.com/index.php/login/index",
        {
            logintype = "fb",
            platform = (device.platform == "windows" and "android" or device.platform),
            token = accessToken,
            appVersion = hotUpdateVersion or self.appVersion,
        },
        handler(self, self.onLoginSuccessListener_),
        handler(self, self.onLoginFailListener_))
end

function LoginController:onLoginSuccessListener_(data)
    self.secondTime = wq.getTime()

    local retData = json.decode(data)
    if type(retData) == "table" and retData.uid and tonumber(retData.uid) > 0 then
        rl.haveGetRedPoint = false
        wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)

        if retData.pig_info == nil then
            retData.pig_info = {}
        end
        wq.DataStorage:setData(rl.DataKeys.PIG_DATA, retData.pig_info)
        for key, var in pairs(retData.pig_info) do
            wq.DataStorage:setData(rl.DataKeys.PIG_DATA..key, var, true)
        end

        for i = 1, #rl.pigData do
            if rl.pigData[i].isShow == 1 then
                rl.pigData[i].finishTime = os.time() + rl.pigData[i].timeLeft
            end
        end

        wq.EventDispatcher:dispatchEvent(rl.EventKeys.LOGIN_SUCCESS)

        self:getConfig()
		--其他事件

        local lastLoginType = rl.userDefault:getStringForKey(rl.StorageKeys.LAST_LOGIN, "GUEST")
        if lastLoginType == "FACEBOOK" then
            rl.userData.isGuest = false
        elseif lastLoginType == "GUEST" then
            rl.userData.isGuest = true
        end


	elseif retData.uid == -99 then
		--其他错误，停服之类的
        rl.TopTipsManager:insert(retData.msg)
        self.view_:stopLoadingViewAnim()
        self.view_:setLoginButtonsVisible(true)
    else
        self:onLoginFailListener_()
	end
end

function LoginController:onLoginFailListener_()
    rl.TopTipsManager:insert(wq.LangTool.getText("Common", "badNetWork"))
    wq.EventDispatcher:dispatchEvent(rl.EventKeys.LOGIN_FAIL)
    self.view_:stopLoadingViewAnim()
    self.view_:setLoginButtonsVisible(true)
end

local retryTimes = 3
function LoginController:getConfig()
    wq.HttpService.PostUrl(appConfig.ROOT_URL.."/index.php/login/config" or "http://gameth.iwormgame.com/index.php/login/index",
        {
            uid = rl.userData.uid,
        },
        function(data)
            local retData = json.decode(data)
            wq.DataStorage:setData(rl.DataKeys.CONFIG_DATA, retData, true)
            wq.HttpService.setDefaultUrl(retData.url_root)

            wq.HttpService.setDefaultParam("uid", rl.userData.uid)
            wq.HttpService.setDefaultParam("ckey", rl.userData.ckey)
            wq.HttpService.setDefaultParam("skey", rl.userData.skey)

            --拿到url_root之后，做其他链接http的操作
            self:getQuickChatConfig()
            --推送token
            if rl.Push then
                rl.Push:registerlush(function(result)
                    logger:log("push token:"..result)
                    if result ~= "failed" then
                        logger:log("push")
                        --php发送token
                        self:pushToken(result)
                    end
                end)
            end
            --广播
            rl.socket.BroadcastSocket:connect(retData.broad_ip, retData.broad_port, true)

            if not rl.userData.isGuest then
                rl.Facebook:getAppRequestsId(rl.userData.isLogin)
            end

            display.addSpriteFrames("hall.plist", "hall.png", function()
                self.view_:stopLoadingViewAnim()

                self.thirdTime = wq.getTime()
                self:reportLoginTime()--上报登录时间

                app:enterScene("HallScene")
            end)
        end,
        function()
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                self:getConfig()
            else
                retryTimes = 3
                self:onLoginFailListener_()
            end
        end)
end

--php发送token
local retryPushTimes = 3
function LoginController:pushToken(token)
    logger:log("php token")
    wq.HttpService.Post(
       {
           type = "reportToken",
           apply = "reportData",
           token = token
       },
       function (data)
       end,
       function ()
            retryPushTimes = retryPushTimes - 1
            if retryPushTimes > 0 then
                self:pushToken(token)
            else
                retryPushTimes = 3
            end
       end)
end

function LoginController:getQuickChatConfig()
    local url = rl.configData.conf_root..rl.configData.quick_chat_config
    wq.cacheFile(url, function(isSuccess,data)
        if isSuccess then
            local retData = json.decode(data)
            wq.DataStorage:setData(rl.DataKeys.ROOM_CHAT_DATA, retData)
        else
            rl.ui.Tips.new({String = "get quick chat fail"}):show()
        end
    end, "quickChat")
end

function LoginController:reportLoginTime()
    local login = string.format("%.3f", (self.thirdTime - self.firstTime + 0.0005))
    local func = string.format("%.3f", (self.secondTime - self.firstTime + 0.0005))
    logger:log("reportLoginTime login:"..login..", func:"..func)
    wq.HttpService.Post(
       {
           type = "report",
           apply = "loginTime",
           login = tonumber(login),
           func = tonumber(func),
       },
       function (data)
       end,
       function ()
       end)
end

return LoginController
