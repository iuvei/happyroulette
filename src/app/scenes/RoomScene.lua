
local RoomScene = class("RoomScene", function()
	return display.newScene("RoomScene")
end)

local RoomView = import("app.module.room.views.RoomView")

function RoomScene:ctor()
	if device.platform == "android" then
        self:addChild(rl.ui.QuitLayer.new("RoomScene"))
    end

	display.addSpriteFrames("room.plist", "room.png", function()
		self:setupView()
		-- cc.Director:getInstance():pushScene(import("app.module.roulette.GameScene").new())
	end)
end

function RoomScene:setupView()
	self:addChild(RoomView.new())
end

function RoomScene:onEnter()
	rl.isRoomView = true
	rl.SoundManager:playMusic(rl.SoundManager.room, true)
end

function RoomScene:onExit()
	rl.isRoomView = false
	-- rl.TopTipsManager:reset()
	-- rl.DialogManager:removeAllDialogs()
end

function RoomScene:onCleanup()
	display.removeSpriteFramesWithFile("room.plist", "room.png")
end

return RoomScene
