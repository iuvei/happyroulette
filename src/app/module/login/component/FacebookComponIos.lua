--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午5:13:51
--

local FacebookComponIos = class("FacebookComponIos")

function FacebookComponIos:ctor()
	luaoc.callStaticMethod("FacebookComponent", "createNewSession")
end

function FacebookComponIos:login(callback)
	luaoc.callStaticMethod("FacebookComponent", "login", {callback = callback})
end

function FacebookComponIos:logout()
	luaoc.callStaticMethod("FacebookComponent", "logout")
end

function FacebookComponIos:getInvitableFriend(callback)
	luaoc.callStaticMethod("FacebookComponent", "getInvitableFriends", {callback = callback})
end

function FacebookComponIos:invite(inviteData, callback)
	local params = inviteData
	params.callback = callback
	luaoc.callStaticMethod("FacebookComponent", "invite", params)
end

function FacebookComponIos:share(shareData, callback)
	local params = shareData
	params.callback = callback
	luaoc.callStaticMethod("FacebookComponent", "share", params)
end

function FacebookComponIos:getAppRequestsId(isLogin)
	local requestIdRetryTimes = 3
	local callback = function(result)
		local success = (result ~= "canceled" and result ~= "failed")
		if type(result) == "table" then
			print("FacebookComponIos:getAppRequestsId result:"..result.requestId)
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
		else
			print("FacebookComponIos:getAppRequestsId result: fail")
		end
	end
	luaoc.callStaticMethod("FacebookComponent", "getAppRequestsId", {callback = callback})
end

function FacebookComponIos:deleteRequestId(requestId)
	luaoc.callStaticMethod("FacebookComponent", "deleteRequestId", {requestId = requestId})
end

return FacebookComponIos