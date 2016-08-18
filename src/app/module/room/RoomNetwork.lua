--
-- Author: wenqing
-- Date: 2016-05-01 18:41:12
--
local RoomNetwork = class("RoomNetwork")

local logger = wq.Logger.new("RoomNetwork")

function RoomNetwork:ctor()
end

-- 召唤机器人
function RoomNetwork:callRobot()
	local param = {}
	param.objectId = rl.userData.objectId
    bmob.execCloud("getRobot",param,"EXEC_EXEC",handler(self, self.onCallRobot))
end

--召唤成功 获取objectId再通过bmob来query
function RoomNetwork:onCallRobot(data)
	if not rl.isRoomView then return end
	local retData = json.decode(data.result)
	local key = -1
    if retData.ret == 0 or retData.ret == "0" then
    	for k,v in pairs(GameManager.robot) do
    		if v.isEmpty == 1 then
    			v.chairId = k
    			v.isEmpty = 0
    			v.objectId = retData.objectId
    			key = k
    			break
    		end
    	end

		if key == -1 then return end

		logger:log("---------------------------------------key = "..key)
    	bmob.queryRow("Robot",GameManager.robot[key].objectId,handler(self, self.onGetRobot))
    	-- self.view:onCallRobot(v)
    else
    	-- 没有else了，不报错给玩家看
    end
end

function RoomNetwork:onGetRobot(data)
	if not rl.isRoomView then return end
	-- dump(data)
-- 	 "<var>" = {
-- [LUA-print] -     "createdAt"  = "2016-05-03 20:43:34"
-- [LUA-print] -     "icon" = {
-- [LUA-print] -         "__type"   = "File"
-- [LUA-print] -         "cdn"      = "upyun"
-- [LUA-print] -         "filename" = "xKO6000G.jpg"
-- [LUA-print] -         "url"      = "http://bmob-cdn-303.b0.upaiyun.com/2016/05/03/67f7a866402df2a6806bae5f21fd7bd0.jpg"
-- [LUA-print] -     }
-- [LUA-print] -     "money"      = 30000002
-- [LUA-print] -     "objectId"   = "xKO6000G"
-- [LUA-print] -     "updateItem" = "0"
-- [LUA-print] -     "updatedAt"  = "2016-05-04 08:26:57"
-- [LUA-print] -     "username"   = "robot1"
-- [LUA-print] - }

	for k,v in ipairs(GameManager.robot) do
		if v.objectId == data.objectId then
			v.isQuery = 1
			v.money = data.money
			v.userName = data.username
			v.lastBetTime = os.time()
			v.betInterval = math.random(30,100)/10
			v.icon = data.icon--.url

			v.tabBetValue = {1000,5000,10000}
		    if v.money > 1000000 and v.money <= 10000000 then --大于100万 <=1000万
		        v.tabBetValue = {1000,10000,50000}
		    elseif v.money > 10000000 and v.money <= 50000000 then --大于1000万 小于5000万
		        v.tabBetValue = {10000,50000,100000}
		    elseif v.money > 50000000 then
		        v.tabBetValue = {10000,100000,1000000}
		    end

			GameManager.roomView:onCallRobot(v)
			break
		end
	end
end

function RoomNetwork:updateMoney()
    bmob.updateMoney(rl.userData.money)
end

function RoomNetwork:reportGameResult(param)
    bmob.execCloud("reportGameResult",param,"EXEC_EXEC",handler(self, self.onReportGameResult))
end

function RoomNetwork:onReportGameResult(data)
	if not rl.isRoomView then return end
    -- dump(data)
    -- local retData = json.decode(data.result)
    -- if retData.ret == 0 or "0" then
    --
    -- end
end

function RoomNetwork:getRoomInfo()
    bmob.queryRow("Room",rl.curRoomId,handler(self, self.onGetRoomInfo))
end

function RoomNetwork:onGetRoomInfo(data)
-- 	{
-- [LUA-print] -     "createdAt" = "2016-05-01 21:39:41"
-- [LUA-print] -     "objectId"  = "cbf347db7e"
-- [LUA-print] -     "updatedAt" = "2016-05-01 21:39:41"
-- [LUA-print] -     "user1"     = "12312312123"
-- [LUA-print] -     "userCount" = 1
-- [LUA-print] - }

    -- dump(data)
    logger:log("data.updatedAt = "..data.updatedAt)
end

return RoomNetwork
