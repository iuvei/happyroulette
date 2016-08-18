local RechargeHelper = class("RechargeHelper")

local GooglePayRechargeCompon = import("app.module.hall.recharge.components.GooglePayRechargeCompon")
-- local ApplePayRechargeCompon = import("app.module.hall.recharge.components.ApplePayRechargeCompon")


function RechargeHelper:ctor()
	self.logger = wq.Logger.new("RechargeHelper")
	self.googleGoodList = {"com.roulette.chip1000","com.roulette.chip10000","com.roulette.chip50000","com.roulette.chip10000"}
	self:initPayCompon()
end

function RechargeHelper:initPayCompon()
	if device.platform == "android" then
		self.component = GooglePayRechargeCompon.new(self)
	elseif device.platform == "ios" then
		-- self.component = ApplePayRechargeCompon.new(self)
	else
		return
	end

	self.component:init()
end

function RechargeHelper:recharge(id,callback)
	dump(self.googleGoodList)
	local sku = self.googleGoodList[id]
	self.logger:log("recharge sku = "..sku)
	self.component:recharge(sku,callback)
end


return RechargeHelper
