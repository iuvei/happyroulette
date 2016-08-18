local DialogBase = rl.ui.DialogBase
local RechargeView = class("RechargeView",DialogBase)

local RechargeItem   = import("app.module.hall.recharge.RechargeItem")
local RechargeHelper = import("app.module.hall.recharge.RechargeHelper")

local WIDTH,HEIGHT = 624,544

function RechargeView:ctor()
    RechargeView.super.ctor(self, cc.size(WIDTH,HEIGHT))
    self.rechargeHelper = RechargeHelper.new()
    self.rechargeHandlerId = wq.EventDispatcher:addEventListener(rl.EventKeys.RECHARGE_CLICK, handler(self, self.onRechargeClick))
    self.logger = wq.Logger.new("RechargeView")
end

function RechargeView:onRechargeClick(event)
    self.rechargeHelper:recharge(event.id,handler(self,self.onRecharge))
end

function RechargeView:onRecharge(result)
    self.logger:log(result)
end

function RechargeView:onShowed()

    display.newSprite("#recharge_title.png"):addTo(self):pos(-WIDTH/2 + 84,HEIGHT/2 + 12)

    self.title =  cc.ui.UILabel.new({font = "tahoma",
        text = wq.LangTool.getText("HALL","SHOP"),
        size = 36,
        color = cc.c3b(233,217,184)})
        :align (cc.ui.TEXT_ALIGN_CENTER)
        :pos(20,HEIGHT/2 - 25)
        :addTo(self)

    local split = display.newScale9Sprite("#dialog_split_icon.png", 0, HEIGHT/2 - 55,
        cc.size(WIDTH - 10, 2)):addTo(self)

    self:initListView()
    self:addCloseButton()
end

function RechargeView:initListView()
	local listWidth, listHeight = 568, 448
    self.list = wq.ui.ListViewBase.new({
        viewRect = cc.rect(0, 0, listWidth, listHeight),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        async = false,
    }, RechargeItem)
    :addTo(self):pos(-listWidth/2 , -listHeight/2 - 16)
    local data = {{money = 1000,price = 1},{money = 10000,price = 10},{money = 50000,price = 48},{money = 100000,price = 88}}
	self.list:setData(data)
end

function RechargeView:onCleanup()
    wq.EventDispatcher:removeEventListener(self.rechargeHandlerId)
end

return RechargeView
