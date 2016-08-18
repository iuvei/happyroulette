--
-- Author: Vincent
-- Date: 2015/10/24 0024 14:50
--

local RPRadioButton = class("RPRadioButton",function() 
    return display.newNode()
end)

function RPRadioButton:ctor(args)
    self.bgSrc = args.bgSrc or "#radio_btn_bg.png"
    self.checkSrc = args.checkSrc or "#radio_btn_check.png"
    self.num = args.num or 1
    self.dir = args.dir or 1 -- 1 垂直(从上到下) 2 水平（从左往右）
    self.padding = args.padding or 60 --偷懒了，记得padding把bg的宽算在里面，默认的图片是40，填60相当于间距是20
    self.checkId = 1
    self:setupView()
end

function RPRadioButton:setupView()
    self.bg = {}
    self.check = display.newSprite(self.checkSrc):addTo(self,1)

    for i = 1, self.num do
        self.bg[i] = display.newSprite(self.bgSrc):addTo(self)
        if self.dir == 1 then
            self.bg[i]:pos(0,self.padding*(i - 1))
        elseif self.dir == 2 then
            self.bg[i]:pos(self.padding*(i - 1),0)
        end
        wq.TouchHelper.new(self.bg[i], handler(self, self.onClick_), false, true)
    end
end

function RPRadioButton:setCheck(idx)
    self.checkId = idx
    if self.dir == 1 then
        self.check:pos(0,self.padding*(idx - 1))
    elseif self.dir == 2 then
        self.check:pos(self.padding*(idx - 1),0)
    end
    if self.callback then
        self.callback()
    end
end

function RPRadioButton:getCheck()
   return self.checkId
end

function RPRadioButton:setCallback(callback)
    self.callback = callback
end

function RPRadioButton:onClick_(target, eventName)
    if wq.TouchHelper.CLICK  == eventName then
        for i = 1, self.num do
            if i ~= self.checkId then
               if self.bg[i] == target then
                   rp.SoundManager:playSounds(rp.SoundManager.btn_click)
                   self:setCheck(i)
                   break
               end
           end
        end
    end
end

return RPRadioButton