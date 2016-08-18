--  通用对话框
--[[用例
rl.ui.CommonDialog.new({size = cc.size(0,0), hasConfirm = 1, hasCancel = 0})
:setTitle("提示")
:addContent(display.newNode())
:setConformBtnStr("str")
:setCancelBtnStr("str")
:setConfirmCallback(handler(self,self.func))
:setCancelCallback(handler(self,self.func))
:show()
]]

local DialogBase = import(".DialogBase")
local CommonDialog = class("CommonDialog", DialogBase)

function CommonDialog:ctor(param)

    --默认大小为屏幕3/4，有确认和取消按钮
    self.size_ = cc.size(display.width*3/4,display.height*3/4)
    self.hasConfirm = 1
    self.hasCancel = 1

    if param then
        if param.size then    --是否自定义size
            self.size_ = param.size
        else
            self.size_ = cc.size(display.width*3/4,display.height*3/4)
        end

        if param.hasConfirm then
            self.hasConfirm = param.hasConfirm
        else
            self.hasConfirm = 1
        end

        if param.hasCancel then
            self.hasCancel = param.hasCancel
        else
            self.hasCancel = 1
        end
    end

    CommonDialog.super.ctor(self, self.size_)

    self:setupView()
end

function CommonDialog:setupView()

    self.title =  cc.ui.UILabel.new({
        text = wq.LangTool.getText("COMMON","TIPS"),
        size = 36,
        color = cc.c3b(233,217,184)})
        :align (cc.ui.TEXT_ALIGN_CENTER)
        :pos(0,self.size_.height/2 - 38)
        :addTo(self)

        --万恶的分鸡鸡线
    local split = display.newScale9Sprite("#dialog_split_icon.png", 0, self.size_.height/2 - 75,
        cc.size(self.size_.width - 100, 2)):addTo(self)

    self:addCloseButton()
    -- self.title:enableOutline(rl.data.color.dialogTitleOutline, 2)
    self:addButton()
end

function CommonDialog:addContent(node)
    node:addTo(self)
    return self
end

function CommonDialog:setTitle(str)
    self.title:setString(str)
    return self
end

function CommonDialog:setConfirmCallback(callback)
    self.confirmCallback_ = callback
    return self
end

function CommonDialog:setCancelCallback(callback)
    self.cancelCallback_ = callback
    return self
end

function CommonDialog:addButton()
    local conformLabel = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("COMMON","CONFIRM"), size = 36,  color = rl.data.color.black})
    -- conformLabel:enableOutline(rl.data.color.btnGreenOutline, 2)

    local cancelLabel = cc.ui.UILabel.new({font = "tahoma",text = wq.LangTool.getText("COMMON","CANCEL"), size = 36,  color = rl.data.color.black})
    -- cancelLabel:enableOutline(rl.data.color.btnRedOutline, 2)


    self.conformBtn = wq.ui.WQPushButton.new({normal = "#common_btn.png"}, {scale9 = true,capInsets = cc.rect(9,32,2,2)})
        :setButtonSize(146, 64)
        :onButtonClicked(buttonHandler(self,self.onBtnConfirmClick))
        :setButtonLabel(conformLabel)
        :pos(135 * rl.widthScale, - self.size_.height/2 + 30 + 40* rl.heightScale)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.conformBtn)

    self.cancelBtn = wq.ui.WQPushButton.new({normal = "#common_btn.png"}, {scale9 = true,capInsets = cc.rect(9,32,2,2)})
        :setButtonSize(146, 64)
        :onButtonClicked(buttonHandler(self,self.onBtnCancelClick))
        :setButtonLabel(cancelLabel)
        :pos(-135 * rl.widthScale, - self.size_.height/2 + 30 + 40* rl.heightScale)
        :addTo(self)
    rl.ButtonHelper:onClickAnimation(self.cancelBtn)

    --不显示确认按钮
    if self.hasConfirm == 0 then
        self.conformBtn:hide()
    end

    --不显示取消按钮
    if self.hasCancel == 0 then
        self.cancelBtn:hide()
        --把确认按钮调至中间
        if self.hasConfirm then
            self.conformBtn:pos(0, - self.size_.height/2 + 35 + 40* rl.heightScale)
        end
    end

end

--打开更新旋转
function CommonDialog:addLoading()
    self.loading = rl.ui.Loading.new():pos(-47, -47):addTo(self):setLoading(true)
    return self
end

function CommonDialog:closeLoading()
    self.loading:setLoading(false)
    return self
end

function CommonDialog:onBtnConfirmClick()
    rl.ButtonHelper:shielding(self.conformBtn,2)
    if self.confirmCallback_ then
        self.confirmCallback_()
    end
    self:hide()
end

function CommonDialog:onBtnCancelClick()
    rl.ButtonHelper:shielding(self.cancelBtn,2)
    if self.cancelCallback_ then
        self.cancelCallback_()
    end
    self:hide()
end

function CommonDialog:setConformBtnStr(str)
    self.conformBtn:setButtonLabelString(str)
    return self;
end

function CommonDialog:setCancelBtnStr(str)
    self.cancelBtn:setButtonLabelString(str)
    return self;
end

function CommonDialog:show(hasAnimation)
    if hasAnimation == nil then
        hasAnimation = true
    end
    -- rl.SoundManager:playSounds(rl.SoundManager.open_view)
    rl.DialogManager:insert(self,hasAnimation)
    return self
end

function CommonDialog:onShowed()
end

return CommonDialog
