local UIListView = cc.ui.UIListView
local ListViewBase = class("ListViewBase", UIListView)

function ListViewBase:ctor(params, itemClass)
	ListViewBase.super.ctor(self, params)
	self.base_visibleCount = 0
	self:setItemClass(itemClass)
	self:setBounceable(false)

	self.listMargin_ = params.listMargin or {left = 0, right = 0, top = 0, bottom = 0}
end

function ListViewBase:setItemClass(itemClass)
	self.itemClass_ = itemClass
	return self
end

function ListViewBase:setData(data)
    if #self.items_ > 0 then
        self:removeAllItems()
    end

	if data == nil then
		return
	end
	self.data_ = data
	local listNum = 0
	self.isTabled = false
	if type(data) == "table" then
		listNum = #data
		self.isTabled = true
	else
		listNum = data
	end
	if listNum == 0 then
		return
	end
	self.base_visibleCount = listNum

	if self.bAsyncLoad then
	    self:releaseAllFreeItems_()
		self:setDelegate(handler(self, self.asyncDelegate))
	else
		for i = 1, listNum do
			local content = self.itemClass_.new(self,{index = i,listNum = listNum})
			content:setIdx(i)
			if self.isTabled then
				content:setData(data[i])
			else
				content:setData(i)
			end

			local item = self:newItem(content)
			content:setParentItem(item)
			item:setMargin({left = self.listMargin_.left, right = self.listMargin_.right, top = self.listMargin_.top, bottom = self.listMargin_.bottom})

			item:setItemSize(self.itemClass_.WIDTH, self.itemClass_.HEIGHT)
			self:addItem(item)
		end
	end
	self:reload()
end

function ListViewBase:getData()
	return self.data_
end

function ListViewBase:asyncDelegate(listView, tag, idx)
    if UIListView.COUNT_TAG == tag then
        return self.base_visibleCount or 0
    elseif UIListView.CELL_TAG == tag then
        local item
        local content
        item = listView:dequeueItem()
        if not item then
			content = self.itemClass_.new(self)
			content:setIdx(idx)
			if self.isTabled then
				content:setData(self.data_[idx])
			else
				content:setData(idx)
			end
			item = self:newItem(content)
			content:setParentItem(item)
            item:setMargin({left = self.listMargin_.left, right = self.listMargin_.right, top = self.listMargin_.top, bottom = self.listMargin_.bottom})
			item:setItemSize(self.itemClass_.WIDTH, self.itemClass_.HEIGHT)
		else
			content = item:getContent()
			content:setIdx(idx)
			if self.isTabled then
				content:setData(self.data_[idx])
			else
				content:setData(idx)
			end
        end
        return item
    elseif UIListView.UNLOAD_CELL_TAG == tag then
    	-- printInfo("UIListView.UNLOAD_CELL_TAG idx: %d", idx)
    end
end

function ListViewBase:setHook(tag, args)
	for _,item in ipairs(self.items_) do
		if item then
			item:getContent():onHook(tag, args)
		end
	end
end

function ListViewBase:getAllItem()
	local items = {}
	for i,item in ipairs(self.items_) do
		if item then
			local listItem = item:getContent()
			table.insert(items, i, listItem)
		end
	end
	return items
end

return ListViewBase
