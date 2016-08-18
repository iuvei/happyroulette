--
-- Created by IntelliJ IDEA.
-- User: Vincent
-- Date: 2015/8/21 0021
-- Time: 17:27
-- To change this template use File | Settings | File Templates.
--

local ConcatLabel = class("ConcatLabel",function()
    return display.newNode()
end)

local TYPE_LABEL = 1
local TYPE_IMG = 2

function ConcatLabel:ctor(params)

    self.padding = 0
    if params.padding then self.padding = params.padding end

    self.data = params.data
    --文字{type =1 ,text = "str",color = cc.c3b(0,0,0)}
    --图片{type =2 ,src = "#coin.png"} 暂不考虑

    self.totalWidth = 0
    for i = 1, #self.data do
        self:addContent(self.data[i])
    end

end

function ConcatLabel:addContent(data)
    if data.type ==  TYPE_LABEL then
        local label = cc.ui.UILabel.new({font = "tahoma",text = ""..data.text, size = data.size,  color = data.color}):addTo(self)
        label:setAnchorPoint(0,0)



        if self.totalWidth == 0 then
            label:pos(self.totalWidth, 0)
            self.totalWidth = self.totalWidth + label:getContentSize().width
        else
            label:pos(self.totalWidth + self.padding,0)
            self.totalWidth = self.totalWidth + label:getContentSize().width + self.padding
        end

    elseif data.type == TYPE_IMG then

    end
end

function ConcatLabel:getContentWidth()
    return self.totalWidth
end

return ConcatLabel