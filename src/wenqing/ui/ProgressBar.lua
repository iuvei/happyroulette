local ProgressBar = class("ProgressBar", function()
    return display.newNode()
end)

function ProgressBar:ctor(textures, sizes, zorders, params)



    local fillTexture_ = textures.fillTexture
    local backgroundSize_ = sizes.backgroundSize
    local fillSize_ = sizes.fillSize

    local fillX_, fillY_, fillWidthPadding_ = 0, 0, 0
    if params then
        fillX_ = params.fillX
        fillY_ = params.fillY
        fillWidthPadding_ = params.fillWidthPadding
    end

    if not zorders then
        zorders = {1, 2}
    end
    local backgroundZorder_ = zorders[1]
    local fillZorder_ = zorders[2]

    if textures.backgroundTexture then
        local backgoundTexture_ = textures.backgroundTexture
        self.backgroundSprite_  = display.newScale9Sprite(backgoundTexture_)
            :size(backgroundSize_)
            :align(display.CENTER_LEFT, 0, 0)
            :addTo(self, backgroundZorder_)
    end

    self.fillSprite_ = display.newScale9Sprite(fillTexture_)
        :size(fillSize_)
        :align(display.CENTER_LEFT, fillX_, fillY_)
        :addTo(self, fillZorder_)

    self.progress = 0
    self.fullWidth, self.fillWidth, self.fillHeight = backgroundSize_.width - fillWidthPadding_, fillSize_.width, fillSize_.height
end

function ProgressBar:setProgress(progress)
    if progress == 0 then
        self.fillSprite_:hide()
    else
        self.fillSprite_:show()
    end

    local progress_ = progress / 100
    if self.progress == progress_ then
        return
    elseif progress_ < 0 then
        progress_ = 0
    elseif progress_ > 1 then
        progress_ = 1
    end

    self.progress = progress_
    if progress_ <= (self.fillWidth / self.fullWidth) then
        self.fillSprite_:setContentSize(cc.size(self.fillWidth, self.fillHeight))
    else
        self.fillSprite_:setContentSize(cc.size(self.fullWidth * progress_, self.fillHeight))
    end
end

function ProgressBar:getProgress()
    return self.progress
end

return ProgressBar
