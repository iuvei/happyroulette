
local DialogBase = class("DialogBase", function()
	return display.newNode()
end)

function DialogBase:ctor(size)
    self.width, self.height = size.width, size.height
 	self.bg = display.newScale9Sprite("#dialog_background.png", 0, 0,
        cc.size(self.width, self.height), cc.rect(27, 27, 18, 18))
		:addTo(self)
    self.bg:setTouchEnabled(true)
--	CCTouchDispatcher::sharedDispatcher()->setPriority(kCCMenuTouchPriority - 1, layer);
--	local listener = cc.EventListenerTouchOneByOne:create()
--	listener:registerScriptHandler(function(touch, event)
--		print("============DialogBase touch")
--	end, cc.Handler.EVENT_TOUCH_BEGAN)
--	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.bg)
--	cc.Director:getInstance():getEventDispatcher():setPriority(listener,-999)
--	self.bg:setTouchSwallowEnabled(true)
end

function DialogBase:addCloseButton()
	local closeBtn = cc.ui.UIPushButton.new({normal = "#dialog_close_icon.png", pressed = "#dialog_close_icon.png"}, {scale9 = true})
        :pos(self.width - 5, self.height - 5)
		:addTo(self.bg, 1)
        :onButtonClicked(closeBtnHandler(self,self.hide))
	rl.ButtonHelper:onClickAnimation(closeBtn)

	return self
end

function DialogBase:show()
    -- rl.SoundManager:playSounds(rl.SoundManager.open_view)
	rl.DialogManager:insert(self)
	return self
end

function DialogBase:hide()
	rl.DialogManager:remove(self)
	return self
end

function DialogBase:onShowed()
	-- body
end

function DialogBase:onShowDialog()
	-- body
end

return DialogBase
