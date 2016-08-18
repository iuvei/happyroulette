require("lfs")
local ok, socket = pcall(function()
    return require("socket")
end)
local functions = {}

function functions.exportMethods(target)
	for key, var in pairs(functions) do
		if key ~= "exportMethods" then
			target[key] = var
		end
	end
end

--获取毫秒级别的时间,os.time(),它只提供了完整的秒
function functions.getTime()
    if ok then
        return socket.gettime()
    end
    return os.time()
end

local eventTag = 0
function functions.getEventTag()
	eventTag = eventTag + 1
	return "EventTag" .. eventTag
end

function functions.isFileExist(filename)
	  return cc.FileUtils:getInstance():isFileExist(filename)
end

function functions.isDirectoryExist(dirPath)
	return cc.FileUtils:getInstance():isDirectoryExist(dirPath)
end

function functions.mkdir(filePath)
    if not functions.isDirectoryExist(filePath) then
        local succ, err = lfs.mkdir(filePath)
        if not succ then
            print("functions.mkdir filePath:"..filePath.." not success err:"..err)
            return false
        end
    end
    print("functions.mkdir filePath:"..filePath.."success")
    return true
end

function functions.rmdir(path)
    if functions.isDirectoryExist(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode")
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end

            local succ, des = lfs.rmdir(path)
            return succ
        end
        _rmdir(path)
    end

    return true
end

function functions.cacheFile(url, callback, dirName)
    local dirPath = device.writablePath .. (dirName or "tmpfile") .. device.directorySeparator
    local hash = crypto.md5(url)
    local filePath = dirPath .. hash

    if functions.mkdir(dirPath) then
        if functions.isFileExist(filePath) then
            callback(true, io.readfile(filePath))
        else
            wq.HttpService.GetUrl(url, {}, function(data)
                io.writefile(filePath, data, "w+")
                callback(true, data)
            end,
            function()
                callback(false)
            end)
        end
    end
end

function functions.intersectsRect(rect1, rect2)
    return not ((rect1.x + rect1.width)  < rect2.x or
                (rect2.x + rect2.width)  < rect1.x or
                (rect1.y + rect1.height) < rect2.y or
                (rect2.y + rect2.height) < rect1.y)
end

--num:传入的数字
--sub_:保留小数点后面三位则sub_ = 4，默认不填则保留两位小数,sub_不能小于1
--lenth: 小于 或 等于 这个长度 则 直接 返回 原数
function functions.formatBigNumber(num,sub_,lenth)

    local len  = string.len(tostring(num))

    if not lenth then lenth = 0 end

    if len <= lenth then return tostring(num) end

    local temp = tonumber(num)
    local ret

    local sub = 3
    if sub_ then
        if sub_ < 1 then
            sub_ = 1
        end
       sub = sub_
    end
    local subStr = "%."..sub.."f"

    if len >= 13 then
        temp = temp / 1000000000000;
        ret = string.format(subStr, temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif len >= 10 then
        temp = temp / 1000000000;
        ret = string.format(subStr, temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif len >= 7 then
        temp = temp / 1000000;
        ret = string.format(subStr, temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif len >= 5 then
        temp = temp / 1000;
        ret = string.format(subStr, temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"
    else
        return tostring(temp)
    end

    if string.find(ret, "%.") then
        while true do
            local len = string.len(ret)
            local c = string.sub(ret, len - 1, string.len(ret) - 1)
            if c == "." then
                ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                break
            else
                c = tonumber(c)
                if c == 0 then
                    ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                else
                    break
                end
            end
        end
    end

    return ret
end

function functions.formatNumberThousands(num)
    return string.formatnumberthousands(num)
end

return functions
