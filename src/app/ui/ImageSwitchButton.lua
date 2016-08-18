--
-- Author: Amy@haymus.com
-- Date: 2015-10-12 11:48:08
--
local ImageSwitchButton = class("ImageSwitchButton", function()
	return display.newNode()
end)

local logger = wq.Logger.new("ImageSwitchButton")

function ImageSwitchButton:ctor(parameters)
	self.num_ = parameters.num
	self.width_ = parameters.size.width
    self.height_ = parameters.size.height
    self.sliderWidth_ = self.width_/self.num_

    --性别槽
    if not parameters.bgfilename then
        parameters.bgfilename = "#sex_groove.png"
    end

    if not parameters.bgPaddingPos then
        parameters.bgPaddingPos = cc.p(0,0)
    end

    self.bgPaddingPos = parameters.bgPaddingPos

    cc.ui.UIImage.new(parameters.bgfilename, {scale9 = false})
        :pos(parameters.bgPaddingPos.x/2, parameters.bgPaddingPos.y/2)
        :setLayoutSize(self.width_- parameters.bgPaddingPos.x, self.height_- parameters.bgPaddingPos.y):addTo(self)

    --当前滑条位置
    self.curIndex_ = 1

    --设置自身点击
    self:setContentSize( self.width_, self.height_)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(self, self.onImageButtonTouch_))

end

--spriteFrames 保存了亮暗图片{{"girl_sex_bright.png", "gril_sex_dark.png"}, {"boy_sex_bright.png", "boy_sex_dark.png"}}
function ImageSwitchButton:setSpriteFrames(spriteFrames)
    self.spriteFrames_ = spriteFrames
    self.sprites_ = {}
    for i = 1 , self.num_ do
    	self.sprites_[i] = display.newSprite("#"..self.spriteFrames_[i][2])
        	:pos(self.sliderWidth_*(i - 1) + (self.sliderWidth_/2),self.height_/2 + 2, 0)
        	:addTo(self)
    end

    self.sprites_[1]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[1][1]))
end

function ImageSwitchButton:setCallback(callback)
    self.callback_ = callback
end


function ImageSwitchButton:setOnSlider(res,option)

    local capInsets_ = cc.rect(40/2, 0, 2, 0)
    local res_ = "#sex_button.png"

    if res then
        res_ = res
    end

    if option and option.capInsets then
        capInsets_ = option.capInsets
    end

    self.slider_ = cc.ui.UIImage.new(res_, {scale9 = false, capInsets = capInsets_}):addTo(self):pos(0, 0)

    self.slider_:setLayoutSize(self.sliderWidth_ , self.height_)

    if self.height_ < 54 then
        self.slider_:setScaleY(self.height_/54)
    end

    self.slider_:setTouchEnabled(true)
    self.slider_:setTouchSwallowEnabled(true)
    self.slider_:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(self, self.onImageSliderTouch_))

    return self
end

--自身点击事件
function ImageSwitchButton:onImageButtonTouch_(event)
	if event.name == "began" then
        for i = 1 , self.num_ do
        	--点击时显示的性别 暗的状态
            self.sprites_[i]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[i][2]))
        end
        return true
    elseif event.name == "moved" then
    elseif event.name == "clicked" then
    elseif event.name == "ended" or event.name  == "canceled" then
        local nodePoint = self:convertToNodeSpace(cc.p(event.x ,event.y))
        local index = math.ceil(nodePoint.x / self.sliderWidth_)

        if index >self.num_ then
            index = self.num_
        end

        if index < 1 then
            index = 1
        end

        self:onImageSwitchSlideToAdjust(index)
    end
end

--滑条点击事件
function ImageSwitchButton:onImageSliderTouch_(event)

    if event.name  == "began" then
        self.isMoved_ = false
        for i = 1 , self.num_ do
            self.sprites_[i]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[i][2]))
        end

        return true
    elseif event.name  == "moved" then
        local targetX = self.slider_:getPosition()
        --改变后的位置
        local tmpX = targetX + (event.x-event.prevX)
        if tmpX >= 0 and tmpX <= (self.width_ -self.sliderWidth_) then
            self.slider_:setPosition(tmpX, 0)
        end

    elseif event.name  == "ended" or event.name  == "cancelled" then
        local targetX = self.slider_:getPosition()
        local index = math.floor(targetX / self.sliderWidth_)+1
        local adjust = targetX % self.sliderWidth_
        if adjust > (self.sliderWidth_/2) then
            index = index +1
        end

        if index >self.num_ then
            index = self.num_
        end

        if index < 1 then
            index = 1
        end

        self:onImageSwitchSlideToAdjust(index)

    end
end

function ImageSwitchButton:onImageSwitchSlideToAdjust(index)
	--滑动结束前不可点击
    rp.SoundManager:playSounds(rp.SoundManager.btn_slide)

    self:setTouchEnabled(false)
    self.slider_:setTouchEnabled(false)
    transition.execute(self.slider_,cc.MoveTo:create(0.2, cc.p(self.sliderWidth_ * (index - 1),0)),{onComplete = function()
        self:setTouchEnabled(true)
        self.slider_:setTouchEnabled(true)
        self.sprites_[index]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[index][1]))

        if self.curIndex_ ~= index then
            self:onSwitchSlideAdjustDone(index)
        end

        self.curIndex_ = index

    end })
end

function ImageSwitchButton:setCurIndex(index)
    self.curIndex_ = index
    self.slider_:pos(self.sliderWidth_ * (index - 1),0)
    for i = 1 , self.num_ do
        if i == index then
            self.sprites_[i]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[i][1]))
        else
            self.sprites_[i]:setSpriteFrame(display.newSpriteFrame(self.spriteFrames_[i][2]))
        end
    end
end

function ImageSwitchButton:getCurIndex()
    return self.curIndex_
end

function ImageSwitchButton:onSwitchSlideAdjustDone(index)
    self.callback_(index)
end

return ImageSwitchButton
