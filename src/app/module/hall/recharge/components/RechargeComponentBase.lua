--
-- Author: viking@iwormgame.com
-- Date: 2015-06-09 18:37:09
--
local RechargeComponentBase = class("RechargeComponentBase")


function RechargeComponentBase:ctor(name)
	self.logger = wq.Logger.new(name or "RechargeComponentBase")
end

function RechargeComponentBase:init(config)
	-- body
end

function RechargeComponentBase:loadCoinList(callback)
	-- body
end

function RechargeComponentBase:loadDiamondList(callback)
	-- body
end

function RechargeComponentBase:loadingGoods()
	-- body
end

--商品id
function RechargeComponentBase:recharge(id, callback)
	-- body
end

function RechargeComponentBase:editBoxAdjust(editbox1, editbox2, commitButton)
	-- body
end

--商品类型goodsType
function RechargeComponentBase:onEditBoxData(goodsType, editbox1, editbox2, commitButton, callback)
	-- body
end

function RechargeComponentBase:dispose()
	-- body
end

function RechargeComponentBase:callStaticMethod(javaClassName)
	return function(javaMethodName, javaParams, javaMethodSig)
		if device.platform == "android" then
			local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
			if not ok then
				if ret == -1 then
					self.logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
				elseif ret == -2 then
					self.logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
				elseif ret == -3 then
					self.logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
				elseif ret == -4 then
					self.logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
				elseif ret == -5 then
					self.logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
				elseif ret == -6 then
					self.logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
				end
			end
			return ok, ret
		else
			self.logger:logf("call %s failed, not in android platform", javaMethodName)
			return false, nil
		end
	end
end

return RechargeComponentBase
