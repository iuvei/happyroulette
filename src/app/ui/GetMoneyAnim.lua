--领取金币动画
--用例：rp.ui.GetMoneyAnim.new()

local GetMoneyAnim = class("GetMoneyAnim", function()
    return display.newNode()
end)

function GetMoneyAnim:ctor(param)

    self.hasShield = 1 --默认是有透明黑色遮罩的
    if param and param.hasShield then self.hasShield = param.hasShield  end
    self.hasLight = 1 --默认是有光的
    if param and param.hasLight then self.hasLight = param.hasLight end
    self.posX = display.cx
    if param and param.posX then self.posX = param.posX  end
    self.posY = display.cy
    if param and param.posY then  self.posY = param.posY end

    if param and param.value then  self.value = param.value end

    if param and param.callback then  self.callback_ = param.callback end
    --    self.posY = display.cy
--    self.posY = display.cy
--    if param and param.posY then  self.posY = param.posY  end
    if self.hasShield == 1 then
        self.transparentView = display.newColorLayer(cc.c4b(0,0,0,100))
            :pos(0,0)
            :addTo(self)
        self.transparentView:setTouchEnabled(true)
    end

    self:addTo(display.getRunningScene())
    self:setLocalZOrder(300)

    if self.hasLight == 1 then
        local light =  display.newSprite("#award_light.png"):pos(self.posX,self.posY):addTo(self)
        light:scale(1.2)
        local ray =  display.newSprite("#award_ray.png"):pos(self.posX,self.posY):addTo(self)

        light:setColor(rp.data.color.yellow)
        ray:setColor(rp.data.color.yellow)

        local action1 = cc.RepeatForever:create(cc.RotateBy:create(4, 360))
        local action2 = cc.RepeatForever:create(cc.RotateBy:create(4, -360))
        light:runAction(action1)
        ray:runAction(action2)
    end

    if self.value then
        cc.ui.UILabel.new({font = "tahoma",text = self.value,size = 32,color = rp.data.color.yellow}):addTo(self):pos(self.posX,self.posY - 80):align(display.CENTER)
    end

    self.coinBatch_ = display.newBatchNode("common.png"):addTo(self)
    local coin4 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX- 14,self.posY + 10):rotation(105):scale(0.8)
    local coin3 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX- 14,self.posY + 18):rotation(105):scale(0.8)
    local coin2 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX- 14,self.posY + 26):rotation(105):scale(0.8)
    local coin1 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX- 15,self.posY + 34):rotation(105):scale(0.8)
    local coin6 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX+ 30,self.posY - 12):rotation(120):scale(0.8)
    local coin5 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX+ 30,self.posY - 5):rotation(110):scale(0.8)
    local coin7 = display.newSprite("#coin_big.png"):addTo(self.coinBatch_):pos(self.posX,self.posY - 25):rotation(0):scale(0.8)

    rp.SoundManager:playSounds(rp.SoundManager.get_money)

    local delay = 0.5
    local interval = 0.2

    transition.execute(coin1, self:anim(), {delay = delay})
    transition.execute(coin2, self:anim(), {delay = delay + 1 * interval})
    transition.execute(coin3, self:anim(), {delay = delay + 2 * interval})
    transition.execute(coin4, self:anim(), {delay = delay + 3 * interval})
    transition.execute(coin5, self:anim(), {delay = delay + 4 * interval})
    transition.execute(coin6, self:anim(), {delay = delay + 5 * interval})
    transition.execute(coin7, self:anim(), {delay = delay + 6 * interval, onComplete = function()
        if self.callback_ then
            self.callback_()
        end
        self:removeSelf()
    end})
end

function GetMoneyAnim:anim()

    local bezierTo = cc.BezierTo:create(0.5,{cc.p(self.posX + 130, self.posY + 70),cc.p(self.posX + 140, self.posY + 120),cc.p(display.left + 390, display.top - 40)})

--    local moveTo1 = cc.MoveTo:create(0.2, cc.p(display.cx + 70, display.cy + 100))
--    local moveTo2 = cc.MoveTo:create(0.3, cc.p(display.left + 405, display.top - 36))
    local scaleTo1 = cc.ScaleTo:create(0.5,1.1)

    local spawn = cc.Spawn:create(bezierTo,scaleTo1)

    local scaleTo2 = cc.ScaleTo:create(0.2,0)
    local sequenceAction = cc.Sequence:create( spawn, scaleTo2)
    return sequenceAction
end


return GetMoneyAnim