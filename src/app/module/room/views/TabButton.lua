
local TabButton = class("TabButton", function()
    return display.newNode()
end)

function TabButton:ctor(params)
    self.curIndex_ = 1

    self.num_ = params.num
    if params.labels then
        self.labels_ = params.labels
    else
        self.labels_ = {}
        for i = 1, self.num_ do self.labels_[i] = cc.ui.UILabel.new({text = ""}) end
    end
    self.tabFrontSrc_ = params.tabFrontSrc
    self.tabBackSrc_ = params.tabBackSrc
    self.padding_ = params.padding

    if params.disableLabels then
        self.disableLabels_ = params.disableLabels
    else
        self.disableLabels_ = {}
    end

    if params.tabWidth then
        self.tabWidth_ = params.tabWidth
    else
        self.tabWidth_ = 0
    end

    if params.tabHeight then
        self.tabHeight_ = params.tabHeight
    else
        self.tabHeight_ = 0
    end

    self.offsetY_ = 0
    if params.offsetY then
        self.offsetY_ = params.offsetY
    end

    self.labelOffsetX_ = 0
    if params.labelOffsetX then
        self.labelOffsetX_ = params.labelOffsetX
    end

    self.labelOffsetY_ = 0
    if params.labelOffsetY then
        self.labelOffsetY_ = params.labelOffsetY
    end

    self.buttonOffSetX_ = self.labelOffsetX_ or 0
    if params.buttonOffSetX then
        self.buttonOffSetX_ = params.buttonOffSetX
    end

    self.isVertical_ = false
    if params.isVertical then
        self.isVertical_ = true
    end

    self.tabs_ = {}
    self.tabLight = display.newSprite("#chip_light.png"):addTo(self,-1):scale(1.1)
    if self.isVertical_ then
        for i = 1 , self.num_ do
            self.tabs_[i] = cc.ui.UIPushButton.new({normal=self.tabBackSrc_,press = self.tabBackSrc_,disabled = self.tabFrontSrc_})
            :onButtonPressed(function(event)
--                self.tabs_[i]:pos(-self.labelOffsetX_,-(self.tabHeight_ + self.padding_)*(i - 1))
            end)
            :onButtonRelease(function(event)
--                self.tabs_[i]:pos(0,-(self.tabHeight_ + self.padding_)*(i - 1))
            end)
            :onButtonClicked(handler(self,self.onTabClick))
            :setButtonLabel("normal", self.labels_[i])
            :setButtonLabelOffset(self.labelOffsetX_, self.labelOffsetY_)
            :addTo(self)
            --在这里判断disabled
            if self.disableLabels_[i] then
                self.tabs_[i]:setButtonLabel("disabled", self.disableLabels_[i])
            end

            self.tabs_[i]:pos(-self.buttonOffSetX_,-(self.tabHeight_ + self.padding_)*(i - 1))
        end
    else
        for i = 1 , self.num_ do
            self.tabs_[i] = cc.ui.UIPushButton.new({normal=self.tabBackSrc_,press = self.tabBackSrc_,disabled = self.tabFrontSrc_})
                :onButtonPressed(function(event)
--                    self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),-self.offsetY_)
                end)
                :onButtonRelease(function(event)
--                    self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),0)
                end)
                :onButtonClicked(handler(self,self.onTabClick))
                :setButtonLabel(self.labels_[i])
                :setButtonLabelOffset(self.labelOffsetX_, self.labelOffsetY_)
                :addTo(self)

            --在这里判断disabled
            if self.disableLabels_[i] then
                self.tabs_[i]:setButtonLabel("disabled", self.disableLabels_[i])
            end

            self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),-self.offsetY_)
        end
    end
    --当前设为第一个tab
    self.tabs_[1]:setButtonEnabled(false)
    self.tabs_[1]:updateButtonLable_()
    self.tabs_[1]:pos(0,0)
    self.tabs_[1]:scale(1.1)
    self.tabLight:pos(0,0)
   -- self:onTabClick({target == self.tabs_[1]})
end

function TabButton:setCallback(callback)
    self.callback_ = callback
    return self
end

function TabButton:onTabClick(event)

    rl.SoundManager:playSounds(rl.SoundManager.btn_click)
    local index = 1

    if self.isVertical_ then
        for i = 1 , self.num_ do
            if self.tabs_[i] == event.target then
                index = i
                self.tabs_[i]:setButtonEnabled(false)
                self.tabs_[i]:pos(0,-(self.tabHeight_ + self.padding_)*(i - 1))
                self.tabs_[i]:scale(1.1)
                self.tabLight:pos(0,-(self.tabHeight_ + self.padding_)*(i - 1))
            else
                self.tabs_[i]:setButtonEnabled(true)
                self.tabs_[i]:pos(-self.buttonOffSetX_,-(self.tabHeight_ + self.padding_)*(i - 1))
                self.tabs_[i]:scale(1)
            end
        end
    else
        for i = 1 , self.num_ do
            if self.tabs_[i] == event.target then
                index = i
                self.tabs_[i]:setButtonEnabled(false)
                self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),0)
                self.tabs_[i]:scale(1.1)
                self.tabLight:pos((self.tabWidth_ + self.padding_)*(i - 1),0)
            else
                self.tabs_[i]:setButtonEnabled(true)
                self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),-self.offsetY_)
                self.tabs_[i]:scale(1)
            end
        end
    end
    if  self.callback_ then
       self.callback_(index)
    end

    self.curIndex_ = index
end

-- function TabButton:setCurTabIndex(i)
--     if self.curIndex_ == i then return end
--     local index = i
--
--     if self.isVertical_ then
--         for i = 1 , self.num_ do
--             if i == index then
--                 self.tabs_[i]:setButtonEnabled(false)
--                 self.tabs_[i]:pos(0,-(self.tabHeight_ + self.padding_)*(i - 1))
--                 self.tabLight:pos(0,-(self.tabHeight_ + self.padding_)*(i - 1))
--             else
--                 self.tabs_[i]:setButtonEnabled(true)
--                 self.tabs_[i]:pos(-self.buttonOffSetX_,-(self.tabHeight_ + self.padding_)*(i - 1))
--             end
--         end
--     else
--         for i = 1 , self.num_ do
--             if i == index  then
--                 self.tabs_[i]:setButtonEnabled(false)
--                 self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),0)
--                 self.tabLight:pos((self.tabWidth_ + self.padding_)*(i - 1),0)
--             else
--                 self.tabs_[i]:setButtonEnabled(true)
--                 self.tabs_[i]:pos((self.tabWidth_ + self.padding_)*(i - 1),-self.offsetY_)
--             end
--         end
--     end
--
--     self.curIndex_ = index
-- end

function TabButton:getTabs()
    return self.tabs_
end
return TabButton
