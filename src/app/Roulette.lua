
require("config")
require("constant")
require("cocos.init")
require("framework.init")
require("wenqing.init")
require("app.init")
require("bmob.init")
require("app.manager.GameManager")

GameState = require("framework.cc.utils.GameState")
GameData  = {}

local Roulette = class("Roulette", cc.mvc.AppBase)

function Roulette:ctor()
    Roulette.super.ctor(self)
    appConfig = require("appConfig")--应用配置文件
    math.randomseed(os.time())
end

function Roulette:run()
    -- init GameState
    GameState.init(function(param)
       local returnValue = nil
       if param.errorCode then
           print("error")
       else
           -- crypto
           if param.name=="save" then
               local str=json.encode(param.values)
               str=crypto.encryptXXTEA(str, "abcd")
               returnValue={data=str}
           elseif param.name=="load" then
               local str=crypto.decryptXXTEA(param.values.data, "abcd")
               returnValue=json.decode(str)
           end
           -- returnValue=param.values
       end
       return returnValue
    end, "data.txt","1234")
    GameData = GameState.load()
    if not GameData then
       GameData = {}
    end

    cc.FileUtils:getInstance():addSearchPath("res/")
    bmob.BmobSDKInit:initialize("303bb583d6fc7eb6782512e572fa89c5","5e2e3c3a90e969917804671ce8e1f4a8")
    rl.SoundManager:preloadSound(rl.SoundManager.uiSounds)

    wq.HttpService.setDefaultUrl(bmob.BmobSDKInit.BASE_URL)
    -- rl.SoundManager:preloadMusic(rl.SoundManager.uiSounds)
    display.addSpriteFrames("common.plist", "common.png",handler(self,self.onTextureComplete_))
end

function Roulette:onTextureComplete_()
    self:enterScene("LoginScene")
end

function Roulette:onEnterBackground()
    Roulette.super.onEnterBackground(self)
    -- if rl and rl.configData then
    -- 	rl.socket.BroadcastSocket:disconnect()
    -- end
end

function Roulette:onEnterForeground()
    Roulette.super.onEnterForeground(self)
    -- if rl and rl.configData then
    -- 	rl.socket.BroadcastSocket:connect(rl.configData.broad_ip, rl.configData.broad_port, true)
    -- end
end

return Roulette
