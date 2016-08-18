local RechargeController = class("RechargeController")

local RechargeComponManager = import("app.module.recharge.utils.RechargeComponManager")

local logger = wq.Logger.new("RechargeController")

function RechargeController:ctor(view)
    if view then
        self.view_ = view
    end
    self.mgr = RechargeComponManager.getInstance()

    self.rechargeHandlerId = wq.EventDispatcher:addEventListener(rl.EventKeys.ITEM_RECHARGE, handler(self, self.handlerRecharge_))
end

function RechargeController:handlerRecharge_(evt)
    --todo
    local payCompon = self.view_:getSelectedPayCompon()

    local id = evt.id
    logger:log("id:"..id)
    local compon = self:getRechargeCompon(payCompon.id)
    compon:recharge(id, handler(self, self.rechargeCallback_))
end

function RechargeController:rechargeCallback_(result)
    logger:log("rechargeCallback_:"..result)
    local success = (result ~= "failed" or result ~= "canceled")
end

function RechargeController:init()
    self:getConfig()
end

local retryTimes = 3
function RechargeController:getConfig()
  if false then
    local retData = json.decode([[
      {"payList":[{
      "id":1,
      "name":"GooglePlay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1},
      {"id":3,
      "name":"Easy2Pay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1},
      {"id":4,
      "name":"Easy2Pay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1},
      {"id":5,
      "name":"Easy2Pay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1},
      {"id":6,
      "name":"Easy2Pay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1},
      {"id":7,
      "name":"Easy2Pay",
      "configUrl":"http://gameth.iwormgame.com//config/pay_goods_list_android.php_d34da84d54d401ca.json",
      "deliveryUrl":"http://gameth.iwormgame.com/index.php/pay/deliverGoods",
      "discount":{"com.iwromgame.runningpig.diamond20":1.2, "com.iwromgame.runningpig.coin200k":2},
      "coinDiscount":1.2,
      "diamondDiscount":1}
      ],
      "ret":0}
      ]])
      self.mgr:init(retData.payList)
      self.view_:setPayList(retData.payList)
      self.view_:createUi()
    return
  end

    wq.HttpService.Post(
       {
           type = "pay",
           apply = "getPayList",
           platform = (device.platform == "windows" and "android" or device.platform),
       },
       function(data)
           local retData = json.decode(data)
           if retData.ret == 0 then
                self.mgr:init(retData.payList)
                self.view_:setPayList(retData.payList)
                self.view_:createUi()
            else
                retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    self:getConfig()
                end
           end
       end,
       function()
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                self:getConfig()
            end
       end)
end

function RechargeController:getRechargeCompon(componId)
    return self.mgr:getCompon(componId)
end

function RechargeController:editBoxAdjust(componId, editbox1, editbox2, commitButton)
    local compon = self:getRechargeCompon(componId)
    compon:editBoxAdjust(editbox1, editbox2, commitButton)
end

function RechargeController:onEditBoxData(componId, goodsType, editbox1, editbox2, commitButton)
    local compon = self:getRechargeCompon(componId)
    compon:onEditBoxData(goodsType, editbox1, editbox2, commitButton, handler(self, self.rechargeCallback_))
end

--获取充值金币列表
function RechargeController:getTopupCoin(payCompon)
    if payCompon == nil then
        logger:log("getTopupCoin payCompon nil")
        return
    end
    local compon = self:getRechargeCompon(payCompon.id)
    compon:loadCoinList(handler(self, self.onGetTopupCoinResultListener_))
end

function RechargeController:onGetTopupCoinResultListener_(payComponConfig, isLoaded, data)
    logger:log("RechargeController:onGetTopupCoinResultListener_ ")
    self.view_:setCoinListData(payComponConfig, isLoaded, data)
end

--获取充值钻石列表
function RechargeController:getTopupDiamond(payCompon)
    if payCompon == nil then
        logger:log("getTopupDiamond payCompon nil")
        return
    end
    local compon = self:getRechargeCompon(payCompon.id)
    compon:loadDiamondList(handler(self, self.onGetTopupDiamondResultListener_))
end

function RechargeController:onGetTopupDiamondResultListener_(payComponConfig, isLoaded, data)
    logger:log("RechargeController:onGetTopupDiamondResultListener_")
    self.view_:setDiamondListData(payComponConfig, isLoaded, data)
end

--获取充值记录列表
function RechargeController:getLog()
   wq.HttpService.Post(
       {
           type = "pay",
           apply = "getUserRecord",
       },
       handler(self, self.onGetLogSuccessListener_),
       handler(self, self.onGetLogFailListener_))
end

function RechargeController:onGetLogSuccessListener_(data)
    local retData = json.decode(data)
    print("getLogMsg success")
    if retData.ret == 0 then
        self.view_:setLogListData(retData.data)
    end

    --TODO test
    -- self.view_:setData(3)
end

function RechargeController:onGetLogFailListener_()
    self.view_:setLogListData("failed")
end

function RechargeController:dispose()
    self.mgr:dispose()
    wq.EventDispatcher:removeEventListener(self.rechargeHandlerId)
end

return RechargeController
