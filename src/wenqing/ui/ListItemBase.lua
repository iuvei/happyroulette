local ListItemBase = class("ListItemBase", function()
	return display.newNode()
end)

ListItemBase.WIDTH = 0
ListItemBase.HEIGHT = 0

function ListItemBase:ctor(listView,param)

    if param and param.index then
        self.Idx_ = param.index
	end

	if param and param.listNum then
		self.listNum_ = param.listNum
    end

	self.listView_ = listView
	self:setContentSize(cc.size(ListItemBase.WIDTH, ListItemBase.HEIGHT))
end

function ListItemBase:setIdx(uIdx)
	self.Idx_ = uIdx
	return self
end

function ListItemBase:getIdx()
	return self.Idx_
end

function ListItemBase:getListNum()
	return self.listNum_
end

function ListItemBase:setData(data)
	self.data_ = data
	self:onDataChanged(data)
	return self
end

function ListItemBase:onDataChanged(data)
	-- body
end

function ListItemBase:getData()
	return self.data_
end

function ListItemBase:setParentItem(parentItem)
	self.parentItem_ = parentItem
end

function ListItemBase:getParentItem()
	return self.parentItem_
end

function ListItemBase:onHook(tag, args)
	-- body
end

return ListItemBase
