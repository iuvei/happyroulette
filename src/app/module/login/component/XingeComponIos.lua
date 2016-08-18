--
-- Author: viking@iwormgame.com
-- Date: 2015-06-18 15:30:51
--
local XingeComponIos = class("XingeComponIos")

function XingeComponIos:ctor()
	-- body
end

function XingeComponIos:registerPush(callback)
	print("XingeComponIos:registerPush")
	luaoc.callStaticMethod("CommonFunctions", "getXinGeToken", {callback = callback})
end

return XingeComponIos