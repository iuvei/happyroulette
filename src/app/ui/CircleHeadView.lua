
--用例 ：self.headSprite = rl.ui.CircleHeadView.new():addTo(self):pos(headPosX, headPosY)
local CircleHeadView = class("CircleHeadView", function()
	return display.newNode()
end)

function CircleHeadView:ctor(params)
    self.radius = 40
    self.circleSrc = "#head_circle_normal.png"
    self.circleScale = 1
    if params then
        if params.radius then
            self.radius = params.radius
        end

        if params.circleSrc then
            self.circleSrc = params.circleSrc
        end

        if params.circleScale then
            self.circleScale = params.circleScale
        end
    end
    self:setupView()
end

function CircleHeadView:setupView()
    local stencil = display.newCircle(self.radius,{x = 0, y = 0, borderColor = cc.c4f(0, 0, 0, 0), borderWidth = 0})
    self.headClipper =cc.ClippingNode:create()
    self.headClipper:setStencil(stencil)    --设置裁剪模板
    self.headClipper:setInverted(false)        --设置底板可见
    self.headClipper:setAlphaThreshold(1)   --设置绘制底板的Alpha值为0
    self.headClipper:addTo(self)

    self.headSprite = display.newSprite("#head.png"):scale(self.radius*2/100)    --被裁剪的内容
    self.headClipper:addChild(self.headSprite)
    self.circleSprite = display.newSprite(self.circleSrc):addTo(self):scale(self.circleScale)
end

function CircleHeadView:getContentSize()
    return self.circleSprite:getContentSize()
end

function CircleHeadView:setDefaultSpriteFrame(res)
    if not res then
        self.headSprite:setSpriteFrame(display.newSpriteFrame("head.png"))
    else
        self.headSprite:setSpriteFrame(display.newSpriteFrame(res))
    end
end

function CircleHeadView:setTexture(texture, scale)
    if texture == nil then
        return
    end
    local scale_ = scale or 1
    local textureSize = texture:getContentSize()
    self.headSprite:setTexture(texture)
    self.headSprite:setTextureRect(cc.rect(0, 0, textureSize.width, textureSize.height))
    self.headSprite:setScaleX(self.radius*2/textureSize.width * scale_)
    self.headSprite:setScaleY(self.radius*2/textureSize.height * scale_)
end

function CircleHeadView:setSprite(sprite, scale)
    if sprite == nil then
        return
    end
    local scale_ = scale or 1
    self.headSprite:removeSelf()
    self.headSprite = sprite
    sprite:scale(self.radius*2/100 * scale_)
    self.headClipper:addChild(sprite)
end

return CircleHeadView
