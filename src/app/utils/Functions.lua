--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午4:46:42
--

local functions = {}

function functions.exportMethods(target)
    for key, var in pairs(functions) do
        if key ~= "exportMethods" then
            target[key] = var
        end
    end
end

--获取卖猪价钱
function functions.getPigPrice(sumGrowth)
    local data = wq.DataStorage:getData(rp.DataKeys.PIG_SELL_PRICE_DATA) or  {2500,5000,10000,30000,60000,120000}
    local star = rp.getStar(sumGrowth)
    return data[star+1]
end

--获取当前成长度（当前等级的）
--返回值1：当前等级成长度
--返回值2：下一级需要成长度
function functions.getGrowthValue(sumGrowth)

    local growth = 0
    if sumGrowth then
        growth = sumGrowth
    end
    local growth_section = rp.configData.growth_section

    -- 0,10,210,1210,5210,13210
    --10，260，1260，4260,10260
    --10,200,1000,4000,8000
   if growth >= growth_section[5] and growth < growth_section[6] then

        return growth - growth_section[5],growth_section[6] - growth_section[5]

    elseif growth >= growth_section[4] and growth < growth_section[5] then

        return growth - growth_section[4],growth_section[5] - growth_section[4]

    elseif growth >= growth_section[3] and growth < growth_section[4] then

        return growth - growth_section[3],growth_section[4] - growth_section[3]

    elseif growth >= growth_section[2] and growth < growth_section[3] then

        return growth - growth_section[2],growth_section[3] - growth_section[2]

    elseif growth >= growth_section[1] and growth < growth_section[2] then

        return growth - growth_section[1],growth_section[2] - growth_section[1]

    else --growth >= growth_section[6]

        return growth_section[6] - growth_section[5],growth_section[6] - growth_section[5]

    end
end

--设置星级
--参数1：星星精灵数组
--参数2：当前成长度
function functions.setStar(starArray,sumGrowth)
    local star = rp.getStar(sumGrowth)
    for i = 1, 5 do
        if i > star then
            starArray[i]:setVisible(false)
        else
            starArray[i]:setVisible(true)
        end
    end
end

--获取猪的星级
function functions.getStar(sumGrowth)
    local growth = 3
    if sumGrowth then
        growth = tonumber(sumGrowth)
    end

    local growth_section = rp.configData.growth_section
    -- 0,10,210,1210,5210,13210
    if growth >= growth_section[5] and growth < growth_section[6]then
        return 4
    elseif growth >= growth_section[4] and growth < growth_section[5] then
        return 3
    elseif growth >= growth_section[3] and growth < growth_section[4] then
        return 2
    elseif growth >= growth_section[2] and growth < growth_section[3] then
        return 1
    elseif growth >= growth_section[1] and growth < growth_section[2] then
        return 0
    else --growth >= growth_section[6] then
        return 5
    end
end

function functions.getNowTime(time, serverSystemTime)
    if serverSystemTime then
        functions.delt = os.difftime(serverSystemTime, os.time())
        print("getnoewtime sys:"..serverSystemTime..",my:"..os.time()..",d:"..functions.delt)
    end

    if not functions.delt then
        functions.delt = 0
    end

    return time - functions.delt
end

--上报分享数据 1 大转盘 2 成就 3 升星 4 升等级 5 竞技场 6 投注站 7拍照 8 道具场 9 5倍投注站
function functions.reportFeedData(feedId)
    wq.HttpService.Post({
        type = "user",
        apply = "feedCount",
        feed = feedId,
    },
    function(data)
        -- body
    end,
    function()
        -- body
    end)
end

--数字显示为每三位加逗号间隔
--num 数字或字符串
function functions.formatNumberThousands(num)
    if not num then
        return "0"
    end
    local str = ""..num
    local result = ""
    local len = string.len(str)
    for i = 1, len ,1 do
        if (len-i)%3 == 0 and i~=len then
            result = result..string.sub(str, i,i).. ","
        else
            result =  result..string.sub(str, i,i)
        end
    end
    return result
end

--修改str长度超过max字符后面显示“...”
function functions.formatLongStr(str, max)
    if str == nil then   return " " end
    local result = ""
--    print("str = "..str)
    local len = utf8len(str)
--    print("str len = "..len)
    if len > max then
        result = utf8sub(str,1,max).."..."
    else
        result= str
    end
    return result
end

--判断对象是否在该table中
function functions.isInTable(table,target)
    for _,v in pairs(table) do
        if v == target then
            return true
        end
    end
    return false
end

function functions.prinitTab(tab)
    for i,v in pairs(tab) do
        if type(v) == "table" then
            print("table",i,"{")
            printTab(v)
            print("}")
        else
            print(v)
        end
    end
end

function functions.test(parameters)
end

return functions
