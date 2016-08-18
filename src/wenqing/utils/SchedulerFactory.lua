local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local SchedulerFactory = class("SchedulerFactory")

function SchedulerFactory:ctor()
	self.workers = {}
end

--全局帧事件回调
function SchedulerFactory:scheduleUpdateGlobal(listener, ...)
    local workerId = #self.workers + 1
    local args = {...}
	local scheduleId = scheduler.scheduleUpdateGlobal(function()
	   if listener then
	   	   listener(unpack(args))
	   end
	end)
	self.workers[workerId] = scheduleId
	return workerId
end

function SchedulerFactory:scheduleGlobal(listener, interval, ...)
    local workerId = #self.workers + 1
    local args = {...}
    local scheduleId = scheduler.scheduleGlobal(function()
        if listener then
            listener(unpack(args))
        end
    end, interval)
    self.workers[workerId] = scheduleId
    return workerId
end

function SchedulerFactory:delayGlobal(listener, time, ...)
    local workerId = #self.workers + 1
    local args = {...}
    local scheduleId = scheduler.performWithDelayGlobal(function()
        if listener then
            listener(unpack(args))
        end
    end, time)
    self.workers[workerId] = scheduleId
    return workerId
end

function SchedulerFactory:unscheduleGlobal(workerId)
    if self.workers[workerId] then
        scheduler.unscheduleGlobal(self.workers[workerId])
        self.workers[workerId] = nil
    end
end

function SchedulerFactory:unscheduleGlobalAll()
	for _, var in ipairs(self.workers) do
		scheduler.unscheduleGlobal(var)
	end
	self.workers = {}
end

return SchedulerFactory
