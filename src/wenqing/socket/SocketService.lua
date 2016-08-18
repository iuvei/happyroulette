--
-- Author: viking@iwormgame.com
-- Date: 2015年3月9日 下午8:31:26
--
cc.utils = require("framework.cc.utils.init")
cc.net = require("framework.cc.net.init")
local DataPackager = import(".DataPackager")
local DataResolver = import(".DataResolver")

local SocketService = class("SocketService")
local logger = wq.Logger.new("SocketService")

SocketService.EVENT_DATA_RECEIVED 	= "SocketService.EVENT_DATA_RECEIVED"
SocketService.EVENT_ERROR           = "SocketService.EVENT_ERROR"
SocketService.EVENT_CLOSE           = "SocketService.EVENT_CLOSE"
SocketService.EVENT_CLOSED          = "SocketService.EVENT_CLOSED"
SocketService.EVENT_CONNECT_SUCCESS = "SocketService.EVENT_CONNECT_SUCCESS"
SocketService.EVENT_CONNECT_FAILURE = "SocketService.EVENT_CONNECT_FAILURE"

function SocketService:ctor(name)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.name_ = name
    self.resolver = DataResolver.new(self.name_)
	self.log = wq.Logger.new(name)
end

function SocketService:setResolver(DataResolver)
    self.resolver = DataResolver.new(self.name_)
end

function SocketService:newDataPackager()
	return DataPackager.new(self.name_)
end

function SocketService:getSocket()
	return self.socket_
end

function SocketService:connect(host, port, retryConnectWhenFailure)
	self:disconnect()
    logger:log("connect socket")
	if not self.socket_ then
        logger:log("new socket")
		self.socket_ = cc.net.SocketTCP.new(host, port, retryConnectWhenFailure or false)
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))
		self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
		self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
		self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
	end
	self.socket_:setName(self.name_):connect()
end

function SocketService:disconnect(noneEvent)
    logger:log("disconnect socket")
	if self.socket_ then
        if noneEvent then
            self.socket_:removeAllEventListeners()
            self.socket_:disconnect()
		else
            self.socket_:disconnect()
            self.socket_:removeAllEventListeners()
		end
        logger:log("destroy socket")
        self.socket_ = nil
	end
end

function SocketService:send(data)
    if self.socket_ then
        if type(data) == "string" then
            self.socket_:send(data)
        else
            self.socket_:send(data:getPack())
        end
    end
end

function SocketService:onData(event)
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    buf:writeBuf(event.data)
    buf:setPos(1)
    local success, packets = self.resolver:read(buf)
    if success then
        for _, pack in ipairs(packets) do
            local text = json.decode(pack)
            self.log:logf("[%s][%s]\n==>%s", text.header.service, text.header.method, pack)
            self:dispatchEvent({name = SocketService.EVENT_DATA_RECEIVED, data = text})
        end
    else
        self:dispatchEvent({name = SocketService.EVENT_ERROR})
    end
end

function SocketService:onClose(event)
	self.log:logf("onClose. %s", event.name)
	self:dispatchEvent({name = SocketService.EVENT_CLOSE})
end

function SocketService:onClosed(event)
	self.log:logf("onClosed. %s", event.name)
	self:dispatchEvent({name = SocketService.EVENT_CLOSED})
end

function SocketService:onConnected(event)
    self.log:logf("onConnected. %s", event.name)
    self:dispatchEvent({name = SocketService.EVENT_CONNECT_SUCCESS})
end

function SocketService:onConnectFailure(event)
	self.log:logf("onConnectFailure. %s", event.name)
	self:dispatchEvent({name = SocketService.EVENT_CONNECT_FAILURE})
end

return SocketService
