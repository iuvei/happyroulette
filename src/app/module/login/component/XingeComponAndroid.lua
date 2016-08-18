--
-- Author: viking@iwormgame.com
-- Date: 2015-06-18 15:24:55
--
local XingeComponAndroid = class("XingeComponAndroid")

function XingeComponAndroid:ctor()
	-- body
end

function XingeComponAndroid:registerPush(callback)
	self:call_("registerPush", {callback}, "(I)V")
end

function XingeComponAndroid:call_(javaMethodName, javaParams, javaMethodSig)
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/iwormgame/xinge/XingeJavaBridge", javaMethodName, javaParams, javaMethodSig)
		if not ok then
			if ret == -1 then
				print("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
			elseif ret == -2 then
				print("call %s failed, -2 无效的签名", javaMethodName)
			elseif ret == -3 then
				print("call %s failed, -3 没有找到指定的方法", javaMethodName)
			elseif ret == -4 then
				print("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
			elseif ret == -5 then
				print("call %s failed, -5 Java 虚拟机出错", javaMethodName)
			elseif ret == -6 then
				print("call %s failed, -6 Java 虚拟机出错", javaMethodName)
			end
		end
		return ok, ret
	else
		print("call %s failed, not in android platform", javaMethodName)
		return false, nil
	end
end

return XingeComponAndroid