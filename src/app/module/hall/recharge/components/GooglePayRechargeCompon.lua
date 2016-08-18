--
-- Author: viking@iwormgame.com
-- Date: 2015-06-10 15:46:12
--
local RechargeComponentBase = import(".RechargeComponentBase")
local GooglePayRechargeCompon = class("GooglePayRechargeCompon", RechargeComponentBase)

function GooglePayRechargeCompon:ctor(helper)
	GooglePayRechargeCompon.super.ctor(self, "GooglePayRechargeCompon")

	if device.platform == "android" then
		self.callStaticMethod_ = self:callStaticMethod("com/lzstudio/googlepay/GooglePayJavaBridge")
		self.callStaticMethod_("setDeliveryCallback", {handler(self, self.onDelivery_)}, "(I)V")
	else
		-- self.callStaticMethod_ = function(javaMethodName, javaParams, javaMethodSig)
		-- 	if javaMethodName == "startSetup" then
		-- 		self:onSetup_("true")
		-- 	elseif javaMethodName == "loadingGoods" then
		-- 		self:onLoadGoods_([[ [{"sku":"com.iwromgame.runningpig.coin200k", "priceSymbol":"$0.99", "price":"0.99", "symbol":"$"}] ]])
		-- 	elseif javaMethodName == "recharge" then
		-- 		self:onRecharge_([[{"sku":"com.iwromgame.runningpig.coin200k", "originalJson":"{}", "signature":""}]])
		-- 	end
		-- end
	end

	self.isSetuped_ = false
	self.isSetuping_ = false
	self.isSupported_ = false
	self.goods = nil
	self.isLoadingGoods = false

	self.rechargeHelper_ = helper
end

function GooglePayRechargeCompon:onSetup_(result)
	self.logger:log("onSetup_:"..result)
	self.isSetuping_ = false
	self.isSetuped_ = true
	self.isSupported_ = (result == "true")

	self:loadingGoods()
end

--从google play 拉取商品结束
function GooglePayRechargeCompon:onLoadGoods_(result)
	self.logger:log("onLoadGoods_:"..result)
	self.isLoadingGoods = false
	--更新商品信息
	if result ~= "failed" then
		self.hasLoadGoods = true
		self.logger:log("onLoadGoods_:success")
	else
		self.logger:log("onLoadGoods_:failed")
		self:loadGoodsCallback_("failed", true, "failed")
	end
end

--充值结果
function GooglePayRechargeCompon:onRecharge_(result)
	self.logger:log("onRecharge_"..result)
	local success = (result ~= "failed" and result ~= "canceled")

	if success then
		rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "rechargeSucc"))
		local resultData = json.decode(result)
		self:onNotifyDelivery(resultData, true)
	elseif result == "failed" then
		rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "rechargeFail"))
		self.rechargeCallback_("failed")
	elseif result == "canceled" then
		rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "rechargeCancel"))
		self.rechargeCallback_("canceled")
	end
end

--发货
function GooglePayRechargeCompon:onDelivery_(result)
	self.logger:log("onDelivery_:"..result)
	local resultData = json.decode(result)
	self:onNotifyDelivery(resultData)
end

function GooglePayRechargeCompon:onNotifyDelivery(payData, showTips)
	--todo php 发货 then 消费掉sku
	self:deliveryFunc(payData, showTips)
end

local retryTimes = 3
function GooglePayRechargeCompon:deliveryFunc(payData, showTips)
	local sku = payData.sku
	local originalJson = payData.originalJson
	local signature = payData.signature

	self.logger:log("sku:"..sku..",originalJson:"..originalJson..",signature:"..signature)
	-- wq.HttpService.PostUrl(self.config.deliveryUrl, {sku = sku, originalJson = originalJson, signature = signature, payListId = self.config.id}, function(data)
	-- 	self.logger:log("dlivery back data:"..data)
	-- 	local retData = json.decode(data)
	-- 	if retData.ret == 0 then
	-- 		rl.userData.money = retData.money
	-- 		rl.userData.diamond = retData.diamond
	--
	-- 		retryTimes = 3
	-- 		self.callStaticMethod_("consume", {handler(self, self.onConsume_), sku}, "(ILjava/lang/String;)V")
	-- 		if showTips then
	-- 			rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "deliverySucc"))
	-- 			if self.rechargeCallback_ then
	-- 				self.rechargeCallback_("success")
	-- 			end
	-- 		end
	-- 	else
	-- 		retryTimes = retryTimes - 1
	-- 		if retryTimes > 0 then
	-- 			rl.schedulerFactory:delayGlobal(function()
	-- 				self:deliveryFunc(payData, showTips)
	-- 			end, 5)
	-- 		elseif showTips then
	-- 			rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "deliveryFail"))
	-- 			if self.rechargeCallback_ then
	-- 				self.rechargeCallback_("failed")
	-- 			end
	-- 		end
	-- 	end
	-- end, function()
	-- 	retryTimes = retryTimes - 1
	-- 	if retryTimes > 0 then
	-- 		rl.schedulerFactory:delayGlobal(function()
	-- 			self:deliveryFunc(payData, showTips)
	-- 		end, 5)
	-- 	elseif showTips then
	-- 		rl.TopTipsManager:insert(wq.LangTool.getText("RECHARGE", "deliveryFail"))
	-- 		if self.rechargeCallback_ then
	-- 			self.rechargeCallback_("failed")
	-- 		end
	-- 	end
	-- end, true)
end

function GooglePayRechargeCompon:onConsume_(result)
	self.logger:log("onConsume_:"..result)
end

function GooglePayRechargeCompon:loadGoodsCallback_(typed, isLoaded, data)
	self.logger:log("GooglePayRechargeCompon:loadGoodsCallback_ typed:"..typed)
end

----------------------------------以下为继承成员函数-------------------------------

function GooglePayRechargeCompon:init()
	local ok, ret = self.callStaticMethod_("isSetuped", {}, "()Ljava/lang/String;")
	if ok then
		self.isSetuped_ = (ret == "true")
	end

	ok, ret = self.callStaticMethod_("isSupported", {}, "()Ljava/lang/String;")
	if ok then
		self.isSupported_ = (ret == "true")
	end

	if not self.isSetuped_ then
		self.logger:log("setuping")
		self.isSetuping_ = true
		self.callStaticMethod_("startSetup", {handler(self, self.onSetup_)}, "(I)V")
	end
end

function GooglePayRechargeCompon:loadingGoods()
	self.logger:log("loadingGoods")
	if self.isSetuped_ then
		self.logger:log("loadingGoods1")
		if self.isSupported_ then
			self.logger:log("load goods from google play....")
			self.isLoadingGoods = true
			-- self:loadGoodsCallback_("failed", false)
			--所有物品的id
			if self.hasLoadGoods then--避免重新load
				self.logger:log("load goods from google play...1.")
				self:onLoadGoods_(self.rechargeHelper_.googleGoodList)
			else
				self.logger:log("load goods from google play....2")
				local goodList = table.concat(self.rechargeHelper_.googleGoodList, ",")	--{"com.roulette.chip1000","com.roulette.chip10000","com.roulette.chip50000","com.roulette.chip10000"}
				self.logger:log("load goods from google play.goodList:"..goodList)
				self.callStaticMethod_("loadingGoods", {handler(self, self.onLoadGoods_), goodList}, "(ILjava/lang/String;)V")
			end
		end
	elseif not self.isSetuping_ then
		self.isSetuping_ = true
		self:loadGoodsCallback_("failed", false)
		self.callStaticMethod_("startSetup", {handler(self, self.onSetup_)}, "(I)V")
	end
end

--商品id
function GooglePayRechargeCompon:recharge(sku, callback)
	retryTimes = 3
	self.rechargeCallback_ = callback
	local extraData = {uid = tostring(rl.userData.username), sku = sku}
	self.callStaticMethod_("recharge", {handler(self, self.onRecharge_), json.encode(extraData)}, "(ILjava/lang/String;)V")
end

function GooglePayRechargeCompon:editBoxAdjust(editbox1, editbox2, commitButton)
	-- body
end

--商品类型goodsType
function GooglePayRechargeCompon:onEditBoxData(goodsType, editbox1, editbox2, commitButton, callback)
	-- body
end

function GooglePayRechargeCompon:dispose()
	self.isSetuped_ = false
	self.isSetuping_ = false
	self.isSupported_ = false
	self.goods = nil
	self.isLoadingGoods = false

	self.callStaticMethod_("dispose", {}, "()V")
end

return GooglePayRechargeCompon
