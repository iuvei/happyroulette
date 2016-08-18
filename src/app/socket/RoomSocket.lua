local SocketBase = import(".SocketBase")
local RoomSocket = class("RoomSocket", SocketBase)

local logger = wq.Logger.new("RoomSocket")

function RoomSocket:ctor()
	RoomSocket.super.ctor(self, "RoomSocket")
end

function RoomSocket:onHandlePacket(packet)
	local service = packet.header.service
	local method = packet.header.method
	local data = packet.data
	wq.EventDispatcher:dispatchEvent({name = rp.EventKeys.ROOMSOCKET_PACKAGE, data = {service = service, method = method, data = data}})
end

function RoomSocket:onHeartBeatTimeout(timeoutCount)
    self.log:log("implemented method onHeartBeatTimeout")
    if timeoutCount > 2 then
		self:disconnect()--断开连接
		self:connect(rp.configData.match_ip, rp.configData.match_port, true)
    end
end

function RoomSocket:onHeartBeatReceived(delaySeconds)
    self.log:log("implemented method onHeartBeatReceived")
end

function RoomSocket:onAfterConnectFailure()
	self.log:log("implemented method onAfterConnectFailure")

    self:disconnect()--断开连接
    self:connect(rp.configData.match_ip, rp.configData.match_port, true)
end

function RoomSocket:onAfterConnected()
	logger:log("")
	self:scheduleHeartBeat(5, 2)
end

return RoomSocket
