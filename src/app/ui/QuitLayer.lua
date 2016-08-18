--
-- Author: viking@iwormgame.com
-- Date: 2015-04-27 15:17:43
--
local QuitLayer = class("QuickLayer", function()
	return display.newLayer()
end)

function QuitLayer:ctor(fromView,confirmCallback)
	self.fromView = fromView or "LoginScene"
	if confirmCallback then self.confirmCallback = confirmCallback end

	local contentText = wq.LangTool.getText("COMMON", "QUITLAYER_TIPS1")
	if self.fromView == "LoginScene" then
		contentText = wq.LangTool.getText("COMMON", "QUITLAYER_TIPS1")
	elseif self.fromView == "HallScene" then
		contentText = wq.LangTool.getText("COMMON", "QUITLAYER_TIPS2")
	elseif self.fromView == "RoomScene" then
		contentText = wq.LangTool.getText("COMMON", "QUITLAYER_TIPS3")
	end


	self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if event.key == "back" then
			local node = cc.ui.UILabel.new({text = contentText, size = 36,  color = cc.c3b(233,217,184)})
			node:setAnchorPoint(0.5,0.5)
			rl.ui.CommonDialog.new({size = cc.size(540,360), hasConfirm = 1, hasCancel = 1})
			:addContent(node)
			:setConfirmCallback(handler(self,self.onConfirm))
			:show()
    		-- device.showAlert(wq.LangTool.getText("Common", "dialogTitle"),
    		-- 	wq.LangTool.getText("Common", "dialogMessage"),
    		-- 	{
    		-- 		wq.LangTool.getText("Common", "confirm"),
    		-- 		wq.LangTool.getText("Common", "cancel"),
    		-- 	}, function(event)
    		-- 	if event.buttonIndex == 1 then
    		-- 		app:exit()
    		-- 	end
    		-- end)
        end
    end)
    self:setKeypadEnabled(true)
end

function QuitLayer:onConfirm()
	if self.confirmCallback then
		self.confirmCallback()
	end

	if self.fromView == "LoginScene" then
		app:exit()
	elseif self.fromView == "HallScene" then
		app:exit()
	elseif self.fromView == "RoomScene" then
		GameManager:undoAll()
		GameManager:dispose()
		cc.Director:getInstance():popScene()
	end
end

return QuitLayer
