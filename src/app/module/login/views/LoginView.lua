local LoginView = class("LoginView", function()
	return display.newNode()
end)

local logger = wq.Logger.new("LoginView")
local LoginController = import("app.module.login.LoginController")

local animTime = 0.2
local textSize = 32
local textColor = cc.c3b(255, 231, 73)
local rewardFrameRotation = 12

function LoginView:ctor()
	-- self.loginController_  = LoginController.new(self)
	self:setNodeEventEnabled(true)
	self:setupView()
end

function LoginView:setupView()
	--加载
	display.addSpriteFrames("login.plist", "login.png",handler(self,self.onTextureComplete_))
end

function LoginView:onTextureComplete_()
	self:showView()
end

function LoginView:showView()
	-- self.floorBatch = display.newBatchNode("common.png"):addTo(self):pos(-670,0)
	-- self.floorSp = {}
	-- for i = 1, 50 do
	-- 	self.floorSp[i] =  display.newSprite("#room_floor.png"):addTo(self.floorBatch):pos(199*(math.floor((i-1)/5)),199*((i-1)%5))
	-- end

	display.newSprite("bg_login.jpg"):addTo(self):pos(display.cx,display.cy):scale(rl.bgScale)

	display.newSprite("#logo.png"):addTo(self):pos(display.cx + 14,display.cy + 80* rl.heightScale)

	local loginLabel = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("LOGIN","LOGIN"), size = 40,  color = rl.data.color.white})
	self.loginBtn = wq.ui.WQPushButton.new({normal = "#btn_login.png"}, {scale9 = true,capInsets = cc.rect(50, 45, 1, 1)})
		:setButtonSize(250, 83)
		:pos(display.cx,display.cy - 180*rl.heightScale)
		:addTo(self)
		:setButtonLabel(loginLabel)
		:onButtonClicked(buttonHandler(self, self.onLoginButtonClick_))
	rl.ButtonHelper:onClickAnimation(self.loginBtn)

	-- local signUplabel = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("LOGIN","SIGNUP"), size = 40,  color = rl.data.color.white})
	-- self.signUpBtn = wq.ui.WQPushButton.new({normal = "#btn_login.png"}, {scale9 = true,capInsets = cc.rect(50, 45, 1, 1)})
	-- 	:setButtonSize(200, 83)
	-- 	:pos(display.cx + 200,display.cy - 180*rl.heightScale)
	-- 	:addTo(self)
	-- 	:setButtonLabel(signUplabel)
	-- 	:onButtonClicked(buttonHandler(self, self.onSignButtonClick_))
	-- rl.ButtonHelper:onClickAnimation(self.signUpBtn)
end

function LoginView:onSignButtonClick_()
		local uniqID = rl.Native:getLoginId()
		bmob.BmobUser:signUp(uniqID,"666666")
		rl.Native:bmob("register",function(data)
			local retData = json.decode(data)
			dump(retData)
			if retData.ret == 0 then
				self:onLogin(retData)
			else
				logger:log("retData.err = "..retData.err)
				rl.ui.Tips.new({string = retData.err}):show()
			end
		end)
end

function LoginView:onLoginButtonClick_()
	-- rl.ButtonHelper:shielding(self.loginBtn, 5)

	local uniqID = rl.Native:getLoginId()
	-- bmob.BmobUser:login(uniqID,"666666")

	local param = {}
	param.username = uniqID
	bmob.execCloud("login",param,"EXEC_EXEC",function(data)
		local retData = json.decode(data.result)
		-- dump(retData)
		if retData.code then
			rl.ui.Tips.new({string = "errCode = "..retData.code}):show()
			return
		end
		wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)
		rl.userData.icon  = retData.icon or ""
		self.m_session    = retData.sessionToken

		if display.getRunningScene() ~= "HallScene" then
			app:enterScene("HallScene")
		end
	end)

	-- bmob.BmobUser:login("liu2","666666")
	-- display.addSpriteFrames("hall.plist", "hall.png", function()
	-- 	app:enterScene("HallScene")
	-- end)
end

function LoginView:onLogin(retData)
	wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)
	rl.userData.icon = retData.icon or ""
	rl.userData.money = retData.money or 0
	rl.userData.exp = retData.exp or 0
	display.addSpriteFrames("hall.plist", "hall.png", function()
		app:enterScene("HallScene")
	end)
end

function LoginView:onCleanup()
	display.removeSpriteFramesWithFile("login.plist", "login.png")
	rl.schedulerFactory:delayGlobal(function()
		cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end, 0.1)
end

return LoginView
