local EventDispatcher = class("EventDispatcher")

function EventDispatcher:ctor()
    self.eventProxy = {}
    cc(self.eventProxy):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function EventDispatcher:dispatchEvent(event)
    if type(event) == "string" then
        local name = event
        event = {}
        event.name = name
    end
    return self.eventProxy:dispatchEvent(event)
end

function EventDispatcher:addEventListener(eventName, listener, tag)
    return self.eventProxy:addEventListener(eventName, listener, tag)
end

-- handleId是由addEventListener返回的一个唯一标识
function EventDispatcher:removeEventListener(handleId)
    return self.eventProxy:removeEventListener(handleId)
end

function EventDispatcher:removeEventListenersByTag(tag)
    return self.eventProxy:removeEventListenersByTag(tag)
end

function EventDispatcher:removeEventListenersByEvent(eventName)
    return self.eventProxy:removeEventListenersByEvent(eventName)
end

function EventDispatcher:hasEventListener(eventName)
    return self.eventProxy:hasEventListener(eventName)
end

return EventDispatcher.new()
