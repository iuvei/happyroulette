
--[[
通用声音进入游戏预加载，不需释放
房间声音进入房间预加载，退出房间释放
]]
--onButtonClicked(buttonHandler(self, self.onBtnArenaClick_)) rl.SoundManager:playSounds(rl.SoundManager.btn_click)

local SoundManager = class("SoundManager")
SoundManager.uiSounds = {
    btn_click = "sounds/ui/btn_click.mp3",--普通按钮
    switch    = "sounds/ui/switch.mp3",
    btn_back  = "sounds/ui/btn_back.mp3",
    open_view = "sounds/ui/open_view.mp3",
}

SoundManager.bgMusic = {
    hall = "sounds/bg/hall.mp3",--大厅&登录
    room = "sounds/bg/room.mp3",--房间
}

SoundManager.roomSounds = {
    chip     = "sounds/room/chip.mp3",
    roll     = "sounds/room/roll.mp3",
    rollstop = "sounds/room/rollstop.mp3",
    dingding = "sounds/room/dingding.mp3",
}

for key, var in pairs(SoundManager.uiSounds) do
    SoundManager[key] = var
end

for key, var in pairs(SoundManager.bgMusic) do
    SoundManager[key] = var
end

for key, var in pairs(SoundManager.roomSounds) do
    SoundManager[key] = var
end

function SoundManager:ctor()
    self.curMusicName = ""
    self.tempMusicName = "sounds/bg/hall.mp3"
    self:updateVolume()
    self:updateMusic()
    self:updateSounds()

end

function SoundManager:preloadMusic(musicName)
    self.curMusicName = musicName
    audio.preloadMusic(musicName)
end

function SoundManager:preloadSound(soundType)
    if self[soundType] and type(self[soundType]) == "table" then
        for _, soundName in pairs(self[soundType]) do
            audio.preloadSound(soundName)
        end
    end
end

function SoundManager:unLoadSound(soundType)
    if self[soundType] and type(self[soundType]) == "table" then
        for _, soundName in pairs(self[soundType]) do
            audio.unloadSound(soundName)
        end
    end
end

function SoundManager:play(soundName, loop)
    if self.volume > 0 then
        return audio.playSound(soundName, loop)
    end
    return nil
end

--播放背景音乐
function SoundManager:playMusic(musicName, loop)
    self.tempMusicName = musicName

    if self.isMusicOn then
        if audio.isMusicPlaying() then
            if self.curMusicName ~= musicName then
                self.curMusicName = musicName
                return audio.playMusic(musicName, loop)
            end
        else
            self.curMusicName = musicName
            return audio.playMusic(musicName, loop)
        end
    end
    return nil
end

function SoundManager:stopMusic(isRelease)
    return audio.stopMusic(isRelease)
end

function SoundManager:playSounds(soundName, loop)
    if self.isSoundsOn  then
        return audio.playSound(soundName, loop)
    end
    return nil
end

--更新背景音乐状态
function SoundManager:updateMusic()
    self.isMusicOn = rl.userDefault:getBoolForKey(rl.StorageKeys.IS_MUSIC_ON, true)
    if self.isMusicOn then
        if not self.curMusicName then
            self.curMusicName = ""
        end
        if string.len(self.curMusicName) == 0 then  self.curMusicName = self.tempMusicName end
        if string.len(self.curMusicName) > 0 then
            self:playMusic(self.curMusicName,true)
        end
    else
--        audio.isMusicPlaying()
        self:stopMusic(true)
    end
end

function SoundManager:updateSounds()
    self.isSoundsOn = rl.userDefault:getBoolForKey(rl.StorageKeys.IS_SOUNDS_ON, true)
end

function SoundManager:updateVolume()
    self.volume = rl.userDefault:getIntegerForKey(rl.StorageKeys.VOLUME, 100)
    audio.setSoundsVolume(self.volume / 100)
end

return SoundManager
