--
-- Author: viking@iwormgame.com
-- Date: 2015-04-27 16:50:44
--
local TopTipsManager = class("TopTipsManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local Z_ORDER = 200

local paddingX = 100
local width = display.width - 2 * paddingX
local height = 58
local textScrollPX = 70
local textPaddingX = 12
local keepTime = 3--停留时间
local animTime = 0.2

function TopTipsManager:ctor()
	self.showQueue = {}
	self.isShowing = false	
	self:setupView()
end

function TopTipsManager:setupView()
	self.view = display.newNode()
	self.view:retain()	
	
    self.stencil = display.newPolygon({
        {-width/2 + textPaddingX, -height/2}, 
        {-width/2 + textPaddingX,  height/2}, 
        {width/2 - textPaddingX,  height/2}, 
        {width/2 - textPaddingX, -height/2}
    })   

    self.clipNode = cc.ClippingNode:create()
    self.clipNode:pos(0, 0)
    self.clipNode:addTo(self.view)
    self.clipNode:setInverted(false)      --设置底板可见
    self.clipNode:setAlphaThreshold(1)   --设置绘制底板的Alpha值为0
    self.clipNode:setStencil(self.stencil)

    self.label = cc.ui.UILabel.new({
        text = "", 
        size = 28, 
        color = rl.data.color.white,
        align = cc.ui.TEXT_ALIGN_CENTER
    })
    :addTo(self.clipNode)  	
    self.label:setAnchorPoint(cc.p(0.5, 0.5))
end

function TopTipsManager:reset()
	if self.view then
		self.view:removeSelf()
		self.view = nil
	end
	if  self.bg then
		self.bg:removeSelf()
		self.bg = nil
	end
	self.isShowing = false
end

function TopTipsManager:insert(tips)
	for _,v in pairs(self.showQueue) do
		if v == tips then
			return
		end
	end

	table.insert(self.showQueue, tips)

	if not self.isShowing then
		self:showNext()
	end
end

function TopTipsManager:showNext()

	if not self.view then
		self:setupView()
	end

	if self.showQueue[1] == nil then
		self.isShowing = false
		return
	end

	if not self.bg then
        self.bg = cc.ui.UIImage.new("#toptips.png", {scale9 = true}):pos(0, 0):size(width, height):addTo(self.view, -1)
        self.bg:setAnchorPoint(cc.p(0.5, 0.5))
	end

	local tips = table.remove(self.showQueue, 1)
--	print(tips)
	self.label:setString(tips)
	local labelSize = self.label:getContentSize()

	local scrollTime = (labelSize.width - (width - textPaddingX * 2)) / textScrollPX
	if scrollTime > 0 then
		local scrollPosX = labelSize.width/2 - width/2 + textPaddingX
		self.label:pos(scrollPosX, 0)
		transition.moveTo(self.label, {time = scrollTime, x = -scrollPosX, delay = keepTime/2})
	else
		scrollTime = 0
		self.label:pos(0, 0)
	end

	self.isShowing = true

    if self.view:getParent() ~= display.getRunningScene() then
        print("TopTipsManager self.view:getParent() ~= display.getRunningScene()")
        if self.view:getParent() then
            self.view:removeFromParent()
        end
        self.view:pos(display.cx, display.top + height/2)
		self.view:addTo(display.getRunningScene(), Z_ORDER)
	end	
    
	transition.moveTo(self.view, {time = animTime, x = display.cx, y = display.top - height/2 })

	self.delayHandler = scheduler.performWithDelayGlobal(handler(self, self.delayCallback), animTime + scrollTime + keepTime)
end

function TopTipsManager:delayCallback()
	if not self.view then return end
	if self.view:getParent() then
		transition.moveTo(self.view, {time = animTime, x = display.cx, y = display.top + height/2, onComplete = function()
			self:delayShowNext()
--			print("delay call back1")
		end})
	else
		self.view:pos(display.cx, display.top + height/2)
		self:delayShowNext()
--		print("delay call back2")
	end
end

function TopTipsManager:delayShowNext()
	if self.delayHandler then
		scheduler.unscheduleGlobal(self.delayHandler)
		self.delayHandler = nil
	end
	scheduler.performWithDelayGlobal(function()
		self:showNext()
	end, 1)
end

return TopTipsManager