local DeskView = class("DeskView",function()
    return display.newNode()
end)
local BetAreaView = import(".BetAreaView")
local CountTimer = import(".CountTimer")
local ZOOM_ANIM_TIME = 0.3



function DeskView:ctor()
    GameManager:setDeskView(self)
    self:setupView()
end

function DeskView:setupView()
    -- 桌子
    self.bg = display.newSprite("#roulette_desk.png"):addTo(self)
    self.bg:setAnchorPoint(0.7,0.5)

    -- 盘子
    display.newSprite("#pan0.png"):addTo(self.bg):pos(272,270)
    self.pan1 = display.newSprite("#pan1.png"):addTo(self.bg):pos(272,270)
    local pan2 = display.newSprite("#pan2.png"):addTo(self.bg):pos(272,270)
    self.pan3 = display.newSprite("#pan3.png"):addTo(self.bg):pos(272,270)

    self.ballRound = display.newSprite("#pan1.png"):addTo(self.bg):pos(272,270)
    self.ballRound:setOpacity(0)
    -- 球
    self.ball = display.newSprite("#roulette_ball.png"):addTo(self.ballRound):pos(240,40)

    -- 桌布
    self.deskFlowerBatch = display.newBatchNode("room.png"):addTo(self.bg):pos(490,0)
    self.deskFlowerSp = {}
    for i = 1, 15*15 do
        self.deskFlowerSp[i] = display.newSprite("#desk_grid.png"):addTo(self.deskFlowerBatch):pos(99*(math.floor((i-1)/15)),99*((i-1)%7)):opacity(0)
    end

    -- 投注面
    self.betAreaView = BetAreaView.new():addTo(self.bg,1):pos(970,285):scale(0.8)

    -- 历史记录
    -- self.historyNode  = display.newNode():addTo(self.betAreaView.bg)
    self.historyBg = display.newScale9Sprite("#desk_dark_bg.png", 295,  -38, cc.size(360, 50), cc.rect(62/2, 50/2, 1, 1)):addTo(self.betAreaView.bg)
    self:updateHistory()
    wq.TouchHelper.new(self.historyBg, function(target, eventName)
        if wq.TouchHelper.CLICK  == eventName then
            import("app.module.room.views.HistoryDlg").new():show()
        end
    end, true, true)

    -- 总注
    -- self.totalBetNode = display.newNode():addTo(self.betAreaView.bg)
    self.totalBetBg = display.newScale9Sprite("#desk_dark_bg.png", 666, -38, cc.size(288, 50), cc.rect(62/2, 50/2, 1, 1)):addTo(self.betAreaView.bg)
    self.totalBetLabel = cc.ui.UILabel.new({font = "tahoma",text = "TOTAL BET：0", size = 25,  color = rl.data.color.yellow})
    :align(display.CENTER)
    :addTo(self.totalBetBg):pos(144,25)
    self.totalBetLabel:enableOutline(rl.data.color.black,4)

    -- 计时器
    self.countTimer = CountTimer.new():addTo(self.betAreaView):pos(462,-220)--:scale(0.7)
end

function DeskView:updateView(data)
    self.countTimer:updateView(data)
end

function DeskView:updateHistory()
    self.historyBg:removeAllChildren()
    local resTable = GameData.gameResult or {}
    local showTale = {}

    if #resTable > 7 then
        for i = #resTable - 6,#resTable do
            showTale[i + 7 - #resTable] = resTable[i]
        end
    else
        showTale = resTable
    end

    for i = 1, #showTale do
        local num = showTale[i]
        local src = ""
        if rl.isInTable(RED_NUM,num) then
            src = "#history_red.png"
        elseif rl.isInTable(BLACK_NUM,num) then
            src = "#history_black.png"
        else
            src = "#history_green.png"
        end

        local ball = display.newSprite(src):addTo(self.historyBg):pos(50*i - 18,23)
        local labelNum = cc.ui.UILabel.new({font = "tahoma",text = num, size = 23,  color = rl.data.color.white}):align(display.CENTER):addTo(ball):pos(23,25)
    end
end

function DeskView:roll(rotation,onRollEnd)
    self.pan1:setRotation(0)
    self.pan3:setRotation(0)
    self.ballRound:setRotation(0)
    self.ball:pos(240,40)

    local random = math.random(0,360)
    local rotate1 = -360 * 3 + random
    local rotate2 = 360 * 3 + random + rotation

    rl.SoundManager:playSounds(rl.SoundManager.roll)
    self.pan1:runAction(cc.EaseIn:create(cc.RotateBy:create(5,rotate1),2))
    self.pan3:runAction(cc.EaseIn:create(cc.RotateBy:create(5,rotate1),2))
    self.ballRound:runAction(cc.EaseInOut:create(cc.RotateBy:create(4,rotate2),2))

    rl.schedulerFactory:delayGlobal(function()
        self.pan1:runAction(cc.EaseOut:create(cc.RotateBy:create(4,-360),2))
        self.pan3:runAction(cc.EaseOut:create(cc.RotateBy:create(4,-360),2))
        self.ballRound:runAction(cc.EaseInOut:create(cc.RotateBy:create(5,-360),2))
    end, 5)

    rl.schedulerFactory:delayGlobal(function()
        rl.SoundManager:playSounds(rl.SoundManager.rollstop)
    end, 11.3)

    local ballAction = cc.Sequence:create(cc.EaseInOut:create(cc.MoveBy:create(9,cc.p(0,50)),1),cc.MoveBy:create(2.5,cc.p(0,39))
        ,cc.MoveBy:create(0.1,cc.p(0,-5)),cc.MoveBy:create(0.2,cc.p(0,5))
        ,cc.MoveBy:create(0.1,cc.p(0,-2)),cc.MoveBy:create(0.1,cc.p(0,2)))

    transition.execute(self.ball,ballAction,{onComplete = function()
        onRollEnd()
    end})
end

-- 投注区域放大
function DeskView:betAreaZoomIn()
    if GameManager.gameStatus == GAME_STATUS_ROLLING then
		return
	end
    rl.SoundManager:playSounds(rl.SoundManager.switch)
    for i = 1, 15*15 do
        self.deskFlowerSp[i]:show()
        self.deskFlowerSp[i]:runAction(cc.FadeIn:create(ZOOM_ANIM_TIME))
    end

    self.betAreaView.isBig = true
    self.betAreaView:setTouchEnabled(false)
    local spawn = cc.Spawn:create(cc.ScaleTo:create(ZOOM_ANIM_TIME,0.96),cc.MoveTo:create(ZOOM_ANIM_TIME,cc.p(1020,360)))
    transition.execute(self.betAreaView,spawn,{onComplete = function() self.betAreaView:setTouchEnabled(true) end})
end

-- 投注区域缩小
function DeskView:betAreaZoomOut()
    rl.SoundManager:playSounds(rl.SoundManager.switch)
    for i = 1, 15*15 do
        self.deskFlowerSp[i]:runAction(cc.FadeOut:create(ZOOM_ANIM_TIME))
    end
    self.betAreaView.isBig = false
    self.betAreaView:setTouchEnabled(false)
    local spawn = cc.Spawn:create(cc.ScaleTo:create(ZOOM_ANIM_TIME,0.8),cc.MoveTo:create(ZOOM_ANIM_TIME,cc.p(970,285)))
    transition.execute(self.betAreaView,spawn,{onComplete = function() self.betAreaView:setTouchEnabled(true) end})
end

return DeskView
