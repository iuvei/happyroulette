local BmobSDKInit = BmobSDKInit or {}

BmobSDKInit.APP_ID               = "303bb583d6fc7eb6782512e572fa89c5"
BmobSDKInit.APP_KEY              = "5e2e3c3a90e969917804671ce8e1f4a8"
BmobSDKInit.MASTER_KEY           = "151206eb918cd7a697802ce014c18897"
BmobSDKInit.SECRET_KEY           = "1c5e34e35fce10e1"
BmobSDKInit.BASE_URL             = "https://api.bmob.cn"
BmobSDKInit.URL                  = BmobSDKInit.BASE_URL.."/1/classes/"
BmobSDKInit.USER_URL             = BmobSDKInit.BASE_URL.."/1/users"
BmobSDKInit.LOGIN_URL            = BmobSDKInit.BASE_URL.."/1/login"
BmobSDKInit.RESET_URL            = BmobSDKInit.BASE_URL.."/1/requestPasswordReset"
BmobSDKInit.REQUEST_SMS_CODE_URL = BmobSDKInit.BASE_URL.."/1/requestSmsCode"
BmobSDKInit.RESET_BY_CODE_URL    = BmobSDKInit.BASE_URL.."/1/resetPasswordBySmsCode"
BmobSDKInit.UPDATE_PWD_URL       = BmobSDKInit.BASE_URL.."/1/updateUserPassword"
BmobSDKInit.EMAIL_VERIFY_URL     = BmobSDKInit.BASE_URL.."/1/requestEmailVerify"
BmobSDKInit.CLOUD_CODE_URL       = BmobSDKInit.BASE_URL.."/1/functions/"
BmobSDKInit.UPLOAD_URL           = BmobSDKInit.BASE_URL.."/2/files/"

BmobSDKInit.USER_TABLE = "_User"

function BmobSDKInit:initialize(app_id,app_key)
    BmobSDKInit.APP_ID  = app_id
    BmobSDKInit.APP_KEY = app_key
end

function BmobSDKInit:isInitialize()
    if not BmobSDKInit.APP_ID or not BmobSDKInit.APP_KEY then
        return false
    end
    return true
end

return BmobSDKInit
