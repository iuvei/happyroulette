local UserHead = class("UserHead",function()
    return display.newNode()
end)

function UserHead:ctor(param)
    self.commitSide = param.commitSide
    self:setupView()
end

function UserHead:setupView()
    self.head = rl.ui.CircleHeadView.new():addTo(self)
    self.flagCommit = display.newSprite("#flag_commit.png"):addTo(self.head):pos(55,-25):hide()
    if self.commitSide == 1 then
        self.flagCommit:pos(-63,-25)
    end
    local bgMoney = display.newSprite("#bg_head_money.png"):addTo(self.head):pos(0,-40)

    self.label = cc.ui.UILabel.new({font = "tahoma",text = 0, size = 22,  color = rl.data.color.yellow})
    :pos(39,13)
    :align(display.CENTER)
    :addTo(bgMoney)
end

function UserHead:setTexture(texture, scale)
    self.head:setTexture(texture, scale)
    return self
end

function UserHead:setMoney(money)
    local moneyStr = (money > 1000) and math.ceil(money/1000).."K" or money
    self.label:setString(moneyStr)
    return self
end

return UserHead
