
local ButtonHelper = class("ButtonHelper")

local animTime = 0.05
local scaleFactor = 1.2

function ButtonHelper:ctor()
-- body
end

function ButtonHelper:onPressScale(target, s)
    transition.scaleTo(target, {time = animTime, scale = s or scaleFactor})
end

function ButtonHelper:onReleaseScale(target, s)
    transition.scaleTo(target, {time = animTime, scale = s or 1})
end

function ButtonHelper:createMenuButton(resPath,onClick,pText,posX,posY,offsetY,noAnimate)
    local btnLabel = cc.ui.UILabel.new({font = "tahoma",text = pText, size = 24,  color = rl.data.color.white})
    btnLabel:enableOutline(rl.data.color.menuBtnOutline, 4)
--    btnLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(2,2))

    local btn = cc.ui.UIPushButton.new({normal=resPath})
        :onButtonClicked(function(event)
            -- rl.SoundManager:playSounds(rl.SoundManager.btn_wood)
            rl.ButtonHelper:shielding(event.target , 2)
            onClick()
        end)
        :setButtonLabel(btnLabel)
        :setButtonLabelOffset(0, offsetY)
        :pos(posX, posY)

    if noAnimate then
        btn:onButtonPressed(function(event)
            btn:scale(1.2)
        end)
        btn:onButtonRelease(function(event)
            btn:scale(1)
        end)
    else
        self:onClickAnimation(btn)
    end
    return btn
end

function ButtonHelper:onClickAnimation(target, s1, s2)
    target:onButtonPressed(function()
        self:onPressScale(target, s1)
    end)
        :onButtonRelease(function()
            self:onReleaseScale(target, s2)
        end)
end

--rl.ButtonHelper:shielding(target,2)
function ButtonHelper:shielding(target, duration)
    target:setTouchEnabled(false)
    target:setColor(cc.c3b(150,150,150))
    rl.schedulerFactory:delayGlobal(function()
        if not tolua.isnull(target) then--todo will be nil
            target:setTouchEnabled(true)
            target:setColor(cc.c3b(255,255,255))
        end
    end, duration)
end


return ButtonHelper
