--
-- Author: viking@iwormgame.com
-- Date: 2015-06-10 20:38:17
--
local RechargeComponManager = class("RechargeComponManager")

local GooglePayRechargeCompon = import("app.module.recharge.components.GooglePayRechargeCompon")
local ApplePayRechargeCompon = import("app.module.recharge.components.ApplePayRechargeCompon")

local RechargeType = import(".RechargeType")

function RechargeComponManager:ctor()
	self.rechargeCompons = {}
	if device.platform == "android" then
		self.rechargeCompons[RechargeType.GooglePay] = GooglePayRechargeCompon
	elseif device.platform == "ios" then
		self.rechargeCompons[RechargeType.ApplePay] = ApplePayRechargeCompon
	elseif device.platform == "windows" then

	end
end

function RechargeComponManager.getInstance()
	if not RechargeComponManager.singleInstance then
		RechargeComponManager.singleInstance = RechargeComponManager.new()
	end
	return RechargeComponManager.singleInstance
end

function RechargeComponManager:getCompon(componId)
	return self.rechargeCompons[componId]
end

function RechargeComponManager:init(configs)
	for k,v in pairs(configs) do
		local RechargeComponClass_ = self.rechargeCompons[v.id]
		if RechargeComponClass_ then
			local rechargeComponInstance_ = self.rechargeCompons[v.id]
			if not rechargeComponInstance_ then
				rechargeComponInstance_ = RechargeComponClass_.new()
				self.rechargeCompons[v.id] = rechargeComponInstance_
			end

			rechargeComponInstance_:init(v)
		end
	end
end

function RechargeComponManager:dispose()
	for id, compon in pairs(self.rechargeCompons) do
		compon:dispose()
	end
end

return RechargeComponManager
