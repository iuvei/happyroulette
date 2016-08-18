--[[
UIPushButton 增加scale9的capInsets参数
]]

local WQPushButton = class("WQPushButton", cc.ui.UIPushButton)

function WQPushButton:ctor(images, options)
    if not options then options = {} end
    if options.capInsets then
        self.capInsets_ = options.capInsets
    end
    WQPushButton.super.ctor(self,images, options)
end


function WQPushButton:updateButtonImage_()
    local state = self.fsm_:getState()
    local image = self.images_[state]
    local capInsets = self.capInsets_

    if not image then
        for _, s in pairs(self:getDefaultState_()) do
            image = self.images_[s]
            if image then break end
        end
    end
    if image then
        if self.currentImage_ ~= image then
            for i,v in ipairs(self.sprite_) do
                v:removeFromParent(true)
            end
            self.sprite_ = {}
            self.currentImage_ = image

            if "table" == type(image) then
                for i,v in ipairs(image) do
                    if self.scale9_ then
                        self.sprite_[i] = display.newScale9Sprite(v)
                        if not self.scale9Size_ then
                            local size = self.sprite_[i]:getContentSize()
                            self.scale9Size_ = {size.width, size.height}
                        else
                            self.sprite_[i]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                        end
                    else
                        self.sprite_[i] = display.newSprite(v)
                    end
                    self:addChild(self.sprite_[i], UIButton.IMAGE_ZORDER)
                    if self.sprite_[i].setFlippedX then
                        if self.flipX_ then
                            self.sprite_[i]:setFlippedX(self.flipX_ or false)
                        end
                        if self.flipY_ then
                            self.sprite_[i]:setFlippedY(self.flipY_ or false)
                        end
                    end
                end
            else
                if self.scale9_ then
                    self.sprite_[1] = display.newScale9Sprite(image,0,0,cc.size(0,0),capInsets)
                    if not self.scale9Size_ then
                        local size = self.sprite_[1]:getContentSize()
                        self.scale9Size_ = {size.width, size.height}
                    else
                        self.sprite_[1]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                    end
                else
                    self.sprite_[1] = display.newSprite(image)
                end
                if self.sprite_[1].setFlippedX then
                    if self.flipX_ then
                        self.sprite_[1]:setFlippedX(self.flipX_ or false)
                    end
                    if self.flipY_ then
                        self.sprite_[1]:setFlippedY(self.flipY_ or false)
                    end
                end
                self:addChild(self.sprite_[1], -100)
            end
        end

        for i,v in ipairs(self.sprite_) do
            v:setAnchorPoint(self:getAnchorPoint())
            v:setPosition(0, 0)
        end
    elseif not self.labels_ then
        printError("UIButton:updateButtonImage_() - not set image for state %s", state)
    end
end



return WQPushButton
