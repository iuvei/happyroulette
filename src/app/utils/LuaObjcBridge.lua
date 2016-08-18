--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午5:01:29
--

local LuaObjcBridge = class("LuaObjcBridge")
local logger = wq.Logger.new("LuaObjcBridge")

function LuaObjcBridge:ctor()
end

function LuaObjcBridge:getOpenUdid()
	local openUdid = cc.UserDefault:getInstance():getStringForKey("OPEN_UDID")
	if not openUdid or openUdid == "" then
		openUdid = device.getOpenUDID()
		cc.UserDefault:getInstance():setStringForKey("OPEN_UDID", openUdid)
		cc.UserDefault:getInstance():flush()
	end
	return openUdid
end

function LuaObjcBridge:getLoginId()
	return self:getOpenUdid()
end

function LuaObjcBridge:getUserHead(callback)
	luaoc.callStaticMethod("GetUserHead", "getUserHead", {callback = callback, isFeedbacked = false})
end

function LuaObjcBridge:getPicture(callback)
	luaoc.callStaticMethod("GetUserHead", "getUserHead", {callback = callback, isFeedbacked = true})
end

function LuaObjcBridge:getVersion(callback)
    return luaoc.callStaticMethod("CommonFunctions", "getVersion", {callback = callback})
end

function LuaObjcBridge:showAd(callback)
	return luaoc.callStaticMethod("AdmobFunctions", "showAd", {callback = callback})
end

function LuaObjcBridge:getAdIsLoaded(callback)
	return luaoc.callStaticMethod("AdmobFunctions", "getAdIsLoaded", {callback = callback})
end

return LuaObjcBridge