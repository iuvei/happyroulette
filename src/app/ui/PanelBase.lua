--
-- Author: viking@iwormgame.com
-- Date: 2015-04-28 15:25:41
--
local PanelBase = class("PanelBase", function()
    return display.newNode()
end)

function PanelBase:ctor(size)
    rp.ui.ShieldLayer.new()
    self.width, self.height = size.width, size.height
    self.transparentView = display.newColorLayer(cc.c4b(0,0,0,80))
        :pos(-display.cx, -display.cy)
        :addTo(self,-1)
    self.transparentView:setTouchEnabled(true)

    self.bg = display.newScale9Sprite("#panel_bg.png", 0,0,
        cc.size(self.width,self.height), cc.rect(39, 39, 502, 302))
        :addTo(self, -1)

    self.contentBg = display.newScale9Sprite("#panel_content_bg.png", 0,0,
        cc.size(self.width - 46,self.height - 140), cc.rect(17,17,2,2))
        :pos(0,-10)
        :addTo(self)
    --    self.bg = display.newSprite("#panel_background.png")
    --        :addTo(self, -1)
    self.bg:setTouchEnabled(true)
    rp.PanelManager:insertPanel(self)
end

function PanelBase:setBackground(imageName)
    self.bg:setSpriteFrame(display.newSpriteFrame(imageName))
end

function PanelBase:setContentBgSize(width, height)
    if self.contentBg then
        if not height then
            height = self.height - 140
        end
        self.contentBg:size(width, height)
    end
end

function PanelBase:addCloseButton()
    local closeBtn = cc.ui.UIPushButton.new({normal = "#dialog_close_icon.png", pressed = "#dialog_close_icon.png"}, {scale9 = true})
        :pos(self.width/2 - 10, self.height/2 - 10)
        :addTo(self, 1)
        :onButtonClicked(closeBtnHandler(self,self.hide))
    rp.ButtonHelper:onClickAnimation(closeBtn)

    return self
end

function PanelBase:addTopFlower()
    display.newSprite("#flower_left_top.png")
        :pos(-self.width/2 + 9, self.height/2 - 60)
        :addTo(self)
    return self
end

function PanelBase:addBottomFlower()
    display.newSprite("#flower_right_bottom.png")
        :pos(self.width/2 - 20, -self.height/2 + 40)
        :addTo(self)
    return self
end

function PanelBase:setCloseCallback(callback)
    self.closeCallback_ = callback
end

function PanelBase:show(NoAnimation)
    self:addTo(display.getRunningScene(),10)
    self.transparentView:pos(-display.cx, -display.cy)
    self:pos(display.cx, display.cy)
    if not NoAnimation then
        self:scale(0.2)
        transition.scaleTo(self, {time = 0.3, easing = "backout", scale = 1, onComplete=function() self:onShowed() end})
    end
    self:onShowDialog()
    return self
end

function PanelBase:hide()
    rp.PanelManager:removePanel(self)
    self:removeSelf()
    return self
end

function PanelBase:onShowed()
-- body
end

function PanelBase:onShowDialog()
-- body
end

return PanelBase