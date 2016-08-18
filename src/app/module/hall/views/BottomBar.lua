local BottomBar = class("BottomBar", function()
	return display.newNode()
end)

function BottomBar:ctor()
    self:setupView()
end

function BottomBar:setupView()
    self.bg = display.newScale9Sprite("#hall_bottom_bar.png",0, 0, cc.size(505, 60)):addTo(self)

    -- 邮件
	local btnLabelEmail = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("HALL","EMAIL"), size = 22,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    -- btnLabelEmail:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnEmail = cc.ui.UIPushButton.new({normal = "#btn_email.png"})
		:pos(-505/8*3,35)
		:addTo(self)
        :setButtonLabel(btnLabelEmail)
        :setButtonLabelOffset(0, -45)
		:onButtonClicked()
	rl.ButtonHelper:onClickAnimation(self.btnEmail)

    -- 成就
	local btnLabelAchi= cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("HALL","ACHI"), size = 22,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    -- btnLabelEmail:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnAchi = cc.ui.UIPushButton.new({normal = "#btn_achi.png"})
		:pos(-505/8,35)
		:addTo(self)
        :setButtonLabel(btnLabelAchi)
        :setButtonLabelOffset(0, -45)
		:onButtonClicked()
	rl.ButtonHelper:onClickAnimation(self.btnAchi)

    -- 免费活动
	local btnLabelFree = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("HALL","FREE"), size = 22,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    -- btnLabelEmail:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnFree = cc.ui.UIPushButton.new({normal = "#btn_free.png"})
		:pos(505/8,35)
		:addTo(self)
        :setButtonLabel(btnLabelFree)
        :setButtonLabelOffset(0, -45)
		:onButtonClicked()
	rl.ButtonHelper:onClickAnimation(self.btnFree)

    -- 商店
	local btnLabelRecharge = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("HALL","RECHARGE"), size = 22,  color = rl.data.color.white})
    -- btnLabel:enableOutline(rl.data.color.black, 4)
    -- btnLabelEmail:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))
    self.btnRecharge = cc.ui.UIPushButton.new({normal = "#btn_shop.png"})
		:pos(505/8*3,35)
		:addTo(self)
        :setButtonLabel(btnLabelRecharge)
        :setButtonLabelOffset(0, -45)
		:onButtonClicked(buttonHandler(self,self.onRechargeClick))
	rl.ButtonHelper:onClickAnimation(self.btnRecharge)
end

function BottomBar:onRechargeClick()
	import("app.module.hall.recharge.RechargeView").new():show()
end

return BottomBar
