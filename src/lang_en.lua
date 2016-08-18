
appConfig = require("appConfig")

local lang = {}
local L = lang

--公共
L.COMMON                  = {}
L.COMMON.TIPS             = "Tips"
L.COMMON.CONFIRM          = "ok"
L.COMMON.CANCEL           = "cancel"
L.COMMON.HISTORY          = "record"
L.COMMON.NOT_ENOUGH_MONEY = "not enongh money"
L.COMMON.QUITLAYER_TIPS1  = "是否退出游戏"
L.COMMON.QUITLAYER_TIPS2  = "是否退出游戏"
L.COMMON.QUITLAYER_TIPS3  = "是否退出房间,本局投注将取消"
-- L.COMMON.BACK_CLICK_

--登录面
L.LOGIN        = {}
L.LOGIN.LOGIN  = "login"
L.LOGIN.SIGNUP = "signin"

--Bmob rest api errCode
L.BMOB_REST_API_ERRCODE          = {}
L.BMOB_REST_API_ERRCODE.CODE_202 = "User name already exists !"

--大厅
L.HALL               = {}
L.HALL.EMAIL         = "mail"
L.HALL.ACHI          = "achievement"
L.HALL.FREE          = "free"
L.HALL.RECHARGE      = "recharge"
L.HALL.RANKING       = "rank"
L.HALL.SHOP          = "shop"
L.HALL.DAILY_SIGN_IN = "daily sign in"

--大厅
L.ROOM            = {}
L.ROOM.START_ROLL = "Start Roll !"

--充值
L.RECHARGE                = {}
L.RECHARGE.rechargeSucc   = "recharge success"
L.RECHARGE.rechargeFail   = "recharge failed"
L.RECHARGE.rechargeCancel = "recharge canceled"
L.RECHARGE.deliverySucc   = "delivery success"
L.RECHARGE.deliveryFail   = "delivery failed"
L.RECHARGE.deliveryCancel = "delivery canceled"

return lang
