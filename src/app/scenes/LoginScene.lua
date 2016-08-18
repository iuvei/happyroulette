
local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

local LoginView = import("app.module.login.views.LoginView")
local logger = wq.Logger.new("LoginScene")

function LoginScene:ctor()
	if device.platform == "android" then
        self:addChild(rl.ui.QuitLayer.new("LoginScene"))
    end

end

function LoginScene:onEnter()
    self:addChild(LoginView.new())
    rl.SoundManager:playMusic(rl.SoundManager.hall, true)
    logger:log("onEnter")
    -- print("rl.SoundManager.login = "..rl.SoundManager.login)
    -- audio.playSound(rl.SoundManager.login, true)
end

function LoginScene:onExit()
end

return LoginScene
