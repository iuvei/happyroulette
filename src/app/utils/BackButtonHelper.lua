local BackButtonHelper = class("BackButtonHelper")

function BackButtonHelper:createBackButton()

    if self.backButton_ then
        return self.backButton_
    end

    self.isInView_ = false

    self.backButton_ = cc.ui.UIPushButton.new({normal="#btn_back.png"})
        :onButtonClicked(handler(self,self.onBackBtnClicked_))
        :pos(display.right - 60,display.bottom -42)

    rl.ButtonHelper:onClickAnimation(self.backButton_)
    return self.backButton_
end

function BackButtonHelper:removeBackButton()
    if self.backButton_ then
        self.backButton_:removeFromParent()
        self.backButton_ = nil
    end
end

function BackButtonHelper:onBackBtnClicked_()
    rl.SoundManager:playSounds(rl.SoundManager.btn_back)
    self.callback_()
end

function BackButtonHelper:setCallback(callback)
    self.callback_ = callback
end

function BackButtonHelper:playEnterAnimation(delay,onComplete)

    if self.isInView_ then
        return
    end

    self.isInView_ = true

    local move1 = cc.MoveBy:create(0.2, cc.p(0, 105))
    local move2 = cc.MoveBy:create(0.2, cc.p(0, -11))
    local sequenceAction = cc.Sequence:create( move1, move2)

    transition.execute(self.backButton_, sequenceAction, {delay = delay, onComplete = onComplete})
end

function BackButtonHelper:playExitAnimation(delay,onComplete)
    if not self.isInView_ then
        return
    end

    self.isInView_ = false

    local move = cc.MoveBy:create(0.2, cc.p(0, -94))
    transition.execute(self.backButton_, move, {delay = delay, onComplete = onComplete})
end

return BackButtonHelper
