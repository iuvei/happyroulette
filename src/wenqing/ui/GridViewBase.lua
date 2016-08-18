local ListViewBase = import(".ListViewBase")
local GridViewBase = class("GridViewBase", ListViewBase)

function GridViewBase:ctor(params, itemClass)
	GridViewBase.super.ctor(self, params, itemClass)
	self.numColumns_ = params.numColumns or 3
	self.gridMargin_ = params.gridMargin or {left = 1, right = 0, top = 0, bottom = 0}
	self.horizontalSpacing_ = params.horizontalSpacing or 5
	if params.verticalSpacing then
		self.gridMargin_.bottom = params.verticalSpacing
	end
end

function GridViewBase:setData(data)
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

	self.listNum_ = listNum

	local rowNum = listNum / self.numColumns_
	if listNum % self.numColumns_ ~= 0 then
		rowNum = math.floor(rowNum) + 1
	end

	self.base_visibleCount = rowNum

	if self.bAsyncLoad then
	    self:releaseAllFreeItems_()
		self:setDelegate(handler(self, self.asyncDelegate))
	else
		for row = 1, rowNum do
			local content = display.newNode()
			content.row_ = row

			for col = 1, self.numColumns_ do
				local idx = (row - 1) * self.numColumns_ + col
				if idx > listNum then --已经大于总个数
					break
				end

				content.col_ = col
				local gridItem = self.itemClass_.new(self)
					:addTo(content, 1 , col)
					:pos((col - 1) * (self.horizontalSpacing_ +  self.itemClass_.WIDTH) + self.itemClass_.WIDTH/2, self.itemClass_.HEIGHT/2)
				gridItem:setIdx(idx)
				if self.isTabled then
					gridItem:setData(data[idx])
				else
					gridItem:setData(idx)
				end
			end

			local item = self:newItem(content)
			item:setMargin({left = self.gridMargin_.left, right = self.gridMargin_.right, top = self.gridMargin_.top, bottom = self.gridMargin_.bottom})

			item:setItemSize(self.itemClass_.WIDTH * self.numColumns_ + self.horizontalSpacing_ * (self.numColumns_ - 1), self.itemClass_.HEIGHT)
			self:addItem(item)
		end
	end
	self:reload()
end

function GridViewBase:asyncDelegate(gridview, tag, idx)
    if ListViewBase.COUNT_TAG == tag then
        return self.base_visibleCount or 1
    elseif ListViewBase.CELL_TAG == tag then
        local item
        local content
        item = gridview:dequeueItem()
        if not item then
			content = display.newNode()
			content.row_ = idx

			for col = 1, self.numColumns_ do
				local idx_ = (idx - 1) * self.numColumns_ + col
				if idx_ > self.listNum_ then --已经大于总个数
					break
				end

				content.col_ = col
				local gridItem = self.itemClass_.new(self)
					:addTo(content, 1 , col)
					:pos((col - 1) * (self.horizontalSpacing_ +  self.itemClass_.WIDTH) + self.itemClass_.WIDTH/2, self.itemClass_.HEIGHT/2)
				gridItem:setIdx(idx_)
				if self.isTabled then
					gridItem:setData(self.data_[idx_])
				else
					gridItem:setData(idx_)
				end
			end

			item = self:newItem(content)
			item:setMargin({left = self.gridMargin_.left, right = self.gridMargin_.right, top = self.gridMargin_.top, bottom = self.gridMargin_.bottom})
			item:setItemSize(self.itemClass_.WIDTH * self.numColumns_ + self.horizontalSpacing_ * (self.numColumns_ - 1), self.itemClass_.HEIGHT)
		else
			content = item:getContent()
			content.row_ = idx
			for col = 1, self.numColumns_ do
				local idx_ = (idx - 1) * self.numColumns_ + col

				local gridItem = content:getChildByTag(col)

				if idx_ > self.listNum_ then
					if gridItem then
						gridItem:hide()
					end
				else
					if not gridItem then
						gridItem = self.itemClass_.new(self)
							:addTo(content, 1 , col)
							:pos((col - 1) * (self.horizontalSpacing_ +  self.itemClass_.WIDTH), 0)
					end
					gridItem:show()
					gridItem:setIdx(idx_)
					if self.isTabled then
						gridItem:setData(self.data_[idx_])
					else
						gridItem:setData(idx_)
					end
				end
			end
        end
        return item
    elseif ListViewBase.UNLOAD_CELL_TAG == tag then
    	-- printInfo("UIListView.UNLOAD_CELL_TAG idx: %d", idx)
    end
end

function GridViewBase:setHook(tag, args)
	for _,item in ipairs(self.items_) do
		if item then
			local content = item:getContent()
			for col = 1, content.col_ do
				local gridItem = content:getChildByTag(col)
				if gridItem then
					gridItem:onHook(tag, args)
				end
			end
		end
	end
end

function GridViewBase:getAllItem()
	local items = {}
	for _,item in ipairs(self.items_) do
		if item then
			local content = item:getContent()
			for col = 1, content.col_ do
				local gridItem = content:getChildByTag(col)
				if gridItem then
					table.insert(items, gridItem)
				end
			end
		end
	end
	return items
end

return GridViewBase
