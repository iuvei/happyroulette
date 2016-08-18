-- 用法 ： rl.ui.Tips.new({string = "กำลังคั้งค่า กรุณารอคอยค่ะ"}):show() /rl.ui.Tips.new({errCode = 1}):show()

local Tips = class("Tips", function()
    return display.newNode()
end)

local Z_ORDER = 300


function Tips:ctor(params)
    if params.string then
        self.string = params.string
    end

    if params.isLoading then
        self.isLoading = true
    end

    if params.errCode then
        local errStr = wq.LangTool.getText("ErrString", "code_" .. math.abs(params.errCode))
        if string.len(errStr) == 0 then
            self.string = "Error ! code = "..params.errCode
        else
            self.string = errStr
        end
    end
    self:setupView()
    self.duration = params.duration or 2

    if self.duration < 1 then
        self.duration = 1
    end

    self.removeSchedulerId_ = rl.schedulerFactory:delayGlobal(handler(self,self.hideSelf), self.duration)
end

function Tips:setupView()

    self:pos(display.cx, display.cy)
    self:setLocalZOrder(Z_ORDER)

    --背景图
    if self.isLoading then
        --tips_bg
        self.bg = display.newScale9Sprite("#dark_tips_bg.png", 0, 0,
            cc.size(1, 1)):addTo(self)
    else
        self.bg = display.newScale9Sprite("#dark_tips_bg.png", 0, 0,--统一用黑的先
            cc.size(1, 1)):addTo(self)
    end
    --文字内容 添加到背景（因为文字动画跟着背景走）
    self.label = cc.ui.UILabel.new({ font = "tahoma", text = self.string, size = 32, color = cc.c3b(255, 255, 255) }):align(display.CENTER):addTo(self.bg)
    local size = self.label:getContentSize()

    --根据文字内容重新设定背景大小
    if self.isLoading then --有loading
        self.juhuaCan = display.newSprite("#juhua.png"):addTo(self.bg)
        local action = cc.RepeatForever:create(cc.RotateBy:create(1.5, 360))
        self.juhuaCan:runAction(action)

        local padding =24
        local contentWidth,contentHeight = size.width + padding + 20, size.height + padding + 94 + 20
        self.bg:setContentSize(contentWidth, contentHeight)
        self.bg:setColor(cc.c3b(150, 150, 150))
        self.juhuaCan:pos(contentWidth/2, contentHeight - 94/2 - 10)
        --根据背景大小重新设定文字坐标
        self.label:pos(contentWidth/2, (size.height + padding) / 2 + 10)
    else --无loading
        local padding =24
        self.bg:setContentSize(size.width + padding, size.height + padding)
        --根据背景大小重新设定文字坐标
        self.label:pos((size.width + padding) / 2, (size.height + padding) / 2)
    end

    self.bg:setOpacity(0)
end

function Tips:show()
    rl.TipsManager:insert(self)
end

function Tips:hideSelf(removeSchedulerId) --带参数，未免与自带hide()混淆所以改名hideSelf()
    if removeSchedulerId then
        rl.schedulerFactory:unscheduleGlobal(removeSchedulerId)
        self.removeSchedulerId_ = nil
    end

    rl.TipsManager:remove(self)
end

return Tips
