local HallView = class("HallView", function()
    return display.newNode()
end)

local TopBar = import("app.module.hall.views.TopBar")
local BottomBar = import("app.module.hall.views.BottomBar")
local RankView = import("app.module.hall.rank.RankView")
local SignInView = import("app.module.hall.signin.SignInView")

local logger = wq.Logger.new("HallView")

function HallView:ctor()
    self:setNodeEventEnabled(true)
    self:setupView()
end

function HallView:setupView()
    --加载
    display.addSpriteFrames("hall.plist", "hall.png",handler(self,self.onTextureComplete_))

end

function HallView:onTextureComplete_()
    self:showView()
end

function HallView:showView()
    logger:log("showView")
    --背景墙纸
    self.floorBatch = display.newBatchNode("common.png"):addTo(self):pos(-670,0)
    self.floorSp = {}
    for i = 1, 50 do
        self.floorSp[i] =  display.newSprite("#room_floor.png"):addTo(self.floorBatch):pos(199*(math.floor((i-1)/5)),199*((i-1)%5))
    end

    --顶部栏
    self.topBar = TopBar.new():addTo(self):pos(display.cx,display.top - 44)

    --底部栏
    self.bottomBar = BottomBar.new():addTo(self):pos(display.cx + 195 * rl.widthScale,display.bottom + 60)

    --排行榜
    self.RankView = RankView.new():addTo(self):pos(display.cx - 265 * rl.widthScale, display.cy - 50)

    --签到
    local btnLabelSign = cc.ui.UILabel.new({font = "tahoma",text = "sign", size = 24,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    btnLabelSign:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnSign = cc.ui.UIPushButton.new({normal = "#btn_sign.png"})
        :pos(display.cx + 55,display.cy + 147)
        :addTo(self)
        :setButtonLabel(btnLabelSign)
        :setButtonLabelOffset(0, -50)
        :onButtonClicked(buttonHandler(self,self.onSignInClick))
    rl.ButtonHelper:onClickAnimation(self.btnSign)

    --老虎机
    local btnLabelSlot = cc.ui.UILabel.new({font = "tahoma",text = "slot", size = 24,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    btnLabelSlot:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnSlot = cc.ui.UIPushButton.new({normal = "#btn_slot.png"})
        :pos(display.cx + 215,display.cy + 147)
        :addTo(self)
        :setButtonLabel(btnLabelSlot)
        :setButtonLabelOffset(0, -50)
        :onButtonClicked(function()
            rl.userData.money = rl.userData.money + 1000
            -- local node = cc.ui.UILabel.new({text = "是否退出游戏", size = 36,  color = cc.c3b(233,217,184)})
            -- node:setAnchorPoint(0.5,0.5)
			-- rl.ui.CommonDialog.new({size = cc.size(540,360), hasConfirm = 1, hasCancel = 1})
			-- :addContent(node)
			-- :setConfirmCallback(handler(self,self.onConfirm))
    		-- :show()
        end)
    rl.ButtonHelper:onClickAnimation(self.btnSlot)

    --占卜
    local btnLabelAugury = cc.ui.UILabel.new({font = "tahoma",text = "augury", size = 24,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    btnLabelAugury:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnAugury = cc.ui.UIPushButton.new({normal = "#btn_augury.png"})
        :pos(display.cx + 375,display.cy + 147)
        :addTo(self)
        :setButtonLabel(btnLabelAugury)
        :setButtonLabelOffset(0, -50)
        :onButtonClicked(function()
            end)
    rl.ButtonHelper:onClickAnimation(self.btnAugury)

    --开打
    self.btnPlay = cc.ui.UIPushButton.new({normal = "#btn_play.png"})
        :pos(display.cx + 200 * rl.widthScale,display.cy -53)
        :addTo(self)
        :onButtonClicked(buttonHandler(self,self.onPlayClick))
    rl.ButtonHelper:onClickAnimation(self.btnPlay)
end

function HallView:onSignInClick()
    SignInView.new():show()
end

function HallView:onPlayClick()
    GameManager:init()
    cc.Director:getInstance():pushScene(import("app.scenes.RoomScene").new())
    -- local param = {}
    -- param.objectId = rl.userData.objectId
    -- logger:log("param.objectId = "..param.objectId)
    -- bmob.execCloud("getRoomId",param,"EXEC_EXEC")

    -- local params = {money = rl.userData.money}
    -- rl.Native:callCloud("getRoomId",params,function(data)
    --     logger:log("data = "..data)
    --     local retData = json.decode(data)
    --     logger:log("retData.ret = "..retData.ret)
    --     if retData.ret == 0  then
    --         logger:log("1")
    --         self:onGetRoomId(retData.objectId)
    --     else
    --         logger:log("2")
    --         rl.ui.Tips.new({string = retData.err}):show()
    --     end
    -- end)
end

function HallView:onGetRoomId(roomId)
    logger:log("roomId = "..roomId)
    local params = {objectId = roomId}
    rl.Native:callRealTime(params,function(data)
        dump(data)
        local retData = json.decode(data)
        if retData.ret == 0  then
            dump(retData)
        else
            rl.ui.Tips.new({string = retData.err}):show()
        end
    end)

end

function HallView:onEnter()
    self.RankView:updateRank()
end

function HallView:onCleanup()
    display.removeSpriteFramesWithFile("hall.plist", "hall.png")
end

return HallView
