--
-- Author: wenqing
-- Date: 2016-05-08 21:35:47
--

GameManager = class("GameManager")

local logger = wq.Logger.new("GameManager")

--定时器刷新间隔
local UPDATE_TIME = 0.1
--每局游戏的时间
local perGameTime = TIME_PER_GAME
--对应点的下标
local pointIdx = {31,9,22,18,29,7,28,12,35,3,26,0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14}

function GameManager:ctor()
end

function GameManager:init()
	--当前机器人 人数
	self.robotNum = 0
	--机器人数组(5个) 机器人投注数组
	self.robot = {}
	self.robotBet = {}
	for i = 1, 5 do
		self.robot[i] = {isEmpty = 1, isCommit = 0,lastBetTime = 0,isQuery = 0}
		self.robotBet[i] = {}
		for j = 1, 157 do self.robotBet[i][j] = 0 end
	end

	--倒计时剩余
	self.lestTime = 0
	-- 当前单注额度
	self.betValue = 0
	--当前筹码tab下标
	self.betTabIdx = 1
	--当前下注 (未提交)
	self.curBet = {}
	for i = 1, 157 do self.curBet[i] = 0 end
	--记录第几注的筹码值
	self.myChipsValue = {}
	--当前总下注
	self.totalBet = 0
	--我的筹码（sprite）
	self.myChips = {}
    self.myChipsCount = 0
	self.myNodeIdx = {}
	self.isCommit = 0

	--记录上一局的下注
	self.lastBet = {}
	for i = 1, 157 do self.lastBet[i] = {} end

	self.lastChipsValue = {}
	self.lastChipsCount = 0
	self.lastNodeIdx = {}

	--上次召唤机器人的时间
	self.lastCallRobotTime = 0
end



function GameManager:setNetwork(network)
	self.network = network
end

function GameManager:setRoomView(view)
	self.roomView = view
end

function GameManager:setDeskView(view)
	self.deskView = view
end

function GameManager:setResultView(view)
	self.resultView = view
end

function GameManager:onEnterRoom()
	self.gameStatus = GAME_STATUS_START
	self:newFirstGame()
end

-- 进来开始第一局
function GameManager:newFirstGame()
	--当前玩家数量，剩余开局时间
	self.robotNum = math.random(0,5)
	logger:log("robotNum = "..self.robotNum)
	self.lestTime = math.random(15,perGameTime)
	logger:log("lestTime = "..self.lestTime)
	if self.robotNum ~= 0 then
		for i = 1, self.robotNum do
			rl.schedulerFactory:delayGlobal(function()
            	self.network:callRobot()
        	end, 0.3*i)
		end
	else
		self.lestTime = perGameTime
	end

	for i = 1, 5 do
		self.robot[i].lastBetTime = os.time()
		self.robot[i].betInterval = math.random(30,100)/10
	end

	self.lastCallRobotTime = os.time()
	self.roomView.btnRebet:setButtonEnabled(false)
   	self.gameScheduler = rl.schedulerFactory:scheduleGlobal(handler(self, self.onUpdateSchedule), UPDATE_TIME)
end

--新的一局
function GameManager:newGame()

	self.roomView:setBetBtnsEnabled(true)

	for i = 1, 5 do
		if self.robot[i].isE200y == 0 then
			--钱少走人
			if self.robot[i].money < self.robot[i].tabBetValue[3] then
				self:onRobotExit(i)
			else --随机走人
				local rand = math.random(1, 10)
				if rand <= 4 then
					self:onRobotExit(i)
				end
			end
		end
	end

	self.gameStatus = GAME_STATUS_START
	--机器人
	for i = 1, 5 do
		self.robot[i].lastBetTime = os.time()
		self.robot[i].betInterval = math.random(30,100)/10
		self.roomView.userHead[i].flagCommit:hide()
		self.robot[i].isCommit = 0
		for j = 1, 157 do
			self.robotBet[i][j] = 0
		end
	end

	for i = 1, 157 do self.curBet[i] = 0 end

	self.totalBet = 0
	self.isCommit = 0

	if self.lastChipsCount > 0 then
		self.roomView.btnRebet:setButtonEnabled(true)
		self.roomView.btnRebet:setColor(cc.c3b(255,255,255))
	else
		self.roomView.btnRebet:setButtonEnabled(false)
		self.roomView.btnRebet:setColor(cc.c3b(180,180,180))
	end

	self.myChipsCount = 0

	self.gameScheduler = rl.schedulerFactory:scheduleGlobal(handler(self, self.onUpdateSchedule), UPDATE_TIME)
	self.roomView.btnUndoAll:setButtonEnabled(true)
	self.roomView.btnUndoAll:setColor(cc.c3b(255,255,255))

	self.deskView.betAreaView.bg:setTouchEnabled(true)
end

function GameManager:onRobotExit(idx)
	self.robot[idx] = {isEmpty = 1, isCommit = 0,lastBetTime = 0,isQuery = 0,tabBetValue = {0,0,0}}
	self.roomView.userHead[idx]:hide()
end

--定时器调度
function GameManager:onUpdateSchedule()
	--刷新倒计时
	self.lestTime = self.lestTime - UPDATE_TIME
	if self.lestTime <= 0 then
		self:noMoreBet()
	end
	self.roomView:updateView({lestTime = self.lestTime})

	if self.gameStatus == GAME_STATUS_ROLLING then
		return
	end
	-- 机器人行为
	local curTime = os.time()
	for k,v in ipairs(GameManager.robot) do
		if v.isEmpty == 1 then
			if (curTime - self.lastCallRobotTime) > 5 then
				local random = math.random(1, 100)
				if random < 30 then
		        	self.network:callRobot()
				end
				self.lastCallRobotTime = curTime
			end
		end

		if v.isQuery == 1 and v.isCommit == 0 then
			if (curTime - v.lastBetTime) > v.betInterval then
				local ranCommit = math.random(1, 10)
				if ranCommit <= 3 then
					v.isCommit = 1
					self.roomView.userHead[k].flagCommit:show()
					self:onCommit(false)
				else
					local betTimes = math.random(1, 8)
					local betValueIdx = math.random(1, 3)
					for i = 1, betTimes do
						local betIdx = math.random(1, 157)
						self:onRobotBet(v.chairId,betValueIdx,betIdx)
					end
					v.lastBetTime = curTime
					v.betInterval = math.random(30,70)/10
				end
			end
		end
	end
end

--机器人下注
function GameManager:onRobotBet(chairId,betValueIdx,betIdx)
	local chipValue = self.robot[chairId].tabBetValue[betValueIdx]
	if self.robot[chairId].money < chipValue then return end

	self.deskView.betAreaView:onRobotBet(chairId,betIdx,chipValue)
	self.robotBet[chairId][betIdx] = self.robotBet[chairId][betIdx] + chipValue
	self.robot[chairId].money = self.robot[chairId].money - chipValue
	self.roomView.userHead[chairId]:setMoney(self.robot[chairId].money)
end

--下注
function GameManager:onBet(idx)
	self.curBet[idx] = self.curBet[idx] + self.betValue
	self.totalBet = self.totalBet + self.betValue
	rl.userData.money = rl.userData.money -  self.betValue

	self.roomView.btnRebet:setButtonEnabled(false)
	local totalBetStr = (self.totalBet > 1000) and (self.totalBet/1000).."K" or self.totalBet
	self.deskView.totalBetLabel:setString("TOTAL BET："..totalBetStr)
	self.roomView.myUserHead:setMoney(rl.userData.money)
end

--撤销一步
function GameManager:undoOne()
	if self.myChipsCount < 1 then return end

	self.myChips[self.myChipsCount]:removeSelf()
	self.totalBet = self.totalBet - self.myChipsValue[self.myChipsCount]
	rl.userData.money = rl.userData.money + self.myChipsValue[self.myChipsCount]

	self.curBet[self.myNodeIdx[self.myChipsCount]] = self.curBet[self.myNodeIdx[self.myChipsCount]] - self.myChipsValue[self.myChipsCount]

	self.myChipsValue[self.myChipsCount] = 0
	self.myChipsCount = self.myChipsCount - 1

	local totalBetStr = (self.totalBet > 1000) and (self.totalBet/1000).."K" or self.totalBet
	self.deskView.totalBetLabel:setString("TOTAL BET："..totalBetStr)
	self.roomView.myUserHead:setMoney(rl.userData.money)
end

--撤销全部
function GameManager:undoAll()
	local myTotalBet = 0
	for i = 1, 157 do
		if self.curBet[i] ~= 0 then
			myTotalBet = myTotalBet + self.curBet[i]
			self.curBet[i] = 0
		end
	end

	if myTotalBet == 0 then return end
	self.totalBet = 0
	rl.userData.money = rl.userData.money + myTotalBet

	self.deskView.betAreaView:removeMyChips()
	self.deskView.totalBetLabel:setString("TOTAL BET：0")
	-- local moneyStr = (rl.userData.money > 1000) and math.ceil(rl.userData.money/1000).."K" or rl.userData.money
	-- self.roomView.myUserHead.label:setString(moneyStr)
	self.roomView.myUserHead:setMoney(rl.userData.money)
end

--续投
function GameManager:rebet()
	if self.lastTotalBet > rl.userData.money then
		rl.ui.Tips.new({string = wq.Langtool.getText("COMMON","NOT_ENOUGH_MONEY")}):show()
		return
	end

	self.myChipsValue = clone(self.lastChipsValue)
	self.myChipsCount = clone(self.lastChipsCount)
	self.myNodeIdx = clone(self.lastNodeIdx)
	self.lastChipsValue = {}
	self.lastChipsCount = 0
	self.lastNodeIdx = {}

	self.roomView.btnRebet:setButtonEnabled(false)

	self.deskView.betAreaView:onRebet()

	local myTotalBet = 0
	for i = 1, 157 do
		if self.curBet[i] ~= 0 then
			myTotalBet = myTotalBet + self.curBet[i]
		end
	end

	self.totalBet = myTotalBet

	local totalBetStr = (self.totalBet > 1000) and (self.totalBet/1000).."K" or self.totalBet
	self.deskView.totalBetLabel:setString("TOTAL BET："..totalBetStr)

	rl.userData.money = rl.userData.money - myTotalBet
	-- local moneyStr = (rl.userData.money > 1000) and math.ceil(rl.userData.money/1000).."K" or rl.userData.money
	-- self.roomView.myUserHead.label:setString(moneyStr)
	self.roomView.myUserHead:setMoney(rl.userData.money)
end

function GameManager:onCommit(isSelf)
	if isSelf == true then
		self.isCommit = 1
		self.roomView.myUserHead.flagCommit:show()
		self.deskView.betAreaView.bg:setTouchEnabled(false)
	end

	if self.isCommit ~= 1 then return end
	for k, v in ipairs(self.robot) do
		if v.isEmpty == 0 and v.isCommit == 0 then
			return
		end
	end

	self:noMoreBet()
	-- for i = 1, 157 do
	-- 	self.commitBet[i] = self.commitBet[i] + self.curBet[i]
	-- 	self.curBet[i] = 0
	-- end
end

--下注完毕，开始转盘
function GameManager:noMoreBet()
	rl.ui.Tips.new({string = wq.LangTool.getText("ROOM","START_ROLL")}):show()

	rl.SoundManager:playSounds(rl.SoundManager.dingding)

	self.gameStatus = GAME_STATUS_ROLLING
	self.lastChipsValue = clone(self.myChipsValue)
	self.lastChipsCount = clone(self.myChipsCount)
	self.lastNodeIdx = clone(self.myNodeIdx)
	self.lastTotalBet = self.totalBet
	--停止定时器
	self.lestTime = perGameTime
	if self.gameScheduler then
		rl.schedulerFactory:unscheduleGlobal(self.gameScheduler)
		self.gameScheduler = nil
	end

	--缩小投注区域
	if self.deskView.betAreaView.isBig == true then
		self.roomView:betAreaZoomOut()
	end

	--重置总下注
	self.deskView.totalBetLabel:setString("TOTAL BET：0")

	--重置已提交标签
	self.roomView.myUserHead.flagCommit:hide()

	--删除投注面板的筹码
	self.deskView.betAreaView:removeMyChips()
	self.deskView.betAreaView:removeRobotChips()

	--转移到轮盘的位置
	self.roomView:moveToPlate()
end

--转盘转转转
function GameManager:onRoll()
    local x = math.random(0,36)
    local n = 1
    for k,v in ipairs(pointIdx) do
        if v == x then
            n = k
        end
    end

	--转完了显示结果
    self.deskView:roll(9.729729729729 * n - 1,function()
		self:onGameResult(x)
	end)
end

local betRate = {[36] = {}}

local function getBetRate(idx)
	if 1 <= idx and idx <= 37 then
		return 36
	elseif 38 <= idx and idx <= 97 then
		return 18
	elseif 98 <= idx and idx <= 111 then
		return 12
	elseif 112 <= idx and idx <= 134 then
		return 9
	elseif 135 <= idx and idx <= 145 then
		return 6
	elseif 146 <= idx and idx <= 151 then
		return 3
	elseif 152 <= idx and idx <= 157 then
		return 2
	end
end

--出结果了结算
function GameManager:onGameResult(result)
	self.roomView:showResultView(result)
	--保存GameState
	local resTable = GameData.gameResult or {}
	resTable[#resTable + 1] = result
	GameData.gameResult = resTable
	GameState.save(GameData)

	--刷新历史记录
	self.deskView:updateHistory()

	--结算自己
	local win = 0
	local myTotalBet = 0
	local betNumber = {}
	for i = 1, 157 do
		if self.curBet[i] ~= 0 then
			myTotalBet = myTotalBet + self.curBet[i]
			local isInTable = rl.isInTable(rl.data.betArea.point2Number[i],result)
			if isInTable then --有中奖
				win = win + self.curBet[i]*getBetRate(i)
				logger:log("win = "..win)
			end
			betNumber[#betNumber+1] = i
		end
	end

	rl.ui.Tips.new({string = "中奖:"..win..",总投注:"..myTotalBet}):show()

	--回收盈利的5%做为消耗
	local profit = win - myTotalBet
	if profit > 0 then
		rl.userData.money = rl.userData.money + win - math.floor(profit*0.05)
	else
		rl.userData.money = rl.userData.money + win
	end

	-- local moneyStr = (rl.userData.money > 1000) and math.ceil(rl.userData.money/1000).."K" or rl.userData.money
	self.roomView.myUserHead:setMoney(rl.userData.money)
	logger:log("rl.userData.money = "..rl.userData.money)
	if myTotalBet ~= 0 then
		self.network:updateMoney()
	end

	--结算机器人
	local robotParam = {}

	for i = 1, 5 do
		if self.robot[i].isQuery == 1 then
			local win = 0
			for j = 1, 157 do
				if self.robotBet[i][j] ~= 0 then
					local isInTable = rl.isInTable(rl.data.betArea.point2Number[i],result) --判断号码是否在下注点对应的列表中
					if isInTable then --有中奖
						win = win + self.robotBet[i][j]*getBetRate(i)
					end
				end
			end
			self.robot[i].money = self.robot[i].money + win
			self.roomView.userHead[i]:setMoney(self.robot[i].money)
		end
		robotParam[i] = {isEmpty = self.robot[i].isEmpty,objectId = self.robot[i].objectId or "0",money = self.robot[i].money or 0}
	end

	--上传结算
	local param = {}
	param.user = {
		objectId = rl.userData.objectId,
		betMoney = myTotalBet,
		userBetNumber = betNumber
	}
	param.gameResult = {
		profit = win - myTotalBet,
		resultNum = result
	}
	param.robot = robotParam

	self.network:reportGameResult(param)
end

function GameManager:dispose()
	-- self.roomView = nil
	-- self.deskView = nil
	-- self.resultView = nil

	if self.gameScheduler then
    	rl.schedulerFactory:unscheduleGlobal(self.gameScheduler)
		self.gameScheduler = nil
	end
end
