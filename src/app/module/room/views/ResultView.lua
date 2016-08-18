local ResultView = class("ResultView",function()
    return display.newNode()
end)

function ResultView:ctor()
    self:setupView()
end

function ResultView:setupView()
    self.bg = display.newSprite("#result_bg.png"):addTo(self)
    self.colorBg = display.newSprite("#result_green.png"):addTo(self.bg):pos(96,144)
    self.resultLabel = cc.ui.UILabel.new({font = "tahoma",text = 0, size = 40,  color = rl.data.color.white})
        :addTo(self.colorBg)
        :align(display.CENTER)
        :pos(75,35)
end

function ResultView:setResult(result)
    local src
    if rl.isInTable(RED_NUM,result) then
        src = "result_red.png"
    elseif rl.isInTable(BLACK_NUM,result) then
        src = "result_black.png"
    else
        src = "result_green.png"
    end
    self.colorBg:setSpriteFrame(display.newSpriteFrame(src))

    self.resultLabel:setString(result)
end

return ResultView
