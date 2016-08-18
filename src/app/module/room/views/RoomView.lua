local RoomView = class("RoomView",function()
    return display.newNode()
end)

local DeskView    = import(".DeskView")
local ResultView  = import(".ResultView")
local TabButton   = import(".TabButton")
local UserHead    = import(".UserHead")
local RoomNetwork = import("app.module.room.RoomNetwork")

function RoomView:ctor()
    self:setNodeEventEnabled(true)

    self.network = RoomNetwork.new()
    GameManager:setRoomView(self)
    GameManager:setNetwork(self.network)
    self:setupView()
    GameManager:onEnterRoom()
end

function RoomView:setupView()
    -- 地板砖
    self.floorBatch = display.newBatchNode("common.png"):addTo(self):pos(-670,0)
    self.floorSp = {}
    for i = 1, 50 do
        self.floorSp[i] =  display.newSprite("#room_floor.png"):addTo(self.floorBatch):pos(199*(math.floor((i-1)/5)),199*((i-1)%5))
    end

    -- 桌子
    self.deskView = DeskView.new():addTo(self):pos(display.cx - 20 * rl.widthScale,display.cy + 10)
    -- 荷官
    self.dealer = display.newSprite("#dealer.png"):pos(display.cx - 245 * rl.widthScale,display.cy + 260):addTo(self)

    -- 结算框
    self.resultView = ResultView.new():addTo(self,1):pos(-96,125)--:pos(120,125)

    -- 聊天按钮
    self.btnChat = cc.ui.UIPushButton.new({normal="#btn_chat.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click)end)
        :pos(display.cx - 410 * rl.widthScale, display.bottom + 50)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnChat)
    -- 返回按钮
    self.btnBack = cc.ui.UIPushButton.new({normal="#btn_room_back.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click)
                            local node = cc.ui.UILabel.new({text = wq.LangTool.getText("COMMON", "QUITLAYER_TIPS3"), size = 36,  color = cc.c3b(233,217,184)})
                            node:setAnchorPoint(0.5,0.5)
                            rl.ui.CommonDialog.new({size = cc.size(540,360), hasConfirm = 1, hasCancel = 1})
                            :addContent(node)
                            :setConfirmCallback(function()
                                GameManager:undoAll()
                                GameManager:dispose()
                                cc.Director:getInstance():popScene()
                            end)
                            :show()
                        end)
        :pos(display.left + 60, display.top - 60)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnBack)
    -- 充值按钮
    self.btnRecharge = cc.ui.UIPushButton.new({normal="#btn_recharge.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click)end)
        :pos(display.right - 60, display.top - 60)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnRecharge)

    -- 用户头像
    self.userHead    = {}
    self.myUserHead  = UserHead.new({commitSide = 0}):addTo(self):pos(display.cx - 320 * rl.widthScale, display.bottom + 60):setMoney(rl.userData.money) --自己
    self.userHead[1] = UserHead.new({commitSide = 1}):addTo(self):pos(display.cx + 430, display.cy + 140):hide()
    self.userHead[2] = UserHead.new({commitSide = 1}):addTo(self):pos(display.cx + 430, display.cy - 30):hide()
    self.userHead[3] = UserHead.new({commitSide = 0}):addTo(self):pos(display.cx - 72 * rl.widthScale, display.cy + 250):hide()
    self.userHead[4] = UserHead.new({commitSide = 0}):addTo(self):pos(display.cx + 102 * rl.widthScale, display.cy + 250):hide()
    self.userHead[5] = UserHead.new({commitSide = 0}):addTo(self):pos(display.cx + 276 * rl.widthScale, display.cy + 250):hide()

    wq.TouchHelper.new(self.myUserHead, function(target, eventName)
        if wq.TouchHelper.CLICK  == eventName then
        end
    end, false, true)

    if rl.userData.icon ~= "" then
        self.myGetterId = rl.ImageGetter:getImage(rl.userData.icon, function(success, texture)
            if success then
                self.myUserHead:setTexture(texture, 1)
            end
        end, rl.ImageGetter.CACHE_TYPE_HEAD)
    end

    --默认 （100万以内）
    local labelSrc = {"#label_1k.png","#label_5k.png","#label_10k.png"}
    self.tabBetValue = {1000,5000,10000}
    if rl.userData.money > 1000000 and rl.userData.money <= 10000000 then --大于100万 <=1000万
        self.tabBetValue = {1000,10000,50000 }
    elseif rl.userData.money > 10000000 and rl.userData.money <= 50000000 then --大于1000万 小于5000万
        self.tabBetValue = {10000,50000,100000}
    elseif rl.userData.money > 50000000 then
        self.tabBetValue = {10000,100000,1000000}
    end

    GameManager.betValue = self.tabBetValue[1] --当前单注的额度

    -- local tabs = self.tabBtn:getTabs()
    -- for i = 1,3 do
    --     display.newSprite(labelSrc[i]):addTo(tabs[i]):pos(0,0)
    -- end

    local labelTab = {}
    local labelSize = 24
    for i = 1,3 do
        local value = self.tabBetValue[i]
        if value > 1000000 then
            value = (value/1000000).."M"
        elseif value > 1000 then
            value = (value/1000).."K"
        end
        labelTab[i] = cc.ui.UILabel.new({font = "tahoma",text = value, size = labelSize,  color = rl.data.color.white})
        labelTab[i]:enableOutline(cc.c3b(50,80,6), 3)
    end

    -- 选择筹码大小
    self.tabBtn = TabButton.new({
        isVertical  = false,
        num         = 3,
        tabFrontSrc = "#chip_blue.png",
        tabBackSrc  = "#chip_blue.png",
        tabWidth    = 110,
        padding     = 0,
        labels = labelTab,
    })
        :setCallback(handler(self,self.onTabChanged))
        :pos(display.cx - 200 * rl.widthScale, display.bottom + 55)
        :addTo(self)


    -- 撤销一步按钮
    self.btnUndoOne = cc.ui.UIPushButton.new({normal="#btn_undo_one.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click) GameManager:undoOne()end)
        :pos(display.cx + 230 * rl.widthScale, display.bottom + 50)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnUndoOne)


    -- 撤销全部按钮
    self.btnUndoAll = cc.ui.UIPushButton.new({normal="#btn_undo_all.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click) GameManager:undoAll()end)
        :pos(display.cx + 130 * rl.widthScale, display.bottom + 50)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnUndoAll)

    -- 续压按钮
    self.btnRebet = cc.ui.UIPushButton.new({normal="#btn_rebet.png"})
        :onButtonClicked(function()rl.SoundManager:playSounds(rl.SoundManager.btn_click) GameManager:rebet()end)
        :pos(display.cx + 330 * rl.widthScale, display.bottom + 50)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnRebet)

    -- 确认按钮
    self.btnConfirm = cc.ui.UIPushButton.new({normal="#btn_confirm.png"})
        :onButtonClicked(function()
            rl.SoundManager:playSounds(rl.SoundManager.btn_click)
            GameManager:onCommit(true)
            self:setBetBtnsEnabled(false)
            self:betAreaZoomOut()
        end)
        :pos(display.cx + 430 * rl.widthScale, display.bottom + 50)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.btnConfirm)

    -- 缩放按钮
    self.btnZoomOut = cc.ui.UIPushButton.new({normal="#btn_zoom_out.png"})
        :onButtonClicked(handler(self,self.betAreaZoomOut))
        :pos(display.cx - 410 * rl.widthScale, display.bottom + 150)
        :addTo(self)
        :opacity(0)
    self.btnZoomOut:setButtonEnabled(false)
    rl.ButtonHelper:onClickAnimation(self.btnZoomOut)
end

function RoomView:setBetBtnsEnabled(enable)
    self.btnUndoOne:setButtonEnabled(enable)
    self.btnUndoAll:setButtonEnabled(enable)
    self.btnRebet:setButtonEnabled(enable)
    self.btnConfirm:setButtonEnabled(enable)
    local color = cc.c3b(180,180,180)
    if enable then
        color = cc.c3b(255,255,255)
    end
    self.btnUndoOne:setColor(color)
    self.btnUndoAll:setColor(color)
    self.btnRebet:setColor(color)
    self.btnConfirm:setColor(color)
end

function RoomView:updateView(data)
    self.deskView:updateView(data)
end

function RoomView:onCallRobot(robot)
    local chairId = robot.chairId
    if self.deskView.betAreaView.isBig == false then
        self.userHead[chairId]:show()
    end
    self.userHead[chairId]:setMoney(robot.money)
    if robot.icon ~= "" then
        local gettId = rl.ImageGetter:getImage(robot.icon, function(success, texture)
            if success then
                self.userHead[chairId]:setTexture(texture, 1)
            end
        end, rl.ImageGetter.CACHE_TYPE_HEAD)
    end
end

function RoomView:onTabChanged(idx)
    GameManager.betValue = self.tabBetValue[idx]
    GameManager.betTabIdx = idx
end

function RoomView:showResultView(result)
    self.resultView:setResult(result)
    local action  = cc.MoveTo:create(0.3,cc.p(120,125))
    transition.execute(self.resultView,action,{easing = "backout",onComplete = function()
        rl.schedulerFactory:delayGlobal(function()
            self:moveToDesk()
            self:hideResultView()
            GameManager:newGame()
        end,2)
    end})
end

function RoomView:hideResultView()
    self.resultView:pos(-96,125)
end

function RoomView:moveToPlate()
    self.myUserHead:hide()

    for i = 1, 5 do
        -- if not v.isEmpty then
            self.userHead[i]:hide()
        -- end
    end

    self.floorBatch:runAction(cc.MoveBy:create(0.2,cc.p(760,0)))

    transition.execute(self.deskView,cc.MoveBy:create(0.2,cc.p(760,0)),{onComplete = function()
        GameManager:onRoll()
    end})

    self.btnUndoOne:hide()
    self.btnUndoAll:hide()
    self.btnRebet:hide()
    self.btnConfirm:hide()
    self.tabBtn:hide()
    self.btnChat:hide()
    self.dealer:hide()
end

function RoomView:moveToDesk()
    self.myUserHead:show()

    local robot = GameManager.robot
    for k,v in ipairs(robot) do
        if v.isEmpty == 0 then
            self.userHead[v.chairId]:show()
        end
    end

    self.floorBatch:runAction(cc.MoveBy:create(0.2,cc.p(-760,0)))
    self.deskView:runAction(cc.MoveBy:create(0.2,cc.p(-760,0)))
    self.btnUndoOne:show()
    self.btnUndoAll:show()
    self.btnRebet:show()
    self.btnConfirm:show()
    self.tabBtn:show()
    self.btnChat:show()
    self.dealer:show()
end

function RoomView:betAreaZoomIn()
    for i=1,5 do
        self.userHead[i]:hide()
    end

    self.btnBack:hide()
    self.btnRecharge:hide()
    self.dealer:hide()
    self.deskView:betAreaZoomIn()

    self.btnZoomOut:runAction(cc.FadeIn:create(0.3))
    self.btnZoomOut:setButtonEnabled(true)
end

function RoomView:betAreaZoomOut()
    local robot = GameManager.robot
    for k,v in ipairs(robot) do
        if v.isEmpty == 0 then
            self.userHead[v.chairId]:show()
        end
    end

    self.btnBack:show()
    self.btnRecharge:show()
    self.dealer:show()
    self.deskView:betAreaZoomOut()

    self.btnZoomOut:runAction(cc.FadeOut:create(0.3))
    self.btnZoomOut:setButtonEnabled(false)
end

function RoomView:onCleanup()
    self:removeAllChildren()

    if self.myGetterId then
        rl.ImageGetter:cancelTaskById(self.myGetterId)
        self.myGetterId = nil
    end
    GameManager:dispose()
end

return RoomView
