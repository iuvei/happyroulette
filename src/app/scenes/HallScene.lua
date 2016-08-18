
--大厅场景类
local HallScene = class("HallScene", function()
    return display.newScene("HallScene")
end)

-- local logger = wq.Logger.new("HallScene")
local HallView = import("app.module.hall.views.HallView")

--构造函数
function HallScene:ctor()
    -- cc.Director:getInstance():popScene()

    if device.platform == "android" then
        self:addChild(rl.ui.QuitLayer.new("HallScene"))
    end

    display.addSpriteFrames("hall.plist", "hall.png"
        , function()
            HallView.new():addTo(self)
        end)

end

function HallScene:onEnter()
    rl.SoundManager:playMusic(rl.SoundManager.hall, true)
end

function HallScene:onExit()
end

return HallScene
