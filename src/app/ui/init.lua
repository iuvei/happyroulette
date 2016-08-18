--
-- Author: viking@iwormgame.com
-- Date: 2015年3月10日 下午4:08:47
--

local ui = {}


-- 普通按钮点击音效
function buttonHandler(obj, method)
    return function(...)
        rl.SoundManager:playSounds(rl.SoundManager.btn_click)
        return method(obj, ...)
    end
end

-- 关闭按钮点击音效
function closeBtnHandler(obj, method)
    return function(...)
        rl.SoundManager:playSounds(rl.SoundManager.btn_back)
        return method(obj, ...)
    end
end

--木质tab按钮点击音效
function woodTabHandler(obj, method)
    return function(...)
        -- rl.SoundManager:playSounds(rl.SoundManager.btn_wood_tab)
        return method(obj, ...)
    end
end

ui.CustomListView = import(".CustomListView")
ui.DialogBase = import(".DialogBase")
ui.UISwitchButton = import(".UISwitchButton")
ui.RankingNumber = import(".RankingNumber")
ui.QuitLayer = import(".QuitLayer")
ui.Loading = import(".Loading")
ui.PanelBase = import(".PanelBase")
ui.RPCheckBox = import(".RPCheckBox")
ui.CommonDialog = import(".CommonDialog")
-- ui.UITabHost = import(".UITabHost")
ui.ShieldLayer = import(".ShieldLayer")
ui.GetMoneyAnim = import(".GetMoneyAnim")
ui.CircleHeadView = import(".CircleHeadView")
ui.ConcatLabel = import(".ConcatLabel")
ui.ImageSwitchButton = import(".ImageSwitchButton")
ui.RPRadioButton = import(".RPRadioButton")
ui.SBListView = import(".SBListView")
ui.Tips = import(".Tips")
return ui
