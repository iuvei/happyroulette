--
-- Author: viking@iwormgame.com
-- Date: 2015年3月9日 下午8:21:21
--
local DataStorage = class("DataStorage")

function DataStorage:ctor()
    self:initData()
end

function DataStorage:initData()
    self.dataStorage  = {}
    self.keyHandlers = {}
    self.fieldHandlers = {}
    self.keys = {}
end

function DataStorage:hasData(key)
    return self.dataStorage[key] ~= nil
end

function DataStorage:setData(key, data, isTraced)
     table.insert(self.keys,key)
    --设置之后触发事件处理
    if self.keyHandlers[key] then
        for _, handler in ipairs(self.keyHandlers[key]) do
            handler(data)
        end
    end

    --字段域field设置新值
	if isTraced then
		if type(data) == "table" then
			local cloneTable = {}
			local metaTable  = 
			{
				__index    = data, 
				__newindex = function (_, field, value)
                    data[field] = value;
                    if self.fieldHandlers[key] and self.fieldHandlers[key][field] then
                        for _, handler in ipairs(self.fieldHandlers[key][field]) do
							handler(value)
						end
					end
				end
			}
            setmetatable(cloneTable, metaTable)
            self.dataStorage[key] = cloneTable

            if self.fieldHandlers[key] then
                for field, handlerTable in pairs(self.fieldHandlers[key]) do
					for _, handler in ipairs(handlerTable) do
						handler(data[field])
					end
				end
			end
		else
            self.dataStorage[key] = data
		end
	else
        self.dataStorage[key] = data
	end

    return self.dataStorage[key]
end

function DataStorage:getData(key)
	return self.dataStorage[key]
end

function DataStorage:clearData(key)
    if self:hasData(key) then

        if self.fieldHandlers[key] then
            for _, fields in pairs(self.fieldHandlers[key]) do
                for _, handler in ipairs(fields) do
--                    handler(nil)
                    handler = nil
                end
            end
        end

        if self.keyHandlers[key] then
            for _, handler in ipairs(self.keyHandlers[key]) do
--                handler(nil)
                handler = nil
            end
        end

        self.dataStorage[key] = nil

        return true
    else
        return false
    end
end

function DataStorage:clearAllData()
    if not self.keys then return end
    for i=1,#self.keys do
        self:clearData(self.keys[i])
    end
end

function DataStorage:addObserver(key, handler)
    if not self.keyHandlers[key] then
		self.keyHandlers[key] = {}
	end
	
	local handlerId = #self.keyHandlers[key] + 1
    self.keyHandlers[key][handlerId] = handler

	if self.dataStorage[key] then
		handler(self.dataStorage[key])
	end

    return handlerId
end

function DataStorage:removeObserver(key, handlerId)
    if (self.keyHandlers[key]) and self.keyHandlers[key][handlerId] then
        self.keyHandlers[key][handlerId] = nil
		return true
	end

	return false
end

function DataStorage:addFieldObserver(key, field, handler)
    if not self.fieldHandlers[key] then
        self.fieldHandlers[key] = {}
	end
    if not self.fieldHandlers[key][field] then
        self.fieldHandlers[key][field] = {}
	end

    local handlerId = #self.fieldHandlers[key][field] + 1
    self.fieldHandlers[key][field][handlerId] = handler

	if self.dataStorage[key] then
        handler(self.dataStorage[key][field])
	end

    return handlerId
end

function DataStorage:removeFieldObserver(key, field, handlerId)
    if self.fieldHandlers[key] and self.fieldHandlers[key][field] and self.fieldHandlers[key][field][handlerId] then
        self.fieldHandlers[key][field][handlerId] = nil
		return true
	end

	return false
end

function DataStorage:notifyFieldChange(key, field)
    if self.fieldHandlers[key] and self.fieldHandlers[key][field] and self.dataStorage[key] then
        for _, handler in ipairs(self.fieldHandlers[key][field]) do
			handler(self.dataStorage[key][field])
		end
	end
end

return DataStorage.new()