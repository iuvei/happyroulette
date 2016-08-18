local DialogBase = rl.ui.DialogBase
local SignInView = class("SignInView",DialogBase)
local RechargeItem = import("app.module.hall.recharge.RechargeItem")
local WIDTH,HEIGHT = 780,510
local values = {1000,2000,3000,5000,7000,9000,15000}
local curDay =  0

local logger = wq.Logger.new("logger")

function SignInView:ctor()
    SignInView.super.ctor(self, cc.size(WIDTH,HEIGHT))
    curDay = os.date("*t",os.time()).day
end

function SignInView:onShowed()
    self.title =  cc.ui.UILabel.new({font = "tahoma",
        text = wq.LangTool.getText("HALL","DAILY_SIGN_IN"),
        size = 36,
        color = cc.c3b(233,217,184)})
        :align (cc.ui.TEXT_ALIGN_CENTER)
        :pos(0,HEIGHT/2 - 25)
        :addTo(self)

    local split = display.newScale9Sprite("#dialog_split_icon.png", 0, HEIGHT/2 - 55,
        cc.size(WIDTH - 10, 2)):addTo(self)

    self:addCloseButton()
    self:setupView()
end

function SignInView:setupView()

    local signInDay = rl.userData.signInDay or 0
    local signInDate = rl.userData.signInDate or 0

    local src1 = "#sign_bg1.png"
    local src2 = "#sign_bg2.png"
    self.signInNodes = {}

    for i = 1, 7 do
        local posX = 0
        local posY = 0

        local src = src1
        if  i <= signInDay then
            src = src2
        end

        if i < 5 then
            posX = 108 + 190*(i-1)
            posY = 333
            self.signInNodes[i] = display.newSprite(src):addTo(self.bg):pos(posX,posY)
        else
            posX = 200 + 190*(i-5)
            posY = 120
            self.signInNodes[i] = display.newSprite(src):addTo(self.bg):pos(posX,posY)
        end

        if  i <= signInDay then
            display.newSprite("#sign_checked.png"):addTo(self.signInNodes[i],1):pos(75,80)
        end

        local iconSrc = "#recharge_item_1.png"
        if i <= 3 then
            iconSrc = "#recharge_item_1.png"
        elseif i >= 4 and i <= 6 then
            iconSrc = "#recharge_item_2.png"
        elseif i == 7 then
            iconSrc = "#recharge_item_3.png"
        end

        display.newSprite(iconSrc):addTo(self.signInNodes[i]):pos(81,88)

        cc.ui.UILabel.new({font = "tahoma",text = "Day "..i, size = 24,  color = rl.data.color.white})
        :align(display.CENTER):addTo(self.signInNodes[i]):pos(81,164)
        cc.ui.UILabel.new({font = "tahoma",text = values[i], size = 24,  color = rl.data.color.black})
        :align(display.CENTER):addTo(self.signInNodes[i]):pos(81,20)

        if i == signInDay + 1 and signInDate ~= curDay then
            wq.TouchHelper.new(self.signInNodes[i], handler(self, self.onClick_), false, false)
        end
    end
end

function SignInView:onClick_(target, eventName)
    if wq.TouchHelper.CLICK  == eventName then
        for i = 1, 7 do
            if target == self.signInNodes[i] then
                self.touchIdx = i
                local param = {username = rl.userData.username}
                bmob.execCloud("signIn",param,"EXEC_EXEC",handler(self, self.onSignIn))
                break
            end
        end
    elseif wq.TouchHelper.BEGAN  == eventName then
        transition.scaleTo(target, {time = 0.05, scale = 0.95})
    elseif wq.TouchHelper.ENDED  == eventName then
        transition.scaleTo(target, {time = 0.05, scale = 1})
    end
end

function SignInView:onSignIn(data)
    local retData = json.decode(data.result)
    logger:log("retData.ret = "..retData.ret)

    if retData.ret == 0 or retData.ret == "0" then
        logger:log(1)
        rl.userData.money = rl.userData.money + values[self.touchIdx]
        rl.userData.signInDate = curDay
        rl.userData.signInDay = self.touchIdx
        display.newSprite("#sign_checked.png"):addTo(self.signInNodes[self.touchIdx],1):pos(75,80)
        self.signInNodes[self.touchIdx]:setTouchEnabled(false)
        self.signInNodes[self.touchIdx]:setSpriteFrame(display.newSpriteFrame("sign_bg2.png"))
        rl.ui.Tips.new({string = ""..values[self.touchIdx]}):show()
    else
        logger:log(2)
        rl.ui.Tips.new({string = "Fail to get reward !"}):show()
    end
end

return SignInView
