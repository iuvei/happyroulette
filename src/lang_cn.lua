
appConfig = require("appConfig")

local lang = {}
local L = lang

--公共
L.COMMON         = {}
L.COMMON.CONFIRM = "确认"
L.COMMON.CANCEL  = "取消"
L.COMMON.HISTORY = "历史记录"
L.COMMON.NOT_ENOUGH_MONEY = "筹码不足"

--登录面
L.LOGIN        = {}
L.LOGIN.LOGIN  = "登录"
L.LOGIN.SIGNUP = "注册"

--Bmob rest api errCode
L.BMOB_REST_API_ERRCODE          = {}
L.BMOB_REST_API_ERRCODE.CODE_202 = "用户名已经存在"

--大厅
L.HALL               = {}
L.HALL.EMAIL         = "邮件"
L.HALL.ACHI          = "成就"
L.HALL.FREE          = "免费"
L.HALL.RECHARGE      = "充值"
L.HALL.RANKING       = "排行榜"
L.HALL.SHOP          = "商店"
L.HALL.DAILY_SIGN_IN = "每日签到"

return lang
