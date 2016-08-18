--
-- Author: viking@iwormgame.com
-- Date: 2015-04-30 14:37:51
--
local RPCheckBox = class("RPCheckBox", function()
	return display.newNode()
end)

function RPCheckBox:ctor(args)
	if  args.uiType and  args.uiType == 2 then
		display.newSprite("#checkbox_bg_rectangle.png"):addTo(self)
	else
		display.newSprite("#checkbox_bg_circle.png"):addTo(self)
	end

	self.fg = display.newSprite("#checkbox_fg.png"):addTo(self):hide()
	self.isCheck_ = false
	self.callback = args.callback
	if not args.cancleClick then
		wq.TouchHelper.new(self, handler(self, self.onClick_), false, true)
	end
	
end

function RPCheckBox:setCheck(isCheck)
	self.isCheck_ = isCheck
	if isCheck then
		self.fg:show()
	else
		self.fg:hide()
	end

	if self.callback then
		self.callback(self, isCheck)
	end
end

function RPCheckBox:isChecked()
	return self.isCheck_
end

function RPCheckBox:onClick_(target, eventName)
    if wq.TouchHelper.CLICK  == eventName then
       self.isCheck_ = not self.isCheck_
       self:setCheck(self.isCheck_)
    end
end

return RPCheckBox