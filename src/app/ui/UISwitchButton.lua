
--[[--

quick SwitchButton控件

--使用示例：

self.switch = rp.ui.UISwitchButton.new({num = 2,size = cc.size(360,49),darkColor = cc.c3b(128,128,128),brightColor = self.brightColor_})
:pos(44, 15)
:addTo(self.propertyBar)

self.switch:setSlider(cc.ui.UIImage.new("#switch_btn.png", {scale9 = true}))

self.switch:setLabels({
cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("Ranch","property"), size = 22}):align (cc.ui.TEXT_ALIGN_CENTER),
cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("Ranch","btnAccessory"), size = 22}):align (cc.ui.TEXT_ALIGN_CENTER),
})

self.switch:setCallback(handler(self,self.onSwitchSlideAdjustDone))

]]

local UISwitchButton = class("UISwitchButton", function()
    return display.newNode()
end)

function UISwitchButton:ctor(parameters)
    --设置选项数，宽高，滑条宽度
    self.num_ =  parameters.num
    self.width_ = parameters.size.width
    self.height_ = parameters.size.height
    self.sliderWidth_ = self.width_/self.num_

    --字体暗，亮的颜色
    self.darkColor_ = rp.data.color.slideBtnDark
    if parameters.darkColor then
        self.darkColor_ = parameters.darkColor
    end

    self.brightColor_ = rp.data.color.slideBtnBright
    if parameters.brightColor then
        self.brightColor_ = parameters.brightColor
    end

    self.brightOutline_ = rp.data.color.slideBtnBrightOutline
    if parameters.brightOutline then
        self.brightOutline_ = parameters.brightOutline
    end

    self.darkOutline_ = rp.data.color.slideBtnDarkOutline
    if parameters.darkOutline then
        self.darkOutline_ = parameters.darkOutline
    end


    --背景框

    if not parameters.bgfilename then
        parameters.bgfilename = "#panel_tab_background.png"
    end

    if not parameters.bgPaddingPos then
        parameters.bgPaddingPos = cc.p(10,10)
    end

    self.bgPaddingPos = parameters.bgPaddingPos

    cc.ui.UIImage.new(parameters.bgfilename, {scale9 = true})
        :pos(parameters.bgPaddingPos.x/2, parameters.bgPaddingPos.y/2)
        :setLayoutSize(self.width_- parameters.bgPaddingPos.x, self.height_- parameters.bgPaddingPos.y):addTo(self)

    --分界线
    local dividerfilename
    if not parameters.dividerfilename then
        parameters.dividerfilename = "#panel_tab_divider.png"
    end

    if not parameters.nodivider then
        for i = 1 , self.num_ - 1 do
            display.newSprite(parameters.dividerfilename):addTo(self):pos(self.sliderWidth_*(i - 1) + self.sliderWidth_, self.height_/2)
        end
    end
    
    --当前滑条位置
    self.curIndex_ = 1

    --设置自身点击
    self:setContentSize( self.width_, self.height_)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(self, self.onRectTouch_))
end

function UISwitchButton:setSlider(res,option)

    local capInsets_ = cc.rect(40/2, 0, 2, 0)
    local res_ = "#switch_btn.png"

    if res then
        res_ = res
    end

    if option and option.capInsets then
        capInsets_ = option.capInsets
    end

    self.slider_ = cc.ui.UIImage.new(res_, {scale9 = true, capInsets = capInsets_}):addTo(self):pos(0,0)

    self.slider_:setLayoutSize(self.sliderWidth_ , self.height_)

    if self.height_ < 64 then
        self.slider_:setScaleY(self.height_/64)
    end

    self.slider_:setTouchEnabled(true)
    self.slider_:setTouchSwallowEnabled(true)
    self.slider_:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(self, self.onSliderTouch_))

    return self
end

function UISwitchButton:setLabels(labels)
    self.labels_ = labels
    for i = 1 , self.num_ do

        self.labels_[i]:setPosition(self.sliderWidth_*(i - 1) + (self.sliderWidth_/2),self.height_/2)
        self.labels_[i]:setColor(self.darkColor_)
        self.labels_[i]:enableOutline(self.darkOutline_,3)
        self.labels_[i]:addTo(self)
    end

    self.labels_[1]:setColor(self.brightColor_)
    self.labels_[1]:enableOutline(self.brightOutline_,3)
end

function UISwitchButton:setCallback(callback)
    self.callback_ = callback
end

--自身点击事件
function UISwitchButton:onRectTouch_(event)
    if event.name  == "began" then
        for i = 1 , self.num_ do
            self.labels_[i]:setColor(self.darkColor_)
            self.labels_[i]:enableOutline(self.darkOutline_,3)
        end
        return true
    elseif event.name  == "moved" then
    elseif event.name  == "clicked" then
    elseif event.name  == "ended" or event.name  == "canceled" then
        local nodePoint =  self:convertToNodeSpace(cc.p(event.x ,event.y))
        local index = math.ceil(nodePoint.x / self.sliderWidth_)

        if index >self.num_ then
            index = self.num_
        end

        if index < 1 then
            index = 1
        end

        self:onSwitchSlideToAdjust(index)
    end
end

--滑条点击事件
function UISwitchButton:onSliderTouch_(event)

    if event.name  == "began" then
        self.isMoved_ = false
        for i = 1 , self.num_ do
            self.labels_[i]:setColor(self.darkColor_)
            self.labels_[i]:enableOutline(self.darkOutline_,3)
        end

        return true
    elseif event.name  == "moved" then
        local targetX = self.slider_:getPosition()
        if targetX >= 0 and targetX <= (self.width_ -self.sliderWidth_)  then
            self.slider_:setPosition(targetX + (event.x-event.prevX),0)
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

        self:onSwitchSlideToAdjust(index)

    end
end

--滑条位置自适应
function UISwitchButton:onSwitchSlideToAdjust(index)
    --滑动结束前不可点击
    rp.SoundManager:playSounds(rp.SoundManager.btn_slide)

    self:setTouchEnabled(false)
    self.slider_:setTouchEnabled(false)
    transition.execute(self.slider_,cc.MoveTo:create(0.2, cc.p(self.sliderWidth_ * (index - 1),0)),{onComplete = function()
        self:setTouchEnabled(true)
        self.slider_:setTouchEnabled(true)
        self.labels_[index]:setColor(self.brightColor_)
        self.labels_[index]:enableOutline(self.brightOutline_,3)

        if self.curIndex_ ~= index then
            self:onSwitchSlideAdjustDone(index)
        end

        self.curIndex_ = index

    end })
end

function UISwitchButton:setCurIndex(index)
    self.curIndex_ = index
    self.slider_:pos(self.sliderWidth_ * (index - 1),0)
    for i = 1 , self.num_ do
        if i == index then
            self.labels_[i]:setColor(self.brightColor_)
            self.labels_[i]:enableOutline(self.brightOutline_,3)
        else
            self.labels_[i]:setColor(self.darkColor_)
            self.labels_[i]:enableOutline(self.darkOutline_,3)
        end
    end
end

function UISwitchButton:getCurIndex()
    return self.curIndex_
end

function UISwitchButton:onSwitchSlideAdjustDone(index)
    self.callback_(index)
end

return UISwitchButton