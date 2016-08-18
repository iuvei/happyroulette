local BmobDelegete = class("BmobDelegete")
local logger = wq.Logger.new("BmobDelegete")

function BmobDelegete:ctor()

end

--save (注册或登录成功)
function BmobDelegete.onSaveSucess(retData)
    logger:log("onSaveSucess")

    -- retData:
    -- "createdAt"    = "2016-03-20 22:17:32"
    -- "money"        = 10000
    -- "objectId"     = "72664e5dc8"
    -- "sessionToken" = "a35841be40a6951f8013ae899c3aad02"
    -- "updatedAt"    = "2016-03-27 10:11:15"
    -- "username"     = "liu2"

    wq.DataStorage:setData(rl.DataKeys.USER_DATA, retData, true)
    rl.userData.icon = retData.icon or ""
    rl.userData.money = retData.money or 0
    rl.userData.exp = retData.exp or 0
    display.addSpriteFrames("hall.plist", "hall.png", function()
		app:enterScene("HallScene")
	end)
end

function BmobDelegete.onSaveError(code,string)
    logger:log("onSaveError code = "..code..",string = "..string)
end

--update
function BmobDelegete.onUpdateSucess(retData)
    logger:log("onSaveSucess")
end

function BmobDelegete.onUpdateError(code,string)
    logger:log("onUpdateError code = "..code..",string = "..string)
end

--delete
function BmobDelegete.onDeleteSucess(retData)
    logger:log("onSaveSucess")
end

function BmobDelegete.onDeleteError(code,string)
    logger:log("onDeleteError code = "..code..",string = "..string)
end

--reset
function BmobDelegete.onResetSucess(retData)
    logger:log("onSaveSucess")
end

function BmobDelegete.onResetError(code,string)
    logger:log("onResetError code = "..code..",string = "..string)
end

--email verify
function BmobDelegete.onEmailVerifySucess(retData)
    logger:log("onSaveSucess")
end

function BmobDelegete.onEmailVerifyError(code,string)
    logger:log("onEmailVerifyError code = "..code..",string = "..string)
end

--request
function BmobDelegete.onRequestDone(code,string)
    logger:log("onRequestDone code = "..code..",string = "..string)
end

--reset
function BmobDelegete.onResetDone(code,string)
    logger:log("onResetDone code = "..code..",string = "..string)
end

--login
function BmobDelegete.onLoginDone(code,string)
    logger:log("onLoginDone code = "..code..",string = "..string)
end

return BmobDelegete
