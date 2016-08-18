--wq.TouchHelper.new(self.touchNode_, handler(self, self.onClick_), false, true)
-- function onClick_(target, eventName)
--     if wq.TouchHelper.CLICK  == eventName then
--     end
-- end

local TouchHelper = class("TouchHelper")

TouchHelper.CLICK = "CLICK"
TouchHelper.BEGAN = "BEGAN"
TouchHelper.MOVED = "MOVED"
TouchHelper.ENDED = "ENDED"

TouchHelper.CLICK_CANCELED_PX = 5

function TouchHelper:ctor(node, listener, swallowEnabled, isClickHorizontal)
    self.listener = listener
    self.node = node
    self.node:setTouchEnabled(true)
    if swallowEnabled == nil then
        swallowEnabled = true
    end
    if isClickHorizontal == nil then
        self.checkClicked = false
        self.clickCanceled = false
    else
        self.checkClicked = true
        self.clickCanceled = false
        self.isClickHorizontal_ = isClickHorizontal
    end
    self.node:setTouchSwallowEnabled(swallowEnabled)
    self.node:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
end

function TouchHelper:onTouch_(event)
    local name, x, y = event.name, event.x, event.y
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        self.clickCanceled = false
        if not self:checkTouchInSprite_(x, y) then return false end
        self:onTouchListener(TouchHelper.BEGAN, {x = x, y = y})
        return true
    end

    local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY)
        and self:checkTouchInSprite_(x, y)
    if name == "moved" then
        self:onTouchListener(TouchHelper.MOVED, {x = x, y = y})
    else
        self:onTouchListener(TouchHelper.ENDED, {x = x, y = y})
        if self.checkClicked then
            if self.isClickHorizontal_ then
                if math.abs(x - self.touchBeganX) > TouchHelper.CLICK_CANCELED_PX then
                   self.clickCanceled = true
                end
            else
                if math.abs(y - self.touchBeganY) > TouchHelper.CLICK_CANCELED_PX then
                   self.clickCanceled = true
                end
            end
        end
        if name == "ended" and touchInTarget and not self.clickCanceled then
            self:onTouchListener(TouchHelper.CLICK, {x = x, y = y})
        end
    end
end

function TouchHelper:onTouchListener(evtName, ...)
	if self.listener then
		self.listener(self.node, evtName, ...)
	end
end

function TouchHelper:checkTouchInSprite_(x, y)
    return self.node:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end

return TouchHelper
