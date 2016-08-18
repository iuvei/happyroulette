--
-- Author: vincent
-- Date: 2015-11-30 18:20:52
--
--[[
修正滚动条的坐标
]]

local UIListView = cc.ui.UIListView
local SBListView = class("SBListView", UIListView)

SBListView.SCROLLBAR_ZORDER = 11
SBListView.SCROLLBAR_LEFT = 0
SBListView.SCROLLBAR_RIGHT = 1

function SBListView:ctor(params)
	SBListView.super.ctor(self, params)
	if params and params.scrollbarSide then
		self.scrollbarSide = params.scrollbarSide
	else 
		self.scrollbarSide = SBListView.SCROLLBAR_RIGHT
	end
end

function SBListView:enableScrollBar()
	local bound = self.scrollNode:getCascadeBoundingBox()
	if self.sbV then
		self.sbV:setVisible(false)
		transition.stopTarget(self.sbV)
		self.sbV:setOpacity(128)
		local size = self.sbV:getContentSize()
		if self.viewRect_.height < bound.height then
			self.isSbvVisible = true
			local barH = self.viewRect_.height*self.viewRect_.height/bound.height
			if barH < size.width then
				-- 保证bar不会太小
				barH = size.width
			end
			self.sbV:setContentSize(size.width, barH)

			if self.scrollbarSide == SBListView.SCROLLBAR_RIGHT then
				self.sbV:setPosition(
					self.viewRect_.x + self.viewRect_.width - size.width/2, self.viewRect_.y + barH/2)
			else
				self.sbV:setPosition(
					-self.viewRect_.width/2- size.width, self.viewRect_.y + barH/2)
			end
		else
			self.isSbvVisible = false
		end
	end
	if self.sbH then
		self.sbH:setVisible(false)
		transition.stopTarget(self.sbH)
		self.sbH:setOpacity(128)
		local size = self.sbH:getContentSize()
		if self.viewRect_.width < bound.width then
			local barW = self.viewRect_.width*self.viewRect_.width/bound.width
			if barW < size.height then
				barW = size.height
			end
			self.sbH:setContentSize(barW, size.height)
			self.sbH:setPosition(self.viewRect_.x + barW/2,
				self.viewRect_.y + size.height/2)
		end
	end
end

function SBListView:drawScrollBar()
	if not self.bDrag_ then
		return
	end
	if not self.sbV and not self.sbH then
		return
	end

	local bound = self.scrollNode:getCascadeBoundingBox()
	if self.sbV then
		self.sbV:setVisible(self.isSbvVisible)
		local size = self.sbV:getContentSize()
		local maxY = bound.height - self.viewRect_.height
		local barScrollRange = self.viewRect_.height/2 - size.height/2
		local posY =  2 * barScrollRange * math.abs(self.scrollNode:getPositionY()/maxY) - barScrollRange
		local x, y = self.sbV:getPosition()
		self.sbV:setPosition(x, posY)
	end
	if self.sbH then
		self.sbH:setVisible(true)
		local size = self.sbH:getContentSize()

		local posX = (self.viewRect_.x - bound.x)*(self.viewRect_.width - size.width)/(bound.width - self.viewRect_.width)
				+ self.viewRect_.x + size.width/2
		local x, y = self.sbH:getPosition()
		self.sbH:setPosition(posX, y)
	end
end

return SBListView