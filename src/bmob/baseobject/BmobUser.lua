local BmobObject = import(".BmobObject")
local BmobUser   = class("BmobUser",BmobObject)

BmobUser.__USER_FILE = "cur_user.xml"

local logger = wq.Logger.new("BmobUser")

function BmobUser:ctor()
	BmobUser.super.ctor(self, BmobUser.__USER_FILE)
	self.m_tableName = "_User"
end

function BmobUser:getCurrentUser()
	if self.currentUser then
		return self.currentUser
	end

	local id      = cc.UserDefault:getInstance():getStringForKey("user_id")
	local pwd     = cc.UserDefault:getInstance():getStringForKey("user_pwd")
	local name    = cc.UserDefault:getInstance():getStringForKey("user_name")
	local session = cc.UserDefault:getInstance():getStringForKey("user_session")

	if id or name or session then
		return nil
	end

	self.currentUser            = {}
	self.currentUser.m_objectId = id
	self.currentUser.m_username = name
	self.currentUser.m_session  = session
	self.currentUser:setPassword(pwd)

	return self.currentUser
end

function BmobUser.logOut()
	if self.currentUser == nil then return end

	cc.UserDefault:getInstance():setStringForKey("user_id","")
	cc.UserDefault:getInstance():setStringForKey("user_pwd","")
	cc.UserDefault:getInstance():setStringForKey("user_name","")
	cc.UserDefault:getInstance():setStringForKey("user_session","")
	cc.UserDefault:getInstance():flush()

	self.currentUser = nil
end

function BmobUser:setPassword(password)
	--encrpty
	self.currentUser.m_password = password;
end

function BmobUser:getPassword()
	return self.currentUser.m_password
end

--注册
function BmobUser:signUp(username,password)

	self.m_url =  bmob.BmobSDKInit.USER_URL

	-- self._opType = HTTP_OP_Type._bHTTP_SAVE
	self.m_session = nil
	self._task = "signUp"
	self.delegate = function(retData)
		logger:log("onSignUpSucess")

		-- retData:
		-- "createdAt"    = "2016-03-20 22:17:32"
		-- "money"        = 10000
		-- "objectId"     = "72664e5dc8"
		-- "sessionToken" = "a35841be40a6951f8013ae899c3aad02"
		-- "updatedAt"    = "2016-03-27 10:11:15"
		-- "username"     = "liu2"

		wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)
		rl.userData.icon = retData.icon or ""
		rl.userData.money = retData.money or 0
		rl.userData.exp = retData.exp or 0
		rl.userData.nickName = retData.nickName or "nickName"

		self.m_session =  retData.sessionToken
		app:enterScene("HallScene")
	end

	self.m_mapData = {}
	self.m_mapData.username = username
	self.m_mapData.password = password

    -- cc.UserDefault:getInstance():setStringForKey("user_name",self.m_username)
    -- cc.UserDefault:getInstance():setStringForKey("user_pwd",self.m_password)
    -- cc.UserDefault:getInstance():flush()

	self:send("POST")
end

--登录
function BmobUser:login(username,password)
	self.m_url = bmob.BmobSDKInit.LOGIN_URL.."?username="..username.."&password="..password
	self:clear()
	self._task = "login"
	self.m_mapData = {}
	self.m_mapData.username = username
	self.m_mapData.password = password
	self.m_session = nil
	self.delegate = function(retData)
	    logger:log("onLoginSucess")
	    -- retData:
	    -- "createdAt"    = "2016-03-20 22:17:32"
	    -- "money"        = 10000
	    -- "objectId"     = "72664e5dc8"
	    -- "sessionToken" = "a35841be40a6951f8013ae899c3aad02"
	    -- "updatedAt"    = "2016-03-27 10:11:15"
	    -- "username"     = "liu2"
		dump(retData)
	    wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)
		rl.userData.icon  = retData.icon or ""
		rl.userData.money = retData.money or 0
		rl.userData.exp   = retData.exp or 0
		self.m_session    = retData.sessionToken
		rl.userData.name = retData.nickName or "nickName"

		app:enterScene("HallScene")
	end

	self:send("GET")
end

function BmobUser:updateIcon(iconUrl)
	self.m_url = bmob.BmobSDKInit.USER_URL.."/"..rl.userData.objectId
	self:clear()
	print("iconUrl = "..iconUrl)
	self.m_mapData = {}
	self.m_mapData.icon = iconUrl
	-- self.m_mapData.username = "liu3"
	-- self.m_mapData.phone = "8812221"

	self.delegate = function(retData)
		-- dump(retData)
	end

	self:send("PUT")
end

function BmobUser:updateMoney(money)
	self.m_url = bmob.BmobSDKInit.USER_URL.."/"..rl.userData.objectId
	self:clear()
	print("money = "..money)
	self.m_mapData = {}
	self.m_mapData.money = money

	self.delegate = function(retData)
		-- dump(retData)
	end

	self:send("PUT")
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
		elseif xhr.status == 404 then
			local retData = json.decode(xhr.response)
			dump(retData)
			if self._task == "login" and retData.code == 101 then
				local username = self.m_mapData.username
				local password = self.m_mapData.password
				self:signUp(username,password)
			end
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
--
-- void BmobUser::loginByAccount(string mebileNumber,string pwd,BmobLoginDelegate* delegate){
-- 	if (mebileNumber.empty() || pwd.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	this->m_url = BmobSDKInit::LOGIN_URL  + "?username=" + \
-- 					mebileNumber + "&password=" + pwd;
-- 	this->clear();
--
-- 	/**
-- 	* save user
-- 	*/
-- 	CCUserDefault::sharedUserDefault()->setStringForKey("user_name",mebileNumber);
-- 	CCUserDefault::sharedUserDefault()->setStringForKey("user_pwd",pwd);
--
-- 	_opType = HTTP_OP_Type::_bHTTP_LOGIN;
--
-- 	this->m_pLoginDelegate = delegate;
--
--
-- 	this->send(network::HttpRequest::Type::GET);
--
-- }
--
-- void BmobUser::loginBySMSCode(string mebileNumber,string code,BmobLoginDelegate* delegate){
-- 	if (mebileNumber.empty() || code.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	this->m_url = BmobSDKInit::LOGIN_URL  + "?mobilePhoneNumber=" + \
-- 					mebileNumber + "&smsCode=" + code;
-- 	this->clear();
--
-- 	/**
-- 	* save user
-- 	*/
-- 	// CCUserDefault::sharedUserDefault()->setStringForKey("user_name",mebileNumber);
-- 	// CCUserDefault::sharedUserDefault()->setStringForKey("user_pwd",pwd);
--
-- 	_opType = HTTP_OP_Type::_bHTTP_LOGIN;
--
-- 	this->m_pLoginDelegate = delegate;
--
--
-- 	this->send(network::HttpRequest::Type::GET);
--
-- }
--
-- void BmobUser::signOrLoginByMobilePhone(string mebileNumber,string code,BmobLoginDelegate* delegate){
-- 	this->loginBySMSCode(mebileNumber,code,delegate);
-- }
--
-- void BmobUser::update(string objectId,BmobUpdateDelegate* delegate){
-- 	if (objectId.empty())
--     {
--         /* code */
--         return ;
--     }
--      _opType = HTTP_OP_Type::_bHTTP_UPDATE;
--     this->m_pUpdateDelegate = delegate;
--
--     this->m_url =  BmobSDKInit::USER_URL;
--
--     string session ;
-- 	if (m_session.empty())
-- 	{
-- 		/* code */
-- 		session = CCUserDefault::sharedUserDefault()->getStringForKey("user_session");
-- 	}else{
-- 		session = m_session;
-- 	}
--
--     this->setSession(session);
--
--     if (!objectId.empty())
--     {
--         /* code */
--         this->m_url += + "/" + objectId;
--     }
--
--     this->send(network::HttpRequest::Type::PUT);
-- }
--
-- void BmobUser::update(BmobUpdateDelegate* delegate){
-- 	this->update(this->getObjectId(),delegate);
-- }
--
-- void BmobUser::resetPasswordByEmail(string email,BmobResetPasswordDelegate* delegate){
-- 	if (email.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	_opType = HTTP_OP_Type::_bHTTP_RESET;
-- 	this->m_pResetDelegate = delegate;
-- 	this->m_url = BmobSDKInit::RESET_URL + "?";
--
-- 	this->clear();
--
-- 	this->enParamsToHttp("email",CCString::createWithFormat("%s",email.c_str()));
--
-- 	this->send();
-- }
--
-- void BmobUser::requestSMSCode(string meblieNumber,string template_name,BmobRequestSMSCodeDelegate* delegate){
-- 	if (meblieNumber.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	_opType = HTTP_OP_Type::_bHTTP_REQUEST_CODE;
-- 	this->m_pRequestSMSCodeDelegate = delegate;
-- 	this->m_url = BmobSDKInit::REQUEST_SMS_CODE_URL + "?";
--
-- 	this->clear();
--
-- 	this->enParamsToHttp("mobilePhoneNumber",CCString::createWithFormat("%s",meblieNumber.c_str()));
-- 	if (!template_name.empty())
-- 	{
-- 		/*code */
-- 		this->enParamsToHttp("template",CCString::createWithFormat("%s",template_name.c_str()));
-- 	}
--
-- 	this->send();
-- }
--
-- void BmobUser::resetPasswordBySMSCode(string pw,string code,BmobResetPasswordByCodeDelegate* delegate){
-- 	if (pw.empty() || code.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	_opType = HTTP_OP_Type::_bHTTP_RESET_BY_CODE;
-- 	this->m_pResetByMSMCodeDelegate = delegate;
-- 	this->m_url = BmobSDKInit::RESET_BY_CODE_URL + "/" + code;
--
-- 	this->clear();
--
-- 	CCUserDefault::sharedUserDefault()->setStringForKey("user_pwd",pw);
--
-- 	this->enParamsToHttp("password",CCString::createWithFormat("%s",pw.c_str()));
--
-- 	this->send(network::HttpRequest::Type::PUT);
-- }
--
-- void BmobUser::updateCurrentUserPassword(string old_pwd,string new_pwd,BmobUpdateDelegate* delegate){
-- 	if (old_pwd.empty() || new_pwd.empty() || m_objectId.empty())
-- 	{
-- 		/* code */
-- 		return ;
-- 	}
--
-- 	this->m_pUpdateDelegate = delegate;
-- 	_opType = HTTP_OP_Type::_bHTTP_UPDATE;
--
-- 	string session ;
-- 	if (m_session.empty())
-- 	{
-- 		/* code */
-- 		CCUserDefault::sharedUserDefault()->getStringForKey("user_session");
-- 	}else{
-- 		session = m_session;
-- 	}
-- 	this->setSession(session);
--
-- 	this->clear();
--
-- 	this->m_url = BmobSDKInit::UPDATE_PWD_URL + "/" + m_objectId;
--
-- 	CCUserDefault::sharedUserDefault()->setStringForKey("user_pwd",new_pwd);
--
-- 	this->enParamsToHttp("oldPassword",CCString::createWithFormat("%s",old_pwd.c_str()));
-- 	this->enParamsToHttp("newPassword",CCString::createWithFormat("%s",new_pwd.c_str()));
--
-- 	this->send(network::HttpRequest::Type::PUT);
-- }
--
-- void BmobUser::requestEmailVerify(string email,BmobEmailVerifyDelegate* delegate){
-- 	if (email.empty())
-- 	{
-- 		/* code */
-- 		return  ;
-- 	}
--
-- 	this->m_pEmailVerifyDelegate = delegate;
-- 	_opType = HTTP_OP_Type::_bHTTP_EMAIL_VERIFY;
--
-- 	this->m_url = BmobSDKInit::EMAIL_VERIFY_URL;
--
-- 	this->clear();
--
-- 	this->enParamsToHttp("email",CCString::createWithFormat("%s",email.c_str()));
--
-- 	this->send();
-- }

return BmobUser
