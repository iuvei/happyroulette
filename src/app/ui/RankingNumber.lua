local RankingNumber = class("RankingNumber", function()
    return display.newNode()
end)

RankingNumber.res1 = {
    "#0.png",
    "#1.png",
    "#2.png",
    "#3.png",
    "#4.png",
    "#5.png",
    "#6.png",
    "#7.png",
    "#8.png",
    "#9.png",}

RankingNumber.res2 = {
    "#result_num0.png",
    "#result_num1.png",
    "#result_num2.png",
    "#result_num3.png",
    "#result_num4.png",
    "#result_num5.png",
    "#result_num6.png",
    "#result_num7.png",
    "#result_num8.png",
    "#result_num9.png",
    "#result_numdot.png"}

RankingNumber.res3 = {
   "#red_0.png",
   "#red_1.png",
   "#red_2.png",
   "#red_3.png",}

function RankingNumber:ctor(args)
    if args then
        self.args_ = args
        self.number_ = args.number
        self.res_ = args.res
        self.hasDot_ = args.hasDot--千分号
        self.color_ = args.color
        self.hasWarn_ = args.hasWarn--倒计时0,1,2,3警告
        self.hasAnim_ = args.hasAnim--跳动动画
        self.sign = args.sign or 0 --1正号  -1 负号  0 没有
        self.hasK = args.hasK --是否用K缩写
    end

    if self.res_ == 2 then
        self.tmpRes_ = RankingNumber.res2
--    elseif self.res_ == 3 then
--        self.res_ = RankingNumber.res3
--        self.hasDot_ = false
    else
        self.tmpRes_ = RankingNumber.res1
        self.hasDot_ = false
    end

    if self.hasK then
        self.number_ = math.floor(self.number_/1000)
    end

    self.offsetX = 0

    self:setupView(self.number_)
end


function RankingNumber:setupView(number)
    if self.hasWarn_ then
        if (number >= 0 and number <=3) then
            self.res_ = RankingNumber.res3
        else
            self.res_ = self.tmpRes_
        end
    else
        self.res_ = self.tmpRes_
    end

    if number <= 0 then
        local sp =  display.newSprite(self.res_[1]):addTo(self)
        if self.color_ then
            sp:setColor(self.color_)
        end   
        sp:pos(sp:getContentSize().width/2,0)
        self.width_ = sp:getContentSize().width
    else
        local nums = {}

        local a = 0
        local b = 0
        repeat
            a = a+1
            nums[a] = number%10
            number = math.floor(number/10)

            if self.hasDot_ then
                b = b + 1
                if b % 3 == 0 and number ~= 0 then
                    a = a + 1
                    nums[a] = 10--千分号  7,210 a1 = 0 a2 = 1 a3 = 2 a4 = , a5 = 7
                end
            end
        until number == 0

        self.width_ = 0
        --正负号
        if self.sign == 1 then
            self:addSp("#result_num_plus.png")
        elseif self.sign == -1 then
            self:addSp("#result_num_minus.png")
        end
        for i = a, 1,-1 do
            self:addSp(self.res_[nums[i]+1])
        end
        if self.hasK then
            self:addSp("#result_num_k.png")
        end
    end

    if self.hasAnim_ then
        self:enLargeAnimation()
    end
end

function RankingNumber:addSp(src)
    local sp = display.newSprite(src):addTo(self)
    if self.color_ then
        sp:setColor(self.color_)
    end
    sp:pos(self.width_ + sp:getContentSize().width/2,0)
    self.width_ = self.width_ + sp:getContentSize().width
end

function RankingNumber:getWidth()
    return self.width_
end

function RankingNumber:setNumber(number)
    self:removeAllChildren()
    self:setupView(number)
    if self.offsetX ~= 0 then
        self:setPositionX(self.offsetX - self.width_/2)
    end
end

function RankingNumber:jumpToNum(fromNum,toNum,duration,offsetX)
    self.fromNum = fromNum
    self.toNum = toNum
    self.jumpNum = (fromNum - toNum)/(duration/0.05)
    self.offsetX = offsetX or 0
    self.countSchedulerId_ = rp.schedulerFactory:scheduleGlobal(handler(self, self.jump),0.05)
    rp.schedulerFactory:delayGlobal(handler(self,self.stopJump), duration)
end

function RankingNumber:stopJump()
    self:setNumber(self.toNum)
    rp.schedulerFactory:unscheduleGlobal(self.countSchedulerId_)
end
function RankingNumber:jump()
    self.fromNum = self.fromNum - self.jumpNum
    self:setNumber(self.fromNum)
end

function RankingNumber:enLargeAnimation()
    transition.execute(self,cc.ScaleTo:create(0.1,1.2),{onComplete = function()
        transition.execute(self,cc.ScaleTo:create(0.2,1))
    end})
end

return RankingNumber