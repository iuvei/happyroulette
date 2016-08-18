local RankItem = class("RankItem", wq.ui.ListItemBase)

local paddingX = 8
local paddingY = 4
RankItem.WIDTH = 324
RankItem.HEIGHT = 80 + paddingY

local logger = wq.Logger.new("RankItem")

function RankItem:ctor(listView)
    self:setNodeEventEnabled(true)
	RankItem.super.ctor(self, listView)
	self:setupView()
end

function RankItem:setupView()
    self.bg = display.newScale9Sprite("#ranking_item_bg.png")
            :size(RankItem.WIDTH - paddingX * 2, RankItem.HEIGHT - paddingY)
            :pos(0,0)
            :addTo(self, -1)
    wq.TouchHelper.new(self.bg, handler(self, self.onClick_), false, false)
end

function RankItem:onDataChanged(data)
    --排名标志
    local rank = self:getIdx()
    local flagSrc = "#ranking_4.png"
    if rank == 1 then
        flagSrc = "#ranking_1.png"
    elseif rank == 2 then
        flagSrc = "#ranking_2.png"
    elseif rank == 3 then
        flagSrc = "#ranking_3.png"
    end
    local flag = display.newSprite(flagSrc):addTo(self.bg,1):pos(22,63)
    cc.ui.UILabel.new({font = "tahoma",text = rank, size = 30,  color = rl.data.color.white}):align(display.CENTER):addTo(flag):pos(18,23)

    self.head = rl.ui.CircleHeadView.new():addTo(self.bg):pos(60,42):scale(0.8)

    self.getterId = rl.ImageGetter:getImage(data.icon, function(success, texture)
        if success then
            self.head:setTexture(texture, 1)
        end
    end, rl.ImageGetter.CACHE_TYPE_HEAD)

    cc.ui.UILabel.new({font = "tahoma",text = data.nickName or "nickName", size = 30,  color = cc.c3b(0xf6,0xf0,0xd9)}):addTo(self.bg):pos(112,58)
    cc.ui.UILabel.new({font = "tahoma",text = "$ "..rl.formatNumberThousands(data.money) or 0, size = 24,  color = cc.c3b(0xf6,0xf0,0xd9)}):addTo(self.bg):pos(112,24)
end

function RankItem:onClick_(target, eventName)
    if not self.data_.last then
        if wq.TouchHelper.CLICK  == eventName then
        elseif wq.TouchHelper.BEGAN  == eventName then
            transition.scaleTo(self.bg, {time = 0.05, scale = 0.95})
        elseif wq.TouchHelper.ENDED  == eventName then
            transition.scaleTo(self.bg, {time = 0.05, scale = 1})
        end
    end
end

function RankItem:onCleanup()
    if self.getterId then
        rl.ImageGetter:cancelTaskById(self.getterId)
        self.getterId = nil
    end
end
return RankItem
