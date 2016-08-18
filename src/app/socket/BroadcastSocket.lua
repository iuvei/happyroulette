--
-- Author: viking@iwormgame.com
-- Date: 2015-05-07 10:19:56
--
local SocketBase = import(".SocketBase")
local BroadcastSocket = class("BroadcastSocket", SocketBase)

local logger = wq.Logger.new("BroadcastSocket")

function BroadcastSocket:ctor()
	BroadcastSocket.super.ctor(self, "BroadcastSocket")
end

function BroadcastSocket:sendLogin()
	self:sendPackage("user", "login", {uid = rl.userData.uid})
end

--发送消息和表情
function BroadcastSocket:sendUserChat(data)
-- http://testxyz.haymus.com/index.php/privateChat/sendMessage?uid=60508&msg=test&chatUid=10018&type=1&seckey_x=Adxswydxby
    wq.HttpService.Post({
    	isExtends = true,
        type1 = "privateChat",
        apply1 = "sendMessage",
        chatUid = data.chatuid, --uid
        msg = data.content, --内容
        type = data.type, --判断是表情还是输入的内容
    },
        function(data)
            local retData = json.decode(data)
            if retData.ret == 0 then

            elseif retData.ret == -265 then
            	--发送消息失败 提示不是您的好友
                rl.ui.Tips.new({string = wq.LangTool.getText("Friend", "friendPrompt")}):show()
            else
                rl.ui.Tips.new({ errCode = retData.ret }):show()
            end
        end,
        function()
            --没拉取到数据的时候提示网络的问题
            rl.TopTipsManager:insert(wq.LangTool.getText("Common", "badNetWork"))
        end)
end

function BroadcastSocket:onHandlePacket(packet)
	local service = packet.header.service
	local method = packet.header.method
	local data = packet.data
	wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.BROADCASTSOCKET_PACKAGE, data = {service = service, method = method, data = data}})
	if service == "user" then
		if method == "toOne" then
			if data.uid == rl.userData.uid then
				if data.idString == "levelUp" then
					self:levelUp(data)
				elseif data.idString == "starUp" then
				 	self:starUp(data)
                elseif data.idString == "achiFinish" then --完成一项成就
                    self:achiFinish(data)
                elseif data.idString == "taskFinish" then --完成一个每日任务
                    self:taskFinish(data)
                elseif data.idString == "betGetReward" then
                	self:updateMoney(data)
                elseif data.idString == "syncData" then
                	self:syncData(data)
                elseif data.idString == "newMessage" then --消息中心有新消息
                    self:getNewMessage()
                elseif data.idString == "requestFriend" then --消息中心好友邀请
                	self:getAcceptFriend()
				elseif data.idString == "bankruptcyRecharge" then --破产充值了
					self:bankruptcyRecharge()
				elseif data.idString == "private_chat" then --消息中心好友聊天消息
					self:receiveFriendNews(data)
				elseif data.idString == "requestFriendToMatch" then --被邀请去私人房
					--data : name tid star blind password
					if display.getRunningScene().name ~= "RoomScene" then
						rl.BeInvitedHelper:onInvited(data)
					end
				elseif data.idString == "getSendMoney" then --收到有人给爹送钱
					if display.getRunningScene().name ~= "RoomScene"then
						rl.TopTipsManager:insert(wq.LangTool.getText("BettingShop", "getGiveMoneyFromXX",data.name,data.money))

					else
						if display.getRunningScene().name == "RoomScene" and rl.matchType == "profession" then
							rl.pfTopTips:insert(wq.LangTool.getText("BettingShop", "getGiveMoneyFromXX",data.name,data.money))
						else
							local getSendMoneyData = wq.DataStorage:getData(rl.DataKeys.GET_SEND_MONEY_DATA) or {}
							table.insert(getSendMoneyData,data)
							wq.DataStorage:setData(rl.DataKeys.GET_SEND_MONEY_DATA,getSendMoneyData)
						end
					end
					rl.userData.money = rl.userData.money + data.money
                end
			end
		elseif method == "toAll" then
			if data.idString == "allBroad" then --广播喇叭
				self:getAllBroad(data)
			elseif data.idString == "dailyStarUpdate" then
				self:dailyStarUpdate(data)
			end
		end
	end
end

function BroadcastSocket:levelUp(data)--src isMatch 0不在，1在。
	logger:log("oldLv:"..data.old..",newLv:"..data.new..",exp:"..data.exp)

	--show
	if data.src == 1 or rl.isTaskViewShow then
		rl.userData.levelData = data--比赛完再弹框
	else
		display.addSpriteFrames("levelup.plist", "levelup.png",function()
			rl.ui.LvOrStarUpDialog.new(1, data):show()
		end)
	end
end

function BroadcastSocket:starUp(data)--src isMatch 0不在，1在。
	logger:log("oldstar:"..data.old..",newstar:"..data.new..",pig_index:"..data.pig_index..",sumGrowth:"..data.sumGrowth)
	data.pig_index = data.pig_index + 1
	rl.pigData[data.pig_index].starData = data

	--show
	-- display.addSpriteFrames("levelup.plist", "levelup.png",function()
	-- 	rl.ui.LvOrStarUpDialog.new(2, data):show()
	-- end)
end

function BroadcastSocket:dailyStarUpdate(data)
	wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "bet_daily_star", isShow = true})
	rl.userDefault:setBoolForKey(rl.StorageKeys.REDPOINT_BET_DAILYSTAR_ISSHOW, true)
	rl.userDefault:flush()
end

function BroadcastSocket:getNewMessage()
    wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "msg", isShow = true})
end

--添加好友
function BroadcastSocket:getAcceptFriend()
    if display.getRunningScene().name ~= "RoomScene" then
    	rl.TopTipsManager:insert(wq.LangTool.getText("Friend", "friendAccept"))
    else
    	wq.DataStorage:setData(rl.DataKeys.HAVE_ACCEPT_SUCCESS,true)
    end
	wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "accept", isShow = true})
end

--好友聊天消息
function BroadcastSocket:receiveFriendNews(data)
	if rl.userData.chatuid == data.info[1] then --当前是在和自己聊天
		wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.HAVE_FRIEND_CHAT_MSG, data = data.msg}) -- 刷新聊天的界面
	else
		if display.getRunningScene().name ~= "RoomScene" then
	    	rl.TopTipsManager:insert(wq.LangTool.getText("Friend", "friendBroadMsg", data.info[2]))
	    else
	    	wq.DataStorage:setData(rl.DataKeys.HAVE_ACCEPT_SUCCESS,true)
	    end
		--广播的时候刷新msgFriend列表 抛事件
		wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "accept", isShow = true})
	end

	wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.MSG_REFRESH_NEWS})
end

function BroadcastSocket:taskFinish(data)
    wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "task", isShow = true})
    if display.getRunningScene().name ~= "RoomScene" then
        rl.TopTipsManager:insert(wq.LangTool.getText("Task","taskComplete"))
	else
		wq.DataStorage:setData(rl.DataKeys.HAVE_TASK_SUCCESS,true)
    end
end

function BroadcastSocket:achiFinish(data)
    wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.UPDATE_REDPOINT, key = "achi", isShow = true})
--    local retInfo = wq.DataStorage:getData(rl.DataKeys.ACHIEVEMENT_DATA)
    if display.getRunningScene().name ~= "RoomScene" then
        rl.TopTipsManager:insert(wq.LangTool.getText("Task","achiComplete"))
	else
		wq.DataStorage:setData(rl.DataKeys.HAVE_ACHI_SUCCESS,true)
    end
--    for i = 0 , #retInfo do
--        if retInfo[i].achi_type == data.achiID then
--            retInfo[i].nowIndex = data.nowIndex
--            break
--        end
--    end
	logger:log("achiID:"..data.achiID..",nowIndex:"..data.nowIndex..",nextIndex:"..data.nextIndex)
end

--全服广播
function BroadcastSocket:getAllBroad(data)
	-- data: type(1文字 2中奖通告,3庄家盈利下庄通告) msg money name
	if data.type == 1 then
		if display.getRunningScene().name ~= "RoomScene" then
			rl.BroadcastManager:insert(data)
		end
	elseif data.type == 2 then
		rl.schedulerFactory:delayGlobal(function()	--中奖通告延迟30秒播放
			if display.getRunningScene().name ~= "RoomScene" then
				rl.BroadcastManager:insert(data)
			end
		end, 40)
	elseif data.type == 3 then
		rl.schedulerFactory:delayGlobal(function()	--下庄通告延迟30秒播放
			if display.getRunningScene().name ~= "RoomScene" then
				rl.BroadcastManager:insert(data)
			end
		end, 40)
	end
end

function BroadcastSocket:bankruptcyRecharge()
	rl.configData.bankruptcy_discount = 1
	rl.configData.bankruptcy_left_time = 0
	wq.EventDispatcher:dispatchEvent({name = rl.EventKeys.ON_BANKRUPTCY_RECHARGE})
end

function BroadcastSocket:updateMoney(data)
	rl.userData.money = data.money
end

--money exp diamond
function BroadcastSocket:syncData(data)
	logger:log("")
	if data.money then
		logger:log("money:"..data.money)
		self:updateMoney(data)
	else
		logger:log("money: nil")
	end

	if data.exp then
		logger:log("exp:"..data.exp)
		rl.userData.exp = data.exp
	else
		logger:log("exp: nil")
	end

	if data.diamond then
		logger:log("diamond:"..data.diamond)
		rl.userData.diamond = data.diamond
	else
		logger:log("diamond: nil")
	end

	if data.type and display.getRunningScene().name ~= "RoomScene" then
		if data.type == 1 then
			rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "rechargeCoinSucc", data.value))
		elseif data.type == 2 then
			rl.TopTipsManager:insert(wq.LangTool.getText("Recharge", "rechargeDiamondSucc", data.value))
		end
	end
end

function BroadcastSocket:onHeartBeatTimeout(timeoutCount)
    self.log:log("implemented method onHeartBeatTimeout")
    if timeoutCount > 2 then
    	self:disconnect()--断开连接
    	self:connect(rl.configData.broad_ip, rl.configData.broad_port, true)
    end
end

function BroadcastSocket:onHeartBeatReceived(delaySeconds)
    self.log:log("implemented method onHeartBeatReceived")
end

function SocketBase:onAfterConnectFailure()
	self.log:log("implemented method onAfterConnectFailure")
	-- self.retryLimit_ = 2
	self:disconnect()--断开连接
	self:connect(rl.configData.broad_ip, rl.configData.broad_port, true)
end

function BroadcastSocket:onAfterConnected()
	logger:log("")
	self:sendLogin()
	self:scheduleHeartBeat(5, 2)
end

return BroadcastSocket
