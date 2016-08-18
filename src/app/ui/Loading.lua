--
-- Author: viking@iwormgame.com
-- Date: 2015-04-27 15:53:25
--
local Loading = class("Loading", function()
	return display.newNode()
end)

function Loading:ctor(args)

	if args and args.isShield then
		self.isShield = args.isShield
		self.shieldLayer = display.newColorLayer(cc.c4b(0,0,0,0))
		:pos(0,0)
		:addTo(self)
		self.shieldLayer:setTouchEnabled(false)
	end

	if args and args.string then
		self.string  = args.string

		self.bg = display.newScale9Sprite("#dark_tips_bg.png", 0, 0,
			cc.size(1, 1)):addTo(self):hide()

		self.label = cc.ui.UILabel.new({ font = "tahoma", text = self.string, size = 32, color = cc.c3b(255, 255, 255) }):align(display.CENTER):addTo(self.bg)
		local size = self.label:getContentSize()

		self.juhuaCan = display.newSprite("#juhua.png"):addTo(self.bg)
--		local action = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
--		self.juhuaCan:runAction(action)

		local padding =24
		local contentWidth,contentHeight = size.width + padding + 20, size.height + padding + 94 + 20
		self.bg:setContentSize(contentWidth, contentHeight)
		self.bg:setColor(cc.c3b(150, 150, 150))
		self.juhuaCan:pos(contentWidth/2, contentHeight - 94/2 - 10)
		self.label:pos(contentWidth/2, (size.height + padding) / 2 + 10)
	else
		self.juhuaCan = display.newSprite("#juhua.png"):addTo(self):pos(94/2, 94/2):hide()
	end
end

function Loading:setLoading(isLoading)

	if  self.isShield then
		self.shieldLayer:setTouchEnabled(isLoading)
	end

	if self.string then
		self.juhuaCan:stopAllActions()
		if isLoading then
			local action = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
			self.bg:show()
			self.juhuaCan:runAction(action)
		else
			self.bg:hide()
		end
	else
		self.juhuaCan:stopAllActions()
		if isLoading then
			local action = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
			self.juhuaCan:show()
			self.juhuaCan:runAction(action)
		else
			self.juhuaCan:hide()
		end
	end


	return self
end

return Loading