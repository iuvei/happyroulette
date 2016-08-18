--全屏屏蔽点击层
--用例：rl.ui.ShieldLayer.new()
-- delay == -1 表示无限时间，需主动调用hide()才会关闭
local ShieldLayer = class("ShieldLayer", function()
    return display.newNode()
end)

local logger = wq.Logger.new("ShieldLayer")

function ShieldLayer:ctor(delay)
    self:setNodeEventEnabled(true)
    self.layer = display.newColorLayer(cc.c4b(0,0,0,0))
        :pos(0,0)
        :addTo(self)
    self.layer:setTouchEnabled(true)
    self:addTo(display.getRunningScene(),500)

    local delay_ = 1.0
    if delay then
        delay_ = delay
    end

    logger:log("delay_ = "..delay_)

    if delay_ ~= -1 then
        self.scheduleid_ = rp.schedulerFactory:delayGlobal(function()
            self:hide()
        end, delay_)
    end

    --预防道具赛从赛道回来，偶现点不动的情况
    if display.getRunningScene().name == "HallScene" then
        if rp.hallCurView == "ARENAVIEW" and rp.arenaEntryType == 2 then--道具赛房间列表
            wq.TouchHelper.new(self.layer, handler(self, self.onTouch))
        end
    else
        if self.scheduleid_ then
            rp.schedulerFactory:unscheduleGlobal(self.scheduleid_)
            self.scheduleid_ = nil
        end
        self:removeSelf()
    end
end

function ShieldLayer:onTouch(target, evtName, pos)
   if evtName == wq.TouchHelper.CLICK then
        logger:log("click by ARENAVIEW prop...")
        if self.scheduleid_ then
            rp.schedulerFactory:unscheduleGlobal(self.scheduleid_)
            self.scheduleid_ = nil
        end
        self:removeSelf()
    end
end

function ShieldLayer:hide()
    logger:log("ShieldLayer:hide")
    self:removeSelf()
end

function ShieldLayer:onCleanup()
    if self.scheduleid_ then
        rp.schedulerFactory:unscheduleGlobal(self.scheduleid_)
        self.scheduleid_ = nil
    end
end

return ShieldLayer
