local BetAreaView = class("BetAreaView",function()
    return display.newNode()
end)

local logger = wq.Logger.new("BetAreaView")

local myCoinFromPos = {display.cx - 320 * rl.widthScale + 5,60-205}--{{display.cx - 210 * rl.widthScale - 50, 55-210},{display.cx - 210 * rl.widthScale + 110, 55},{display.cx - 210 * rl.widthScale + 220, 55}}
local robotCoinFromPos = {
                            {display.cx + 430, display.cy + 140},
                            {display.cx + 430, display.cy - 30},
                            {display.cx - 72 * rl.widthScale, display.cy + 250},
                            {display.cx + 102 * rl.widthScale, display.cy + 250},
                            {display.cx + 276 * rl.widthScale, display.cy + 250}}

function BetAreaView:ctor()
    self:setupView()
    self.isBig = false --是否已经放大

    self.robotChips = {}
    self.robotChipsCount = 0
end

function BetAreaView:setupView()
    self.bg = display.newSprite("#bet_area.png"):addTo(self)
    self.bg:setTouchEnabled(true)
    self.bg:setTouchSwallowEnabled(true)
    self.bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(self, self.onTouch_))
    self:initTouchNodes()
    self:initHightLights()
end

--自身点击事件
function BetAreaView:onTouch_(event)
    -- if wq.TouchHelper.CLICK  == eventName then
    -- elseif wq.TouchHelper.BEGAN == eventName then
    -- elseif wq.TouchHelper.MOVED == eventName then
    -- elseif wq.TouchHelper.ENDED == eventName then
    -- end

    -- dump(event)
    if event.name  == "began" then
        if self.isBig == false then
            self:getParent():getParent():getParent():betAreaZoomIn()
            return false
        end
        self.touchBeganX = event.x
        self.touchBeganY = event.y
        self.clickCanceled = false
        if not self:checkTouchInSprite_(event.x, event.y) then return false end
        self.isMoved_ = false
        self:checkTouchNode_(event.x ,event.y)
        -- local nodePoint = self:convertToNodeSpace(cc.p(event.x ,event.y))
        -- print("nodePoint.x = "..nodePoint.x..", nodePoint.y = "..nodePoint.y)
        return true
    elseif event.name  == "moved" then
        self.isMoved_ = true
        self:checkTouchNode_(event.x ,event.y)
    elseif event.name  == "ended" or event.name  == "canceled" then
        self:setHightLight()

        --当前是否已经放大为下注模式
        if self.isBig == false then
        else
            if self:checkTouchInSprite_(event.x, event.y) then
                self:onBet_(event.x ,event.y)
            else
            end
        end
    end
end

function BetAreaView:checkTouchInSprite_(x, y)
    return self.bg:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end

--初始化点击节点
function BetAreaView:initTouchNodes()
    print("BetAreaView:initTouchNodes_()")
    self.touchNodes_ = {}
    for i = 1, 157 do
        self.touchNodes_[i] = display.newNode():size(1,1):pos(rl.data.betArea.touchPos[i].x,rl.data.betArea.touchPos[i].y):addTo(self.bg)
    end
    --设置node大小
    self.touchNodes_[1]:size(48,169)
    for i = 2,145 do self.touchNodes_[i]:size(33,33) end
    for i = 146,148 do self.touchNodes_[i]:size(67,67) end
    for i = 149,151 do self.touchNodes_[i]:size(270,57) end
    for i = 152,157 do self.touchNodes_[i]:size(133,91) end
end

--初始化触摸高亮下注区域
function BetAreaView:initHightLights()
    print("BetAreaView:initHightLights()")
    self.hightLights = {}
    self.hightLights[1] = display.newSprite("#hight_light1.png"):pos(rl.data.betArea.highLightPos[1].x,rl.data.betArea.highLightPos[1].y):addTo(self.bg):hide()
    for i = 2 , 40 do
        self.hightLights[i] = display.newSprite("#hight_light2.png"):pos(rl.data.betArea.highLightPos[i].x,rl.data.betArea.highLightPos[i].y):addTo(self.bg):hide()
    end
    for i = 41 , 43 do
        self.hightLights[i] = display.newSprite("#hight_light3.png"):pos(rl.data.betArea.highLightPos[i].x,rl.data.betArea.highLightPos[i].y):addTo(self.bg):hide()
    end
    for i = 44 , 49 do
        self.hightLights[i] = display.newSprite("#hight_light4.png"):pos(rl.data.betArea.highLightPos[i].x,rl.data.betArea.highLightPos[i].y):addTo(self.bg):hide()
    end
end

--检测是否在点击区域内
function BetAreaView:checkTouchNode_(x,y)
    for i = 1, #self.touchNodes_ do
        if self.touchNodes_[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
            self:setHightLight(i)
            break
        end
    end
end

function BetAreaView:getDetalPos(i)
    local detalX, detalY = 0,0
    local randomX,randomY = 0,0
    if i == 1 then
        detalX, detalY = 35,85
        randomX = math.random(-5, 5)
        randomY = math.random(-60, 60)
    elseif i >= 2 and i <= 145 then
        detalX, detalY = 16,16
        randomX = math.random(-5, 5)
        randomY = math.random(-5, 5)
    elseif i >= 146 and i <= 148 then
        detalX, detalY = 35,32
        randomX = math.random(-17, 17)
        randomY = math.random(-15, 15)
    elseif i >= 149 and i <= 151 then
        detalX, detalY = 133,38
        randomX = math.random(-80, 80)
        randomY = math.random(-15, 15)
    elseif i >= 152 and i <= 157 then
        detalX, detalY = 67,47
        randomX = math.random(-40, 40)
        randomY = math.random(-20, 20)
    end

    detalX, detalY = detalX + randomX,detalY + randomY
    return detalX,detalY
end

--在坐标点内下注
function BetAreaView:onBet_(x,y)
    if rl.userData.money < GameManager.betValue then
        rl.ui.Tips.new({string = wq.LangTool.getText("COMMON","NOT_ENOUGH_MONEY")}):show()
        return
    end

    for i = 1, #self.touchNodes_ do
        if self.touchNodes_[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
            local detalX, detalY = self:getDetalPos(i)

            GameManager.myChipsCount = GameManager.myChipsCount + 1
            GameManager.myChips[GameManager.myChipsCount] = display.newSprite("#chip_blue.png")
                                            :scale(0.5)
                                            :pos(myCoinFromPos[1], myCoinFromPos[2])
                                            :addTo(self.bg)
            GameManager.myChipsValue[GameManager.myChipsCount] = GameManager.betValue
            GameManager.myNodeIdx[GameManager.myChipsCount] = i

            local value = GameManager.betValue
            if value > 1000000 then
                value = (value/1000000).."M"
            elseif value > 1000 then
                value = (value/1000).."K"
            end
            label = cc.ui.UILabel.new({font = "tahoma",text = value, size = 30,  color = rl.data.color.white})
            :align(cc.ui.TEXT_ALIGN_CENTER)
            :pos(39,39)
            :addTo(GameManager.myChips[GameManager.myChipsCount])

            rl.SoundManager:playSounds(rl.SoundManager.chip)
            GameManager.myChips[GameManager.myChipsCount]:runAction(cc.MoveTo:create(0.5,cc.p(rl.data.betArea.touchPos[i].x + detalX, rl.data.betArea.touchPos[i].y + detalY)))

            GameManager:onBet(i)
            break
        end
    end
end

function BetAreaView:onRebet()
    for i = 1, GameManager.myChipsCount do
        GameManager.myChips[i] = display.newSprite("#chip_blue.png")
                                        :scale(0.5)
                                        :pos(myCoinFromPos[1], myCoinFromPos[2])
                                        :addTo(self.bg)

        local value = GameManager.myChipsValue[i]

        local idx = GameManager.myNodeIdx[i]

        local detalX, detalY = self:getDetalPos(idx)

        GameManager.curBet[idx] = GameManager.curBet[idx] + value
        if value > 1000000 then
            value = (value/1000000).."M"
        elseif value > 1000 then
            value = (value/1000).."K"
        end
        label = cc.ui.UILabel.new({font = "tahoma",text = value, size = 30,  color = rl.data.color.white})
        :align(cc.ui.TEXT_ALIGN_CENTER)
        :pos(39,39)
        :addTo(GameManager.myChips[i])

        rl.SoundManager:playSounds(rl.SoundManager.chip)
        GameManager.myChips[i]:runAction(cc.MoveTo:create(0.5,cc.p(rl.data.betArea.touchPos[idx].x + detalX, rl.data.betArea.touchPos[idx].y + detalY)))
    end
end

function BetAreaView:onRobotBet(chairId,betIdx,chipValue)
    self.robotChipsCount = self.robotChipsCount + 1
    local chipIdx = self.robotChipsCount

    local betPos = self.bg:convertToNodeSpace(cc.p(robotCoinFromPos[chairId][1], robotCoinFromPos[chairId][2]))
    self.robotChips[chipIdx] = display.newSprite("#chip_purple.png")
                                :scale(0.5)
                                :pos(betPos.x, betPos.y)
                                :addTo(self.bg)

    local detalX, detalY = self:getDetalPos(betIdx)


    if chipValue > 1000000 then
        chipValue = (chipValue/1000000).."M"
    elseif chipValue > 1000 then
        chipValue = (chipValue/1000).."K"
    end
    label = cc.ui.UILabel.new({font = "tahoma",text = chipValue, size = 30,  color = rl.data.color.white})
    :align(cc.ui.TEXT_ALIGN_CENTER)
    :pos(39,39)
    :addTo(self.robotChips[chipIdx])

    rl.SoundManager:playSounds(rl.SoundManager.chip)
    self.robotChips[chipIdx]:runAction(
    cc.MoveTo:create(0.5,cc.p(rl.data.betArea.touchPos[betIdx].x + detalX, rl.data.betArea.touchPos[betIdx].y + detalY)))
end

function BetAreaView:removeMyChips()
    for i = 1, GameManager.myChipsCount do
        GameManager.myChips[i]:removeSelf()
        GameManager.myChipsValue[i] = 0
    end
    GameManager.myChipsCount = 0
end

function BetAreaView:removeRobotChips()
    for i = 1, self.robotChipsCount do
        self.robotChips[i]:removeSelf()
    end
    self.robotChipsCount = 0
end

function BetAreaView:setHightLight(touchId)

    for i = 1, #self.hightLights do
        self.hightLights[i]:hide()
    end
    if not touchId then return end
    local highLightId = rl.data.betArea.point2HightLight[touchId]
    -- print("touchId = "..touchId)
    -- dump(highLightId)
    for _,v in ipairs(highLightId)do
        self.hightLights[v+1]:show()
    end
end

return BetAreaView
