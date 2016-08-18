
-- 签名	解释
-- ()V	参数：无，返回值：无
-- (I)V	参数：int，返回值：无
-- (Ljava/lang/String;)Z	参数：字符串，返回值：布尔值
-- (IF)Ljava/lang/String;	参数：整数、浮点数，返回值：字符串

-- 类型名	类型
-- I	整数，或者 Lua function
-- F	浮点数
-- Z	布尔值
-- Ljava/lang/String;	字符串
-- V	Void 空，仅用于指定一个 Java 方法不返回任何值

local LuaJavaBridge = class("LuaJavaBridge")
local logger = wq.Logger.new("LuaJavaBridge")

function LuaJavaBridge:ctor()
end

function LuaJavaBridge:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:logf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

function LuaJavaBridge:getMacAddress()
    local ok, ret = self:call_("com/lzstudio/common/functions/GetMacAddress", "getMacAddress", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end

    return nil
end

function LuaJavaBridge:getLoginId()
    return self:getMacAddress()
end

function LuaJavaBridge:getUserHead(callback)
    local ok, ret = self:call_("com/lzstudio/common/functions/GetUserHead", "getUserHead", {callback}, "(I)V")
    if ok then
        return ret
    end

    return nil
end

function LuaJavaBridge:getPicture(callback)
    local ok, ret = self:call_("com/lzstudio/common/functions/GetPicture", "getPicture", {callback}, "(I)V")
    if ok then
        return ret
    end


    return nil
end

function LuaJavaBridge:getVersion(callback)
    local ok, ret = self:call_("com/lzstudio/common/functions/GetVersion", "getVersion", {callback}, "(I)V")
    if ok then
        return ret
    end

    return nil
end

function LuaJavaBridge:showAd(callback)
    local ok, ret = self:call_("com/lzstudio/googleplayservices/GoolePlayServicesJavaBridge",  "showAd",{callback}, "(I)V")
    if ok then
        return ret
    end

    return nil
end

function LuaJavaBridge:getAdIsLoaded(callback)
    local ok, ret = self:call_("com/lzstudio/googleplayservices/GoolePlayServicesJavaBridge", "isLoaded", {callback}, "(I)V")
    if ok then
        return ret
    end

    return nil
end

function LuaJavaBridge:bmob(method,callback)
    local ok, ret = self:call_("com/lzstudio/bmob/BmobJavaBridge",  method, {callback}, "(I)V")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:uploadIcon(callback)
    local ok, ret = self:call_("com/lzstudio/bmob/BmobJavaBridge",  "uploadIcon", {callback}, "(I)V")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:callCloud(method,params,callback)
    logger:log("method = "..method)
    logger:log("params.money = "..params.money)
    local ok, ret = self:call_("com/lzstudio/bmob/BmobJavaBridge",  "callCloud", {method, json.encode(params),callback}, "(Ljava/lang/String;Ljava/lang/String;I)V")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:callRealTime(params,callback)
    local ok, ret = self:call_("com/lzstudio/bmob/BmobJavaBridge",  "callRealTime", {json.encode(params),callback}, "(Ljava/lang/String;I)V")
    if ok then
        return ret
    end
    return nil

end

return LuaJavaBridge
