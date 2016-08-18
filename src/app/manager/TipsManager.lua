local TipsManager = class("TipsManager")

function TipsManager:ctor()
    self:initData()
end

function TipsManager:initData()
    self.curTips = {}
    self.counter = 0
end

function TipsManager:insert(tips)
    if self.father and self.father ~= display.getRunningScene() then
        self.counter = 0
    end
    tips:addTo(display.getRunningScene())
    self.father = display.getRunningScene()
    local fadeIn = cc.FadeIn:create(0.5)
    transition.execute(tips.bg, fadeIn)
    
    if self.counter == 0 then
        self.curTips = tips
    else
        self.curTips:hideSelf(self.curTips.removeSchedulerId_) -- 当前有一个，立即删除，并把定时器ID传回用来删除定时器
        self.curTips = tips
    end
    
    self.counter = self.counter + 1
end

function TipsManager:remove(tips)
    local fadeOut = cc.FadeOut:create(0.5)
    local move = cc.MoveBy:create(0.5, cc.p(0, 80))
    local spawnAction = cc.Spawn:create(fadeOut, move)
    if  display.getRunningScene().name == "RoomScene" then
        transition.execute(tips.label, cc.Spawn:create(cc.FadeOut:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 1))))
        transition.execute(tips.bg, spawnAction,{onComplete = function ()
            tips:removeSelf()
            self.counter = self.counter - 1
        end})
    else
        transition.execute(tips.bg, spawnAction,{onComplete = function ()
            tips:removeSelf()
            self.counter = self.counter - 1
        end})
    end
end

return TipsManager