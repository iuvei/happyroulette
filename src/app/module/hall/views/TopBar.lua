local TopBar = class("TopBar", function()
	return display.newNode()
end)

local logger = wq.Logger.new("TopBar")

function TopBar:ctor()
	self:setupView()
	self:initObserver()
end

function TopBar:initObserver()
	if not self.isInitObserver then
	        self.isInitObserver = true
			self.moneyHandlerId = wq.DataStorage:addFieldObserver(rl.DataKeys.USER_DATA, "money", function(value)
            	self:setMoneyLabel(value)
        	end)

			self.nameHandlerId = wq.DataStorage:addFieldObserver(rl.DataKeys.USER_DATA, "nickName", function(value)
            	self:setNameLabel(value)
        	end)

	        self.userIconHandlerId = wq.DataStorage:addFieldObserver(rl.DataKeys.USER_DATA, "icon", function(value)
	            if rl.userData.icon ~= "" then

	                self.getterId = rl.ImageGetter:getImage(rl.userData.icon, function(success, texture)

	                    if success then
	                        self.headSprite:setTexture(texture, 0.9)
	                    end
	                end, rl.ImageGetter.CACHE_TYPE_HEAD)
	            end
	        end)
	    end
end

function TopBar:setupView()
    self.bg = display.newScale9Sprite("#hall_top_bar.png",0, 0, cc.size(955, 67)):addTo(self)

	--头像
    self.headSprite = rl.ui.CircleHeadView.new():addTo(self):pos(-420, 0):scale(0.9)
    if rl.userData.icon ~= "" then
        self.getterId = rl.ImageGetter:getImage(rl.userData.icon, function(success, texture)
            if success then
                self.headSprite:setTexture(texture, 1)
            end
        end, rl.ImageGetter.CACHE_TYPE_HEAD)
    end
	wq.TouchHelper.new(self.headSprite, handler(self, self.onHeadClick_), false, true)

	--名字
	self.nameLabel = cc.ui.UILabel.new({font = "tahoma",text = rl.formatLongStr(rl.userData.nickName,12) or "nickName", size = 28,  color = cc.c3b(53,44,31)})
	:pos(-368,20)
	:addTo(self)

	--等级
	self.levelLabel = cc.ui.UILabel.new({font = "tahoma",text = "Lv.".."99", size = 20,  color = cc.c3b(53,44,31)})
	:pos(-368,-6)
	:addTo(self)

	--等级进度条
	self.levelProgressBar = wq.ui.ProgressBar.new(
        {
            fillTexture = "#level_progress.png",
            backgroundTexture = "#level_progress_bg.png",
        },
        {
            backgroundSize = cc.size(110,14),
            fillSize = cc.size(22,14)
        }
    ):pos(-295,-8)
    :addTo(self)

	--万恶的分割线1
	display.newSprite("#hall_top_split.png"):addTo(self):pos(-147,0)

	--金币节点
	local moneyNode = display.newScale9Sprite("#hall_chip_bg.png",0,0, cc.size(340, 57), cc.rect(58,28,1,1)):addTo(self):pos(40,0)
	self.moneyLabel = cc.ui.UILabel.new({font = "tahoma",text = rl.formatNumberThousands(rl.userData.money) or 0,size = 24,  color = cc.c3b(0xf6,0xf0,0xd9)})
	:align(cc.ui.TEXT_ALIGN_CENTER)
	:pos(170,28)
	:addTo(moneyNode)

	--万恶的分割线2
	display.newSprite("#hall_top_split.png"):addTo(self):pos(240,0)

	self.btnHelp = cc.ui.UIPushButton.new({normal = "#btn_help.png"})
		:pos(310,0)
		:addTo(self)
		:onButtonClicked()
	rl.ButtonHelper:onClickAnimation(self.btnHelp)

	self.btnSetting = cc.ui.UIPushButton.new({normal = "#btn_setting.png"})
		:pos(405,0)
		:addTo(self)
		:onButtonClicked()
	rl.ButtonHelper:onClickAnimation(self.btnSetting)
end

function TopBar:setMoneyLabel(value)
	transition.execute(self.moneyLabel,cc.ScaleTo:create(0.1,1.2),{onComplete = function()
        transition.execute(self.moneyLabel,cc.ScaleTo:create(0.2,1))
    end})

    self.moneyLabel:setString(rl.formatNumberThousands(value))
end

function TopBar:setNameLabel(value)
	self.nameLabel:setString(rl.formatLongStr(value,12))
end

function TopBar:getHeadCallback(headPath)
    logger:log("getHeadCallback headPath = "..headPath)
    self.ivPath = headPath
    cc.Director:getInstance():getTextureCache():removeTextureForKey(headPath)

    local content = display.newSprite(headPath)    --被裁剪的内容
    self.headSprite:setSprite(content, 0.9)

    --上传头像
	bmob.uploadFile(headPath,bmob.BmobDelegete)
    -- wq.HttpService.UploadFile(headPath, function(data)
    --     local retData = json.decode(data)
    --     if retData and retData.ret == 0 then
    --         if self.getterId then
    --             rl.ImageGetter:cancelTaskById(self.getterId)
    --             self.getterId = nil
    --         end
    --         rl.userData.icon = retData.icon
    --         rl.TopTipsManager:insert(wq.LangTool.getText("Setting", "uploadImgSucc"))
    --     end
    -- end, function()
    -- end)
end

function TopBar:onHeadClick_(target, eventName)
    if wq.TouchHelper.CLICK  == eventName then
		-- rl.Native:uploadIcon(function(data)
		-- 	dump(data)
		-- 	local  retData = json.decode(data)
		-- 	if retData.ret == 0 then
		-- 		rl.userData.icon = retData.icon
		-- 		rl.schedulerFactory:delayGlobal(function()
	 --                self:getHeadCallback(retData.filePath)
  --               end, 1)
		-- 	end
		-- end)
        rl.Native:getUserHead(function(result)
            print("rl.Native:getUserHead path = "..result)
            rl.schedulerFactory:delayGlobal(function()
                self:getHeadCallback(result)
            end, 1)
        end)
    elseif wq.TouchHelper.BEGAN  == eventName then
    elseif wq.TouchHelper.ENDED  == eventName then
    end
end


function TopBar:onCleanup()
	if self.moneyHandlerId then
        wq.DataStorage:removeFieldObserver(rl.DataKeys.USER_DATA, "money", self.moneyHandlerId)
    end

    if self.nameHandlerId then
        wq.DataStorage:removeFieldObserver(rl.DataKeys.USER_DATA, "name", self.nameHandlerId)
    end

    if self.userIconHandlerId then
        wq.DataStorage:removeFieldObserver(rl.DataKeys.USER_DATA, "icon", self.userIconHandlerId)
    end

	if self.getterId then
        rl.ImageGetter:cancelTaskById(self.getterId)
        self.getterId = nil
    end
end

return TopBar
