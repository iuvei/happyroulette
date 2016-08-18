local BmobObject = import(".BmobObject")
local BmobFile   = class("BmobFile",BmobObject)

function BmobFile:uploadFile(fullpath)
    print("uploadFile = "..fullpath)
    self.m_url    = bmob.BmobSDKInit.UPLOAD_URL..rl.userData.objectId..".jpg"
    self._opType  = HTTP_OP_Type._bHTTP_SAVE
    self.delegate = function(retData)
        dump(retData)
        rl.schedulerFactory:delayGlobal(function()
            bmob.updateIcon(retData.url)
        end, 1)
    end

    -- self.m_mapData = {}
    -- self.m_mapData.filename = "head"..rl.userData.objectId..".jpg"
    -- self.m_mapData.group = "head"
    -- self.m_mapData.url = "head"..rl.userData.objectId..".jpg" --http://file.bmob.cn/ + url 就是文件上传成功后的完整地址


    self:sendFile(fullpath)
end

return BmobFile
