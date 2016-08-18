local CountTimer = class("CountTimer",function()
    return display.newNode()
end)

function CountTimer:ctor()
    self:setupView()
end

function CountTimer:setupView()
    self.bg = display.newSprite("#counter_bg.png"):addTo(self)
    self.progressTimer = display.newProgressTimer("#counter_progress.png", 0):addTo(self)
    self.progressTimer:setReverseDirection(true)
    self.progressTimer:setPercentage(0)
    self.front = display.newSprite("#counter_front.png"):addTo(self)
    self.label = cc.ui.UILabel.new({font = "tahoma",text = "0", size = 34,  color = rl.data.color.white})
    :align(display.CENTER)
    :addTo(self)
end

function CountTimer:updateView(data)
	self.label:setString(math.floor(data.lestTime))
	self.progressTimer:setPercentage(data.lestTime/TIME_PER_GAME*100)
end

return CountTimer
