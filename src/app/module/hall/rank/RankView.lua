local RankView = class("RankView", function()
	return display.newNode()
end)

local RankItem = import("app.module.hall.rank.RankItem")

function RankView:ctor()
    self:setupView()
end

function RankView:setupView()
    self.bg = display.newScale9Sprite("#ranking_bg.png",0, 0, cc.size(365, 508), cc.rect(23,210,1,1)):addTo(self)

	display.newSprite("#ranking_icon.png"):addTo(self):pos(-90,233)
	cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("HALL","RANKING"),size = 24,  color = cc.c3b(0xcf,0x69,0x1e)})
	:align(cc.ui.TEXT_ALIGN_CENTER)
	:pos(0,233)
	:addTo(self)

	self:initListView()
end

function RankView:initListView()
	local listWidth, listHeight = 338, 432
    self.rankList = wq.ui.ListViewBase.new({
        viewRect = cc.rect(0, 0, listWidth, listHeight),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        async = false,
    }, RankItem)
    :addTo(self):pos(-listWidth/2 , -listHeight/2 - 16)
	-- self.rankList:setData({{},{},{},{},{},{},{},{},{},{}})
end

function RankView:updateRank()
	local rankData = GameData.rankData or {}
	local rankDay  = GameData.rankDay or 0
	local tab =  os.date("*t",os.time())
    if tab.day ~= rankDay then --需要更新
		local param = {}
		param.objectId = rl.userData.objectId
	    bmob.execCloud("getRank",param,"EXEC_EXEC",handler(self, self.onGetRank))
	else --继续用旧的
		self.rankList:setData(rankData)
	end
end

function RankView:onGetRank(data)
	local retData = json.decode(data.result)
	local rankData = retData.results
	self.rankList:setData(rankData)
	GameData.rankData = rankData
	GameData.rankDay = os.date("*t",os.time()).day
	GameState.save(GameData)
end

return RankView
