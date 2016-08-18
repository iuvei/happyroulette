--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 上午11:44:27
--

local DialogManager = class("DialogManager")
local Z_ORDER = 201

function DialogManager:ctor()
    self:initData()
end

function DialogManager:initData()
    self.stack_ = {}

    self.view = display.newNode()
    self.view:retain()
    self.view:setNodeEventEnabled(true)
    self.view.onCleanup = handler(self, function ()
        if self.bgView_ then
            self.bgView_:removeFromParent()
            self.bgView_ = nil
        end

        for key, DialogData in ipairs(self.stack_) do
            if DialogData.Dialog then
                DialogData.Dialog:removeFromParent()
            end
            self.stack_[key] = nil
        end
        self.zOrder_ = 2
    end)
    self.zOrder_ = 2	
end

function DialogManager:insert(Dialog, hasAnimation)
	if hasAnimation == nil then
		hasAnimation = true
	end

    if not self.view then
		self:initData()
    end

	if not self.view:getParent() then
		self.view:addTo(display.getRunningScene(), Z_ORDER)
	end

	if self:hasDialog(Dialog) then
		self:remove(Dialog)
	end
    local DialogId = #self.stack_ + 1
    self.stack_[DialogId] = {Dialog = Dialog}
    
    Dialog:pos(display.cx, display.cy)
	if hasAnimation then
		Dialog:scale(0.2)
		if Dialog.onShowed then
			transition.scaleTo(Dialog, {time = 0.3, easing = "backout", scale = 1, onComplete=function() Dialog:onShowed() end})
		else
			transition.scaleTo(Dialog, {time = 0.3, easing = "backout", scale = 1})
		end
	end
	Dialog:addTo(self.view, self.zOrder_)
	self.zOrder_ = self.zOrder_ + 2
	
    if not self.bgView_ then
        self.bgView_ = display.newColorLayer(cc.c4b(0,0,0,100))
            :pos(0, 0)
            :addTo(self.view)
    end	
	self.bgView_:setLocalZOrder(Dialog:getLocalZOrder() - 1)
    self.bgView_:setTouchEnabled(true)   
    self.bgView_:setTouchSwallowEnabled(true)	

	if Dialog.onShowDialog then
		Dialog:onShowDialog()
	end
	
	return DialogId
end

function DialogManager:remove(Dialog)
	if Dialog then
		self.zOrder_ = self.zOrder_ - 2
		local isFound, index = self:hasDialog(Dialog)
		if isFound then
            table.remove(self.stack_, index)
		end
		
		if #self.stack_ == 0 then
			self.view:removeFromParent()
			self.view = nil
		else
            self.bgView_:setLocalZOrder(Dialog:getLocalZOrder() - 3)
		end
        Dialog:removeFromParent()
	end
end

function DialogManager:removeAllDialogs()
	if self.view then
		self.view:removeFromParent()
		self.view = nil
	end
end

function DialogManager:hasDialog(Dialog)
	for i, DialogData in ipairs(self.stack_) do
		if DialogData.Dialog == Dialog then
			return true, i
		end
	end
	return false, 0
end

return DialogManager