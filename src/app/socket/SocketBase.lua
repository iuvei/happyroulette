local SocketBase = class("SocketBase")

SocketBase.EVENT_DATA_RECEIVED 	 = "SocketBase.EVENT_DATA_RECEIVED"
SocketBase.EVENT_ERROR           = "SocketBase.EVENT_ERROR"
SocketBase.EVENT_CLOSED          = "SocketBase.EVENT_CLOSED"
SocketBase.EVENT_CONNECT_SUCCESS = "SocketBase.EVENT_CONNECT_SUCCESS"
SocketBase.EVENT_CONNECT_FAILURE = "SocketBase.EVENT_CONNECT_FAILURE"

function SocketBase:ctor(name)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.name_ = name
    self.socket_ = wq.SocketService.new(self.name_)
	self.socket_:addEventListener(wq.SocketService.EVENT_DATA_RECEIVED, handler(self, self.onDataRecieved))
    self.socket_:addEventListener(wq.SocketService.EVENT_ERROR, handler(self, self.onError))
    self.socket_:addEventListener(wq.SocketService.EVENT_CONNECT_SUCCESS, handler(self, self.onConnected))
    self.socket_:addEventListener(wq.SocketService.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
    self.socket_:addEventListener(wq.SocketService.EVENT_CLOSE, handler(self, self.onClose))
	self.socket_:addEventListener(wq.SocketService.EVENT_CLOSED, handler(self, self.onClosed))
	self.log = wq.Logger.new(self.name_)
	self:initData()
end

function SocketBase:initData()
    self.shouldConnect_ = false
    self.isConnected_ = false
    self.isConnecting_ = false
    self.isPaused_ = false
    self.delayPackCache_ = nil
    self.retryLimit_ = 1

    self.heartBeatSchedulerFactory_ = wq.SchedulerFactory.new()
end


function SocketBase:isConnected()
	return self.isConnected_
end

function SocketBase:connect(ip, port, retryConnectWhenFailure)
	self.shouldConnect_ = true
	self.ip_ = ip
	self.port_ = port
	if not self:isConnected() and not self.isConnecting_ then
		self.isConnecting_ = true

		self.log:logf("direct connect to %s:%s", self.ip_, self.port_)
		self.socket_:connect(self.ip_, self.port_, retryConnectWhenFailure)
	end
end

function SocketBase:reconnect()
	-- self.heartBeatTimeoutCount_ = 0
	self.retryLimit_ = 2
	self.socket_:disconnect()
end

function SocketBase:disconnect(noneEvent)
	self.shouldConnect_ = false
	self.isConnecting_ = false
	self.ip_ = nil
	self.port_ = nil
	self:unscheduleHeartBeat()
    self.socket_:disconnect(noneEvent)
end

function SocketBase:pause()
	self.isPaused_ = true
	self.log:log("paused event dispatching")
end

function SocketBase:resume()
	self.isPaused_ = false
	self.log:log("resume event dispatching")
	if self.delayPackCache_ and #self.delayPackCache_ > 0 then
		for i, v in ipairs(self.delayPackCache_) do
			self:dispatchEvent({name = SocketBase.EVENT_DATA_RECEIVED, packet = v})
		end
		self.delayPackCache_ = nil
	end
end

function SocketBase:newDataPackager(cmd)
    return self.socket_:newDataPackager(cmd)
end

function SocketBase:onConnected(event)
	self.isConnected_ = true
	self.isConnecting_ = false
	self.heartBeatTimeoutCount_ = 0

	self:onAfterConnected()
	self:dispatchEvent({name = SocketBase.EVENT_CONNECT_SUCCESS})
end

function SocketBase:send(packet)
    if self:isConnected() then
        self.socket_:send(packet)
    else
        self.log:error("sending packet when socket is not connected")
    end
end

function SocketBase:sendPackage(service, method, data, version)
	local package = self:newDataPackager():package(json.encode({
		header = {service = service or "", method = method or "", version = version or 1},
		data = data or {}
	}))
	self:send(package)
end

function SocketBase:onConnectFailure(event)
	self.isConnected_ = false
	self.log:log("connect failure ...")
	if not self:reconnect_() then
		self:onAfterConnectFailure()
		self:dispatchEvent({name = SocketBase.EVENT_CONNECT_FAILURE})
	end
end

function SocketBase:onError(event)
	self.isConnected_ = false
	self.socket_:disconnect(true)
	self.log:log("data error ...")
	if not self:reconnect_() then
		self:onAfterDataError()
		self:dispatchEvent({name = SocketBase.EVENT_ERROR})
	end
end

function SocketBase:onClosed(event)
	self.isConnected_ = false
	self:unscheduleHeartBeat()
	if self.shouldConnect_ then
		if not self:reconnect_() then
			self:onAfterConnectFailure()
			self:dispatchEvent({name = SocketBase.EVENT_CONNECT_FAILURE})
			self.log:log("closed and reconnect fail")
		else
			self.log:log("closed and reconnecting")
		end
	else
		self.log:log("closed and do not reconnect")
		self:dispatchEvent({name = SocketBase.EVENT_CLOSED})
	end
end

function SocketBase:onClose(event)
	self:unscheduleHeartBeat()
end

function SocketBase:reconnect_()
	self.socket_:disconnect(true)
	self.retryLimit_ = self.retryLimit_ - 1
	self.log:log("limit:"..self.retryLimit_)
	local isRetrying = true

	if self.retryLimit_ > 0 then
		self.socket_:connect(self.ip_, self.port_, false)
	else
		isRetrying = false
		self.isConnecting_ = false
	end

	return isRetrying
end

function SocketBase:onDataRecieved(event)
	local packet = event.data

	if packet.header.service == "info" and packet.header.method == "heart" then
		if self.heartBeatTimeoutId_ then
			self:onHeartBeatReceived_()
		end
	else
		self:onHandlePacket(packet)
		if self.isPaused_ then
			if not self.delayPackCache_ then
				self.delayPackCache_ = {}
			end
			self.delayPackCache_[#self.delayPackCache_ + 1] = packet
		else
			self.log:logf("%s dispatching service:%s, method:%s", self.name_, packet.header.service, packet.header.method)
			local ret, errMsg = pcall(function() self:dispatchEvent({name = SocketBase.EVENT_DATA_RECEIVED, packet = event.data}) end)
			if errMsg then
				self.log:logf("%s dispatching service:%s, method:%s error %s", self.name_, packet.header.service, packet.header.method, errMsg)
			end
		end
	end
end

function SocketBase:onHandlePacket(packet)
	self.log:log("not implemented method onHandlePacket")
end

function SocketBase:onAfterConnected()
	self.log:log("not implemented method onAfterConnected")
end

function SocketBase:onAfterConnectFailure()
	self.log:log("not implemented method onAfterConnectFailure")
end

function SocketBase:onAfterDataError()
	self:onAfterConnectFailure()
	self.log:log("not implemented method onAfterDataError")
end

function SocketBase:scheduleHeartBeat(interval, timeout)
    self.heartBeatTimeout_ = timeout
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerFactory_:unscheduleGlobalAll()
    self.heartBeatSchedulerFactory_:scheduleGlobal(handler(self, self.onHeartBeat_), interval)
end

function SocketBase:unscheduleHeartBeat()
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerFactory_:unscheduleGlobalAll()
end

function SocketBase:onHeartBeatTimeout(timeoutCount)
    self.log:log("not implemented method onHeartBeatTimeout")
end

function SocketBase:onHeartBeatReceived(delaySeconds)
    self.log:log("not implemented method onHeartBeatReceived")
end

function SocketBase:onHeartBeat_()
    self.heartBeatPackSendTime_ = wq.getTime()
    self:sendPackage("info", "heart")
    self.heartBeatTimeoutId_ = self.heartBeatSchedulerFactory_:delayGlobal(handler(self, self.onHeartBeatTimeout_), self.heartBeatTimeout_)
    self.log:log("send heart beat packet")
end

function SocketBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    self.log:log("heart beat timeout", self.heartBeatTimeoutCount_)
end

function SocketBase:onHeartBeatReceived_()
    local delaySeconds = wq.getTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
        self.heartBeatSchedulerFactory_:unscheduleGlobal(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
        self.heartBeatTimeoutCount_ = 0
        self:onHeartBeatReceived(delaySeconds)
        -- self.log:log("heart beat received", delaySeconds)
    else
        self.log:log("timeout heart beat received", delaySeconds)
    end
end


return SocketBase
