--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午5:13:03
--

local FacebookComponAndroid = class("FacebookComponAndroid")

function FacebookComponAndroid:ctor()

end

function FacebookComponAndroid:login(callback)
    self:call_("login",{callback},"(I)V")
end

function FacebookComponAndroid:logout()
    self:call_("logout",{},"()V")
end

function FacebookComponAndroid:getInvitableFriend(callback)
	self:call_("getInvitableFriends", {callback}, "(I)V")
end

function FacebookComponAndroid:invite(inviteData, callback)
	self:call_("invite", {json.encode(inviteData), callback}, "(Ljava/lang/String;I)V")
end

function FacebookComponAndroid:share(shareData, callback)
	self:call_("share", {json.encode(shareData), callback}, "(Ljava/lang/String;I)V")
end

--facebook登录的时候就需要去拉取
function FacebookComponAndroid:getAppRequestsId(isLogin)
	local requestIdRetryTimes = 3
	local callback = function(result)
		local success = (result ~= "canceled" and result ~= "failed")
		print("FacebookComponAndroid:getAppRequestsId result:"..result)
		if success then
			result = json.decode(result)
			if result and result.requestData and result.requestId then

				if isLogin == 1 then
					wq.HttpService.Post({
						type = "userRecall",
						apply = "recallSucc",
						recallUid = result.requestData,
					},
					function(data)
						local retData = json.decode(data)
						if retData.ret == 0 then
							self:deleteRequestId(result.requestId)
						end
					end,
					function()
						if requestIdRetryTimes > 0 then
							requestIdRetryTimes = requestIdRetryTimes - 1
							callback(result)
						end
					end)
				else
					wq.HttpService.Post({
						type = "user",
						apply = "requestSucc",
						requestUid = result.requestData,
					},
						function(data)
							local retData = json.decode(data)
							if retData.ret == 0 then
								self:deleteRequestId(result.requestId)
							end
						end,
						function()
							if requestIdRetryTimes > 0 then
								requestIdRetryTimes = requestIdRetryTimes - 1
								callback(result)
							end
						end)
				end
			end	
		end	
	end

	self:call_("getAppRequestsId", {callback}, "(I)V")
end

function FacebookComponAndroid:deleteRequestId(requestId)
	self:call_("deleteRequestId", {requestId}, "(Ljava/lang/String;)V")
end

function FacebookComponAndroid:call_(javaMethodName, javaParams, javaMethodSig)
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/iwormgame/facebook/FacebookJavaBridge", javaMethodName, javaParams, javaMethodSig)
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

return FacebookComponAndroid