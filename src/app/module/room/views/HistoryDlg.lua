
local DialogBase = rl.ui.DialogBase
local HistoryDlg = class("HistoryDlg", DialogBase)

local WIDTH,HEIGHT = 550,400

function HistoryDlg:ctor(data)
    HistoryDlg.super.ctor(self, cc.size(WIDTH,HEIGHT))
end

function HistoryDlg:onShowed()

    self.title =  cc.ui.UILabel.new({font = "tahoma",
        text = wq.LangTool.getText("COMMON","HISTORY"),
        size = 36,
        color = cc.c3b(233,217,184)})
        :align (cc.ui.TEXT_ALIGN_CENTER)
        :pos(0,HEIGHT/2 - 38)
        :addTo(self)

    local split = display.newScale9Sprite("#dialog_split_icon.png", 0, HEIGHT/2 - 75,
        cc.size(WIDTH - 100, 2)):addTo(self)

    self:setupView()
    self:addCloseButton()
end

function HistoryDlg:setupView()
    local resTable = GameData.gameResult or {}
    local showTale = {}

    if #resTable > 60 then
        for i = #resTable - 59,#resTable do
            showTale[i + 60 - #resTable] = resTable[i]
        end
    else
        showTale = resTable
    end

    for i = 1, #showTale do
        local num = showTale[i]
        local src = ""
        if rl.isInTable(RED_NUM,num) then
            src = "#history_red.png"
        elseif rl.isInTable(BLACK_NUM,num) then
            src = "#history_black.png"
        else
            src = "#history_green.png"
        end
        local xi = i%10
        if xi == 0 then xi = 10 end

        local yi = math.ceil(i/10)

        local ball = display.newSprite(src):addTo(self):pos(50*xi - 277, -50*yi + 135)
        local labelNum = cc.ui.UILabel.new({font = "tahoma",text = num, size = 23,  color = rl.data.color.white}):align(display.CENTER):addTo(ball):pos(23,25)
    end
end

return HistoryDlg
