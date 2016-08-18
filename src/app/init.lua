rl = rl or {}

local mt = {}
mt.__index = function(t, k)
	if k == "userData" then
		return wq.DataStorage:getData(rl.DataKeys.USER_DATA)
	elseif k == "userDefault" then
		return cc.UserDefault:getInstance()
	elseif k == "configData" then
        return wq.DataStorage:getData(rl.DataKeys.CONFIG_DATA)
	end
end
setmetatable(rl, mt)

rl.curRoomId = nil

rl.ui = import(".ui.init")
rl.data = import(".data.init")
rl.widthScale = display.width / 960
rl.heightScale = display.height / 640

rl.bgScale = 1
if display.width > 1140 and display.height == 640 then
	rl.bgScale = display.width / 1140
elseif display.height > 640 and display.width == 960 then
	rl.bgScale = display.height / 640
end

rl.DataKeys = import(".keys.DataKeys")
rl.EventKeys = import(".keys.EventKeys")
rl.StorageKeys = import(".keys.StorageKeys")

rl.SoundManager = import(".manager.SoundManager").new()
rl.DialogManager = import(".manager.DialogManager").new()
rl.TopTipsManager = import(".manager.TopTipsManager").new()
rl.TipsManager = import(".manager.TipsManager").new()
-- GameManager = import(".manager.GameManager").new()

rl.schedulerFactory = wq.SchedulerFactory.new()

import(".utils.Functions").exportMethods(rl)
import(".utils.utf8str")

-- rl.socket = {}
-- rl.socket.RoomSocket = import(".socket.RoomSocket").new()
-- rl.socket.BroadcastSocket = import(".socket.BroadcastSocket").new()

rl.TransitionHelper = import(".utils.TransitionHelper").new()
rl.ButtonHelper = import(".utils.ButtonHelper").new()

rl.ImageGetter = wq.ImageGetter.new()
rl.ImageGetter.CACHE_TYPE_HEAD = "CACHE_TYPE_HEAD"

rl.ImageGetter:addCacheConfig({cacheType = rl.ImageGetter.CACHE_TYPE_HEAD, path = device.writablePath .."head" .. device.directorySeparator, isLruCached = true})

if device.platform == "android" then
	rl.Native = import(".utils.LuaJavaBridge").new()
	rl.Facebook = import("app.module.login.component.FacebookComponAndroid").new()
    rl.Push = import("app.module.login.component.XingeComponAndroid").new()
elseif device.platform == "ios" then
    rl.Native = import(".utils.LuaObjcBridge").new()
    rl.Facebook = import("app.module.login.component.FacebookComponIos").new()
    rl.Push = import("app.module.login.component.XingeComponIos").new()
else
    rl.Native = import(".utils.LuaBridgeAdapter")
    rl.Facebook = import("app.module.login.component.FacebookComponAdapter").new()
end

return rl
