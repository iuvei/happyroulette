--
-- Author: viking@iwormgame.com
-- Date: 2015-06-17 11:18:13
--
local RechargeComponentBase = import(".RechargeComponentBase")
local ApplePayRechargeCompon = class("ApplePayRechargeCompon", RechargeComponentBase)

local RechargeHelper = import("app.module.recharge.utils.RechargeHelper")
local isSandBox = true

function ApplePayRechargeCompon:ctor()
	ApplePayRechargeCompon.super.ctor(self, "ApplePayRechargeCompon")

	self.store_ = require("framework.cc.sdk.Store")
	self.store_.init(handler(self, self.onPayCallback_))
	self.store_.setReceiptVerifyMode(cc.CCStoreReceiptVerifyModeNone, isSandBox)

	self.isSupported_ = false
	self.goods = nil
	self.canUpdateGoodsPrice = false
	self.isLoadingGoods = false

	self.rechargeHelper_ = RechargeHelper.new("ApplePayRechargeCompon")
end

function ApplePayRechargeCompon:onLoadGoods_(evt)
	self.logger:log("onLoadGoods_")
	self.isLoadingGoods = false

	local goods = evt.products
	if goods and #goods > 0 then
		rl.appleGoodList = goods

		local getPriceSymbol = function(price, priceLocale)
			return luaoc.callStaticMethod("CommonFunctions", "getPriceSymbol", {price = price, priceLocale = priceLocale})
		end
		local getCurrencySymbol = function(priceLocale)
			return luaoc.callStaticMethod("CommonFunctions", "getCurrencySymbol", {priceLocale = priceLocale})
		end

		for _, good in ipairs(goods) do
	        self.logger:log("onLoadGoods_ "..good.productIdentifier)

	        if self.goods then

	        	if self.goods.coins then
					for _, coin in pairs(self.goods.coins) do
						if coin.gid == good.productIdentifier then
							-- self.logger:log("productIdentifier:"..good.productIdentifier..",price:"..good.price..",priceLocale:"..good.priceLocale)

							local ok, priceSymbol = getPriceSymbol(good.price, good.priceLocale)
							if ok then
								coin.priceSymbol = 	priceSymbol
							end

							if good.price ~= 0 then
								coin.price = good.price
							end

							local ok, symbol = getCurrencySymbol(good.priceLocale)
							if ok then
								coin.symbol = symbol
							end
						end
					end
	        	end

	        	if self.goods.diamonds then
					for _, diamond in pairs(self.goods.diamonds) do
						if diamond.gid == good.productIdentifier then
							-- self.logger:log("productIdentifier:"..good.productIdentifier..",price:"..good.price..",priceLocale:"..good.priceLocale)

							local ok, priceSymbol = getPriceSymbol(good.price, good.priceLocale)
							if ok then
								diamond.priceSymbol = 	priceSymbol
							end

							if good.price ~= 0 then
								diamond.price = good.price
							end

							local ok, symbol = getCurrencySymbol(good.priceLocale)
							if ok then
								diamond.symbol = symbol
							end
						end
					end
	        	end
	        end
	    end

    	self.canUpdateGoodsPrice = true
		self:loadingGoods()
	else
		rl.appleGoodList = nil
		self.logger:log("onLoadGoods_:failed")
		self:loadGoodsCallback_("failed", true, "failed")
	end
end

function ApplePayRechargeCompon:onRecharge_(transaction, succ)
	self.logger:log("onRecharge_")
	if succ then
		self:onNotifyDelivery(transaction, true)
	else
		if transaction then
			self.store_.finishTransaction(transaction)
		end
		if self.rechargeCallback_ then
			rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "rechargeFail"))
			self.rechargeCallback_("failed")
		end
	end
end

--需要发货
function ApplePayRechargeCompon:onDelivery_(transaction)
	self:onNotifyDelivery(transaction, false)
end

function ApplePayRechargeCompon:onPayCallback_(evt)
	local transaction = evt.transaction

	if transaction.state then
		self.logger:log("onPayCallback_ state:"..transaction.state)
		-- dump(transaction)
	end
	self.logger:log("onPayCallback_")
	if transaction.state == "purchased" then
		self:onRecharge_(transaction, true)
	elseif transaction.state == "failed" then
		self:onRecharge_(transaction, false)
	elseif transaction.state == "restored" then
		self:onDelivery_(transaction)
	else
		self:onRecharge_(transaction, false)
	end
end

function ApplePayRechargeCompon:onNotifyDelivery(data, showTips)
	--todo php发货 结束交易
	self:deliveryFunc(data, showTips)
end

local retryTimes = 3
function ApplePayRechargeCompon:deliveryFunc(transaction, showTips)
	local transactionIdentifier = transaction.transactionIdentifier
	local receipt = crypto.encodeBase64(transaction.receipt)

	self.logger:log("finishTransaction id:"..transaction.transactionIdentifier..",receipt:"..transaction.receipt..",productIdentifier:"..transaction.productIdentifier)
	wq.HttpService.PostUrl(self.config.deliveryUrl, {gid = transaction.productIdentifier, receipt = receipt, payListId = self.config.id}, function(data)
		self.logger:log("delivery back data:"..data)
		local retData = json.decode(data)
		if retData.ret == 0 then
			rl.userData.money = retData.money or rl.userData.money
			rl.userData.diamond = retData.diamond or rl.userData.diamond

			retryTimes = 3
			self.store_.finishTransaction(transaction)
			if showTips then
				rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "deliverySucc"))
				if self.rechargeCallback_ then
					self.rechargeCallback_("success")
				end
			end
		else
			retryTimes = retryTimes - 1
			if retryTimes > 0 then
				rl.schedulerFactory:delayGlobal(function()
					self:deliveryFunc(payData, showTips)
				end, 5)
			elseif showTips then
				rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "deliveryFail"))
				if self.rechargeCallback_ then
					self.rechargeCallback_("failed")
				end
			end
		end
	end, function()
		retryTimes = retryTimes - 1
		if retryTimes > 0 then
			rl.schedulerFactory:delayGlobal(function()
				self:deliveryFunc(payData, showTips)
			end, 5)
		elseif showTips then
			rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "deliveryFail"))
			if self.rechargeCallback_ then
				self.rechargeCallback_("failed")
			end
		end
	end, true)
end

function ApplePayRechargeCompon:cacheCallback_(isCached, configContent)
	if isCached then
		self.logger:log("cacheCallback_ isCached: true,configContent:"..configContent)
		self.goods = self.rechargeHelper_:getGoods(configContent)
		self.canUpdateGoodsPrice = false
		self:loadingGoods()
	else
 		self.logger:log("cacheCallback_ load failed.")
 		self:loadGoodsCallback_("failed", true)
	end
end

function ApplePayRechargeCompon:loadGoodsCallback_(typed, isLoaded, data)
	self.logger:log("ApplePayRechargeCompon:loadGoodsCallback_ typed:"..typed)
	if (typed == "coin" or typed == "failed") and self.loadCoinCallback_ then
		self.loadCoinCallback_(self.config, isLoaded, data)
	end

	if (typed == "diamond" or typed == "failed") and self.loadDiamondCallback_ then
		self.loadDiamondCallback_(self.config, isLoaded, data)
	end
end

function ApplePayRechargeCompon:init(config)
	self.config = config

	self.isSupported_ = self.store_.canMakePurchases()
	if self.isSupported_ then
		self.logger:log("isSupported: true")
	else
		self.logger:log("isSupported: false")
	end

	-- self:loadingGoods()--todo delete
	self.store_.restore()

	--todo load goods
	if not self.goods then
		self.rechargeHelper_:cache(config.configUrl, handler(self, self.cacheCallback_))
	end
end

function ApplePayRechargeCompon:loadCoinList(callback)
	self.loadCoinCallback_ = callback
	self:loadingGoods()
end

function ApplePayRechargeCompon:loadDiamondList(callback)
	self.loadDiamondCallback_ = callback
	self:loadingGoods()
end

function ApplePayRechargeCompon:loadingGoods()
	self.logger:log("loadingGoods")
	if not self.goods then
		self.logger:log("loadingGoods nil")
		self.rechargeHelper_:cache(self.config.configUrl, handler(self, self.cacheCallback_))
	end

	if self.isSupported_ then
		self.logger:log("loadingGoods2")
		if self.loadCoinCallback_ or self.loadDiamondCallback_ then
			self.logger:log("loadingGoods3")
			if self.goods then
				self.logger:log("loadingGoods4")
				if self.canUpdateGoodsPrice then
					self.logger:log("loadingGoods5")
					self.rechargeHelper_:updateGoodsPrice(self.goods, self.config)

					self:loadGoodsCallback_("coin", true, self.goods.coins)
					self:loadGoodsCallback_("diamond", true, self.goods.diamonds)
				elseif not self.isLoadingGoods then
					self.logger:log("load goods from app store....")
					self.isLoadingGoods = true
					-- self:loadGoodsCallback_("failed", false)
					--所有物品的id
					if rl.appleGoodList then--避免重新load
						self.logger:log("load goods from app store...1.")
						self:onLoadGoods_(rl.appleGoodList)
					else
						self.logger:log("load goods from app store...2")
						local goodList = self.goods.skus--{"com.iwromgame.runningpig.coin450k", "com.iwromgame.runningpig.coin200k"}
						-- self.logger:log("load goods from app store.goodList:"..goodList)
						-- dump(goodList)
						self.store_.loadProducts(goodList, handler(self, self.onLoadGoods_))
					end
				end
			else
				self.logger:log("loadingGoods6")
				self:loadGoodsCallback_("failed", false)
			end
		end
	else
		self:loadGoodsCallback_("failed", false)
	end
end

--商品id
function ApplePayRechargeCompon:recharge(id, callback)
	self.logger:log("id:"..id)
	self.rechargeCallback_ = callback
	self.store_.purchase(id)
end

function ApplePayRechargeCompon:editBoxAdjust(editbox1, editbox2, commitButton)
	-- body
end

--商品类型goodsType
function ApplePayRechargeCompon:onEditBoxData(goodsType, editbox1, editbox2, commitButton, callback)
	-- body
end

function ApplePayRechargeCompon:dispose()
	self.isSupported_ = false
end

return ApplePayRechargeCompon
