local RechargeItem = class("RechargeItem", wq.ui.ListItemBase)

local paddingX = 8
local paddingY = 8
RechargeItem.WIDTH = 554
RechargeItem.HEIGHT = 106 + paddingY

local logger = wq.Logger.new("RechargeItem")

function RechargeItem:ctor(listView)
    self:setNodeEventEnabled(true)
	RechargeItem.super.ctor(self, listView)
	self:setupView()
end

function RechargeItem:setupView()
    self.bg = display.newScale9Sprite("#recharge_item_bg.png")
            :size(RechargeItem.WIDTH - paddingX * 2, RechargeItem.HEIGHT - paddingY)
            :pos(0,0)
            :addTo(self, -1)
    -- wq.TouchHelper.new(self.bg, handler(self, self.onClick_), false, false)
end

function RechargeItem:onDataChanged(data)

    local money = data.money
    local price = data.price

    --排名标志
    local idx = self:getIdx()
    local flagSrc = "#recharge_item_"..idx..".png"
    local flag = display.newSprite(flagSrc):addTo(self.bg,1):pos(77,63)

    cc.ui.UILabel.new({font = "tahoma",text = "x "..money, size = 30,  color = rl.data.color.white}):addTo(flag):pos(146,30)


	local label = cc.ui.UILabel.new({font = "tahoma",text = "$ "..price, size = 26,  color = rl.data.color.black})
	self.buyBtn = wq.ui.WQPushButton.new({normal = "#common_btn.png"}, {scale9 = true,capInsets = cc.rect(9, 32, 2, 2)})
		:setButtonSize(146, 64)
		:pos(150,-4)
		:addTo(self)
		:setButtonLabel(label)
		:onButtonClicked(buttonHandler(self, self.onBuyBtnClick))
   rl.ButtonHelper:onClickAnimation(self.buyBtn)

end

function RechargeItem:onBuyBtnClick(event)
    logger:log("click idx = "..event.target:getTag())
    wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.RECHARGE_CLICK, id = self:getIdx()})
    -- SKU_LIST

end

-- function RechargeItem:onClick_(target, eventName)
--     if not self.data_.last then
--         if wq.TouchHelper.CLICK  == eventName then
--         elseif wq.TouchHelper.BEGAN  == eventName then
--             transition.scaleTo(self.bg, {time = 0.05, scale = 0.95})
--         elseif wq.TouchHelper.ENDED  == eventName then
--             transition.scaleTo(self.bg, {time = 0.05, scale = 1})
--         end
--     end
-- end

function RechargeItem:onCleanup()
end

return RechargeItem
