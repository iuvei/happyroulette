wq = wq or {}

local functions = import(".utils.Functions")
functions.exportMethods(wq)
wq.ui = import(".ui.init")
wq.Logger = import(".utils.Logger")
wq.SchedulerFactory = import(".utils.SchedulerFactory")
wq.TouchHelper = import(".utils.TouchHelper")
wq.ImageGetter = import(".utils.ImageGetter")
wq.EventDispatcher = import(".utils.EventDispatcher")
wq.LangTool = import(".utils.LangTool")
wq.DataStorage = import(".utils.DataStorage")
wq.EventDispatcher = import(".utils.EventDispatcher")
wq.HttpService = import(".http.HttpService")
wq.SocketService = import(".socket.SocketService")

return wq
