bmob = bmob or {}

bmob.BmobSDKInit  = import(".baseobject.BmobSDKInit")
bmob.BmobObject   = import(".baseobject.BmobObject")
bmob.BmobUser     = import(".baseobject.BmobUser").new()
bmob.BmobFile     = import(".baseobject.BmobFile")
bmob.BmobCloud    = import(".baseobject.BmobCloud")
bmob.BmobDelegete = import(".baseobject.BmobDelegete").new()

--注册
function bmob.signUp(userName,passWord)
    bmob.BmobUser:signUp(userName,passWord)
end

--登录
function bmob.login(userName,passWord)
    bmob.BmobUser:login(userName,passWord)
end

----------------------------更新用户信息---------------------------
--更新头像url
function bmob.updateIcon(iconUrl)
    bmob.BmobUser:updateIcon(iconUrl)
end

--更新钱啊
function bmob.updateMoney(money)
    bmob.BmobUser:updateMoney(money)
end
------------------------------------------------------------------




----------------------------上传文件---------------------------
function bmob.uploadFile(fullpath)
    local bmobFile = bmob.BmobFile.new()
    bmobFile:uploadFile(fullpath)
end
----------------------------------------------------------------





----------------------------调用云端代码---------------------------
function bmob.execCloud(cloudName,param,execType,callback)
    local bmobCloud = bmob.BmobCloud.new()
    bmobCloud:execCloud(cloudName,param,execType,callback)
end
----------------------------------------------------------------



----------------------------查询---------------------------
function bmob.queryRow(tableName,objectId,callback)
    local bmobObj = bmob.BmobObject.new()
    bmobObj.m_url = bmob.BmobSDKInit.URL..tableName.."/"..objectId
    bmobObj.delegate = callback
    bmobObj:send("GET")
end
-----------------------------------------------------------

return bmob
