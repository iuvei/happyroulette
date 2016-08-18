--
-- Author: viking@iwormgame.com
-- Date: 2015年3月9日 下午8:30:00
--

local DataPackager = class("DataPackager")

function DataPackager:ctor(socketName)
    self.log = wq.Logger.new(socketName .. ".DataPackager")
end

function DataPackager:package(body)
	local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)

    buf:writeByte(string.byte("W"))

	buf:writeByte(0)--flag

    buf:writeUShort(string.len(body))

    buf:writeStringBytes(body) --写包体

	buf:setPos(buf:getLen() + 1)
    self.log:logf("package: %s [%s]", buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
	return buf
end

return DataPackager
