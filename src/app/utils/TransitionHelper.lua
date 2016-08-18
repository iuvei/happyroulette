--
-- Author: viking@iwormgame.com
-- Date: 2015-05-05 18:03:25
--
local TransitionHelper = class("TransitionHelper")

function TransitionHelper:ctor()
	-- body
end

--同时执行动画
function TransitionHelper:spawn(actions)
    if #actions < 1 then return end
    if #actions < 2 then return actions[1] end

    local prev = actions[1]
    for i = 2, #actions do
        prev = cc.Spawn:create(prev, actions[i])
    end
    return prev
end

--转动金币
function TransitionHelper:rotateCoinAnim(target,frame)
	local animName = "rotateCoin"
    local frame = frame or 8
	if not display.getAnimationCache(animName) then
		local frames = display.newFrames(animName.."%04d.png", 1, 7)
		local animation = display.newAnimation(frames, 0.8 / frame) -- x 秒播放 y 桢
		display.setAnimationCache(animName, animation)
	end
	target:stopAllActions()
	target:playAnimationForever(display.getAnimationCache(animName))
end

--更新文字动画 变大
function TransitionHelper:updateLabel(target,str)
    transition.execute(target,cc.ScaleTo:create(0.1,1.2),{onComplete = function()
        transition.execute(target,cc.ScaleTo:create(0.2,1))
    end})
    target:setString(str)
end

--更新文字动画 跳动的数字
function TransitionHelper:jumpToNum(target,fromNum,toNum,duration)--(cclabel,出事数字，结束数字，动画持续时间)
    local fromNum = fromNum
    local toNum = toNum
    local jumpNum = math.floor((fromNum - toNum)/(duration/0.05))
    local jumpNumSchedulerId_ = rl.schedulerFactory:scheduleGlobal(function()
        fromNum = fromNum - jumpNum
        target:setString(rl.formatNumberThousands(fromNum))
    end,0.05)
    rl.schedulerFactory:delayGlobal(function()
        rl.schedulerFactory:unscheduleGlobal(jumpNumSchedulerId_)
        target:setString(rl.formatNumberThousands(toNum))
    end, duration)
end

return TransitionHelper