--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午5:02:33
--

local LuaBridgeAdapter = {}

local mtable = {
    __index = function(table, key)
    	if LuaBridgeAdapter[key] then
			return LuaBridgeAdapter[key]
		else
           print("CALL function " .. key)
        end
    end,
}

function LuaBridgeAdapter:getLoginId()
	return "WindosTestId"
end

return setmetatable({}, mtable)
