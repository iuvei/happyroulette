require("lfs")

local ImageGetter = class("ImageGetter")
local log = wq.Logger.new("ImageGetter")

ImageGetter.CACHE_TYPE_DEFAULT = "CACHE_TYPE_DEFAULT"
ImageGetter.TMP_DIR_DEFAULT = device.writablePath .. "tmpImages" .. device.directorySeparator

function ImageGetter:ctor()
    self:initData()
end

function ImageGetter:initData()
    self.id = 0
    self.cacheConfigs = {}
    self.tasks = {}

    self:addCacheConfig({cacheType = ImageGetter.CACHE_TYPE_DEFAULT, path=ImageGetter.TMP_DIR_DEFAULT})
end

--cacheType存储类型,path存储路径,isLruCached是否开启LRU缓存
function ImageGetter:addCacheConfig(cacheConfig)
    local cacheType = cacheConfig.cacheType
    self.cacheConfigs[cacheType] =  cacheConfig
	if cacheConfig.path then
		wq.mkdir(cacheConfig.path)
	else
        wq.rmdir(ImageGetter.TMP_DIR_DEFAULT)
        wq.mkdir(ImageGetter.TMP_DIR_DEFAULT)
		cacheConfig.path = ImageGetter.TMP_DIR_DEFAULT
	end
end

function ImageGetter:getId()
	self.id = self.id + 1
	return self.id
end

function ImageGetter:reGetImage(id, url, listener, cacheType)
    if url == "" or url == nil then
        return
    end
	self:cancelTaskById(id)
	cacheType = cacheType or ImageGetter.CACHE_TYPE_DEFAULT
    log:logf("reGetImage(%s, %s, %s)", id, url, cacheType)

	self:doTask(id, url, self.cacheConfigs[cacheType], listener)
end

function ImageGetter:getImage(url, listener, cacheType)
    if url == "" or url == nil then
        return
    end
    local id = self:getId()
	cacheType = cacheType or ImageGetter.CACHE_TYPE_DEFAULT
    log:logf("getImage(%s, %s, %s)", id, url, cacheType)

    self:doTask(id, url, self.cacheConfigs[cacheType], listener)
	return id
end

function ImageGetter:cancelTaskByUrl(url)
	local task = self.tasks[url]
	if task then
		task.listeners = {}
	end
end

function ImageGetter:cancelTaskById(id)
	for url, task in pairs(self.tasks) do
        task.listeners[id] = nil
	end
end

function ImageGetter:doTask(id, url, config, listener)
	local hash = crypto.md5(url)
	local filePath = config.path .. hash
    if io.exists(filePath) then
        log:logf("file exists (%s, %s, %s)", id, url, filePath)
        lfs.touch(filePath)
        local texture = cc.Director:getInstance():getTextureCache():addImage(filePath)
        if texture == nil then
            os.remove(filePath)
		elseif listener then
			listener(true, texture, filePath)
		end
	else
		local task = self.tasks[url]
		if task then
            log:logf("task is loading -> %s", url)
			task.listeners[id] = listener
		else
            log:logf("start task -> %s", url)
			task = {}
			task.listeners = {}
			task.listeners[id] = listener
			self.tasks[url] = task

            local request = network.createHTTPRequest(function(event)
                self:onResponse(event,config,filePath, task, url)
            end, url, "GET")
			task.request = request
			request:start()
		end
	end
end

function ImageGetter:onResponse(event, config, filePath, task, url)
    local request = event.request
    if event.name == "completed" then
        if request:getResponseStatusCode() ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            log:logf("code=%s", code)
            local listeners = table.values(task.listeners)
            for _, listener in ipairs(listeners) do
               listener(false, code)
            end
            self.tasks[url] = nil
        else
            -- 请求成功，显示服务端返回的内容
            local content = request:getResponseData()
            log:logf("loaded from network, save to file -> %s", filePath)
            io.writefile(filePath, content, "w+b")

            if wq.isFileExist(filePath) then
                local texture = nil
                for id, listener in pairs(task.listeners) do
                    log:logf("call listener -> " .. id)
                    if listener then
                        if not texture then
                            lfs.touch(filePath)
                            texture = cc.Director:getInstance():getTextureCache():addImage(filePath)
                        end

                        --还是为nil，就删除之
                        if not texture then
                            os.remove(filePath)
                        else
                            listener(true, texture, filePath)
                        end
                    end
                end
                if config.isLruCached then
                    if not config.cacheFileNum then
                    	config.cacheFileNum = 150
                    end
                    self:lruCache(config.path, config.cacheFileNum)
                end
            else
                log:logf("file not exists -> " .. filePath)
            end
            self.tasks[url] = nil
        end
    elseif event.name ~= "progress" then
        -- 请求失败，显示错误代码和错误消息
        log:logf("errCode=%s errmsg=%s", request:getErrorCode(), request:getErrorMessage())
        local listeners = table.values(task.listeners)
        for _, listener in ipairs(listeners) do
            listener(false, request:getErrorCode() .. " " .. request:getErrorMessage())
        end
        self.tasks[url] = nil
    end
end

function ImageGetter:lruCache(path, cacheFileNum)
    local files = {}
    local fileSortTable = {}
    local cacheFileNum_ = cacheFileNum

    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path.. device.directorySeparator ..file
            local attr = lfs.attributes(f)
            if attr.mode ~= "directory" then
                files[attr.access] = f
                fileSortTable[#fileSortTable + 1] = attr.access
            end
        end
    end

    table.sort(fileSortTable)
    while #fileSortTable > cacheFileNum_ do
        local file = files[fileSortTable[1]]
        os.remove(file)
        table.remove(fileSortTable, 1)
    end
end

function ImageGetter:removeCache()
    for _, config in pairs(self.cacheConfigs) do
        wq.rmdir(config.path)
    end
end

return ImageGetter
