local DataResolver = class("DataResolver")

local HEAD_LEN = 4

local function checkHead(buf)
    local cmd = -1
    local len = -1
    local pos = buf:getPos()
    buf:setPos(1)

    if buf:readByte() == string.byte("W") then
        flag = buf:readByte()
        len = buf:readUShort()
    end

    buf:setPos(pos)
    return flag, len
end

function DataResolver:ctor(socketName)
	self.log = wq.Logger.new(socketName .. ".DataResolver")
end

function DataResolver:read(buf)
	local ret = {}
	while true do
		if not self.buf_ then
			self.buf_ = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
		else
			self.buf_:setPos(self.buf_:getLen() + 1)
		end

		local available = buf:getAvailable()
		local buffLen = self.buf_:getLen()
		if available <= 0 then
			break
		else
			local headCorrected = (buffLen >= HEAD_LEN)
			if not headCorrected then
				if available + buffLen >= HEAD_LEN then
					for i = 1, HEAD_LEN - buffLen do
						self.buf_:writeRawByte(buf:readRawByte())
					end
					headCorrected = true
				else
					for i = 1, available do
						self.buf_:writeRawByte(buf:readRawByte())
					end
					break
				end
			end

			if headCorrected then
				local flag, bodyLen = checkHead(self.buf_)
				self.log:logf("flag %d bodylen %d", flag, bodyLen)

				if bodyLen == 0 then
					ret[#ret + 1] = {}
					self:reset()
				elseif bodyLen > 0 then
					available = buf:getAvailable()
					buffLen = self.buf_:getLen()
					if available <= 0 then
						break
					elseif available + buffLen >= HEAD_LEN + bodyLen then
						for i = 1, HEAD_LEN + bodyLen - buffLen do
							self.buf_:writeRawByte(buf:readRawByte())
						end
						local packet = self:resolve(self.buf_)
						if packet then
							ret[#ret + 1] = packet
						end
						self:reset()
					else
						for i = 1, available do
							self.buf_:writeRawByte(buf:readRawByte())
						end
						break
					end
				else
					return false, "Package head check error, " .. cc.utils.ByteArray.toString(self.buf_, 16)
				end
			end
		end
	end
	return true, ret
end

function DataResolver:resolve(buf)
	self.log:log("#[RESOLVE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]")
	local flag = buf:setPos(2):readByte()
	local len = buf:readUShort()
	local ret = buf:readStringBytes(len)
	-- self.log:log("#[RESOLVE] ret:" .. ret)
	return ret
end

function DataResolver:reset()
    self.buf_ = nil
end

return DataResolver
