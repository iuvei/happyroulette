local betArea = betArea or {}

--投注点对应的号码
betArea.point2Number = {
    --0-36
    {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},
    {10},{11},{12},{13},{14},{15},{16},{17},{18},{19},
    {20},{21},{22},{23},{24},{25},{26},{27},{28},{29},
    {30},{31},{32},{33},{34},{35},{36},
    --37-96
    {0,1},{0,2},{0,3},{1,4},{2,5},{3,6},{4,7},{5,8},{6,9},{7,10},
    {8,11},{9,12},{10,13},{11,14},{12,15},{13,16},{14,17},{15,18},{16,19},{17,20},
    {18,21},{19,22},{20,23},{21,24},{22,25},{23,26},{24,27},{25,28},{26,29},{27,30},
    {28,31},{29,32},{30,33},{31,34},{32,35},{33,36},{1,2},{4,5},{7,8},{10,11},
    {13,14},{16,17},{19,20},{22,23},{25,26},{28,29},{31,32},{34,35},{2,3},{5,6},
    {8,9},{11,12},{14,15},{17,18},{20,21},{23,24},{26,27},{29,30},{32,33},{35,36},
    --97-110
    {1,2,3},{4,5,6},{7,8,9},{10,11,12},{13,14,15},{16,17,18},{19,20,21},
    {22,23,24},{25,26,27},{28,29,30},{31,32,33},{34,35,36},{0,1,2},{0,2,3},
    --111-133
    {1,2,4,5},{4,5,7,8},{7,8,10,11},{10,11,13,14},{13,14,16,17},{16,17,19,20},
    {19,20,22,23},{22,23,25,26},{25,26,28,29},{28,29,31,32},{31,32,34,35},{2,3,5,6},
    {5,6,8,9},{8,9,11,12},{11,12,14,15},{14,15,17,18},{17,18,20,21},{20,21,23,24},
    {23,24,26,27},{26,27,29,30},{29,30,32,33},{32,33,35,36},{0,1,2,3},
    --134-144
    {1,2,3,4,5,6},{4,5,6,7,8,9},
    {7,8,9,10,11,12},{10,11,12,13,14,15},
    {13,14,15,16,17,18},{16,17,18,19,20,21},
    {19,20,21,22,23,24},{22,23,24,25,26,27},
    {25,26,27,28,29,30},{28,29,30,31,32,33},
    {31,32,33,34,35,36},
    --145-156
    {1,4,7,10,13,16,19,22,25,28,31,34}, --1行
    {2,5,8,11,14,17,20,23,26,29,32,35}, --2行
    {3,6,9,12,15,18,21,24,27,30,33,36}, --3行
    {1,2,3,4,5,6,7,8,9,10,11,12}, --1st12
    {13,14,15,16,17,18,19,20,21,22,23,24}, --2nd12
    {25,26,27,28,29,30,31,32,33,34,35,36}, --3rd12
    {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18}, --1to18
    {19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36}, --19to36
    {2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36}, --EVEN 偶数
    {1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35}, --ODD 奇数
    {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36}, --红色
    {2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35}, --黑色
}

--投注点对应的号码包含的高亮区域
betArea.point2HightLight = {
    --1-37
    {0},{1},{2},{3},{4},{5},{6},{7},{8},{9},
    {10},{11},{12},{13},{14},{15},{16},{17},{18},{19},
    {20},{21},{22},{23},{24},{25},{26},{27},{28},{29},
    {30},{31},{32},{33},{34},{35},{36},
    --38-97
    {0,1},{0,2},{0,3},{1,4},{2,5},{3,6},{4,7},{5,8},{6,9},{7,10},
    {8,11},{9,12},{10,13},{11,14},{12,15},{13,16},{14,17},{15,18},{16,19},{17,20},
    {18,21},{19,22},{20,23},{21,24},{22,25},{23,26},{24,27},{25,28},{26,29},{27,30},
    {28,31},{29,32},{30,33},{31,34},{32,35},{33,36},{1,2},{4,5},{7,8},{10,11},
    {13,14},{16,17},{19,20},{22,23},{25,26},{28,29},{31,32},{34,35},{2,3},{5,6},
    {8,9},{11,12},{14,15},{17,18},{20,21},{23,24},{26,27},{29,30},{32,33},{35,36},
    --98-111
    {1,2,3},{4,5,6},{7,8,9},{10,11,12},{13,14,15},{16,17,18},{19,20,21},
    {22,23,24},{25,26,27},{28,29,30},{31,32,33},{34,35,36},{0,1,2},{0,2,3},
    --112-134
    {1,2,4,5},{4,5,7,8},{7,8,10,11},{10,11,13,14},{13,14,16,17},{16,17,19,20},
    {19,20,22,23},{22,23,25,26},{25,26,28,29},{28,29,31,32},{31,32,34,35},{2,3,5,6},
    {5,6,8,9},{8,9,11,12},{11,12,14,15},{14,15,17,18},{17,18,20,21},{20,21,23,24},
    {23,24,26,27},{26,27,29,30},{29,30,32,33},{32,33,35,36},{0,1,2,3},
    --135-145
    {1,2,3,4,5,6},{4,5,6,7,8,9},
    {7,8,9,10,11,12},{10,11,12,13,14,15},
    {13,14,15,16,17,18},{16,17,18,19,20,21},
    {19,20,21,22,23,24},{22,23,24,25,26,27},
    {25,26,27,28,29,30},{28,29,30,31,32,33},
    {31,32,33,34,35,36},
    --146-157
    {1,4,7,10,13,16,19,22,25,28,31,34,37}, --1行
    {2,5,8,11,14,17,20,23,26,29,32,35,38}, --2行
    {3,6,9,12,15,18,21,24,27,30,33,36,39}, --3行
    {1,2,3,4,5,6,7,8,9,10,11,12,40}, --1st12
    {13,14,15,16,17,18,19,20,21,22,23,24,41}, --2nd12
    {25,26,27,28,29,30,31,32,33,34,35,36,42}, --3rd12
    {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,43}, --1to18
    {19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,44}, --19to36
    {2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,45}, --EVEN 偶数
    {1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,46}, --ODD 奇数
    {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36,47}, --红色
    {2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35,48}, --黑色
}

--投注点坐标
betArea.touchPos = {
    cc.p(5,191),
    cc.p(88,191),
    cc.p(88,259),
    cc.p(88,327),
    cc.p(156,191),
    cc.p(156,259),
    cc.p(156,327),
    cc.p(224,191),
    cc.p(224,259),
    cc.p(224,327),
    cc.p(292,191),
    cc.p(292,259),
    cc.p(292,327),
    cc.p(360,191),
    cc.p(360,259),
    cc.p(360,327),
    cc.p(428,191),
    cc.p(428,259),
    cc.p(428,327),
    cc.p(496,191),
    cc.p(496,259),
    cc.p(496,327),
    cc.p(564,191),
    cc.p(564,259),
    cc.p(564,327),
    cc.p(632,191),
    cc.p(632,259),
    cc.p(632,327),
    cc.p(700,191),
    cc.p(700,259),
    cc.p(700,327),
    cc.p(768,191),
    cc.p(768,259),
    cc.p(768,327),
    cc.p(836,191),
    cc.p(836,259),
    cc.p(836,327),
    cc.p(54,191),
    cc.p(54,259),
    cc.p(54,327),
    cc.p(122,191),
    cc.p(122,259),
    cc.p(122,327),
    cc.p(190,191),
    cc.p(190,259),
    cc.p(190,327),
    cc.p(258,191),
    cc.p(258,259),
    cc.p(258,327),
    cc.p(326,191),
    cc.p(326,259),
    cc.p(326,327),
    cc.p(394,191),
    cc.p(394,259),
    cc.p(394,327),
    cc.p(462,191),
    cc.p(462,259),
    cc.p(462,327),
    cc.p(530,191),
    cc.p(530,259),
    cc.p(530,327),
    cc.p(598,191),
    cc.p(598,259),
    cc.p(598,327),
    cc.p(666,191),
    cc.p(666,259),
    cc.p(666,327),
    cc.p(734,191),
    cc.p(734,259),
    cc.p(734,327),
    cc.p(802,191),
    cc.p(802,259),
    cc.p(802,327),
    cc.p(88,225),
    cc.p(156,225),
    cc.p(224,225),
    cc.p(292,225),
    cc.p(360,225),
    cc.p(428,225),
    cc.p(496,225),
    cc.p(564,225),
    cc.p(632,225),
    cc.p(700,225),
    cc.p(768,225),
    cc.p(836,225),
    cc.p(88,293),
    cc.p(156,293),
    cc.p(224,293),
    cc.p(292,293),
    cc.p(360,293),
    cc.p(428,293),
    cc.p(496,293),
    cc.p(564,293),
    cc.p(632,293),
    cc.p(700,293),
    cc.p(768,293),
    cc.p(836,293),
    cc.p(88,157),
    cc.p(156,157),
    cc.p(224,157),
    cc.p(292,157),
    cc.p(360,157),
    cc.p(428,157),
    cc.p(496,157),
    cc.p(564,157),
    cc.p(632,157),
    cc.p(700,157),
    cc.p(768,157),
    cc.p(836,157),
    cc.p(54,225),
    cc.p(54,293),
    cc.p(122,225),
    cc.p(190,225),
    cc.p(258,225),
    cc.p(326,225),
    cc.p(394,225),
    cc.p(462,225),
    cc.p(530,225),
    cc.p(598,225),
    cc.p(666,225),
    cc.p(734,225),
    cc.p(802,225),
    cc.p(122,293),
    cc.p(190,293),
    cc.p(258,293),
    cc.p(326,293),
    cc.p(394,293),
    cc.p(462,293),
    cc.p(530,293),
    cc.p(598,293),
    cc.p(666,293),
    cc.p(734,293),
    cc.p(802,293),
    cc.p(54,157),
    cc.p(122,157),
    cc.p(190,157),
    cc.p(258,157),
    cc.p(326,157),
    cc.p(394,157),
    cc.p(462,157),
    cc.p(530,157),
    cc.p(598,157),
    cc.p(666,157),
    cc.p(734,157),
    cc.p(802,157),
    cc.p(890,174),
    cc.p(890,242),
    cc.p(890,310),
    cc.p(71,98),
    cc.p(345,98),
    cc.p(618,98),
    cc.p(71,3),
    cc.p(755,3),
    cc.p(208,3),
    cc.p(618,3),
    cc.p(344,3),
    cc.p(481,3),
}

--投注点坐标
betArea.highLightPos = {
    cc.p(35,276),
    cc.p(104,208),
    cc.p(104,276),
    cc.p(104,344),
    cc.p(172,208),
    cc.p(172,276),
    cc.p(172,344),
    cc.p(240,208),
    cc.p(240,276),
    cc.p(240,344),
    cc.p(308,208),
    cc.p(308,276),
    cc.p(308,344),
    cc.p(376,208),
    cc.p(376,276),
    cc.p(376,344),
    cc.p(444,208),
    cc.p(444,276),
    cc.p(444,344),
    cc.p(512,208),
    cc.p(512,276),
    cc.p(512,344),
    cc.p(580,208),
    cc.p(580,276),
    cc.p(580,344),
    cc.p(649,208),
    cc.p(649,276),
    cc.p(649,344),
    cc.p(717,208),
    cc.p(717,276),
    cc.p(717,344),
    cc.p(785,208),
    cc.p(785,276),
    cc.p(785,344),
    cc.p(853,208),
    cc.p(853,276),
    cc.p(853,344),
    cc.p(923,208),
    cc.p(923,276),
    cc.p(923,344),
    cc.p(206,135),
    cc.p(479,135),
    cc.p(752,135),

    cc.p(138,49),
    cc.p(821,49),
    cc.p(275,49),
    cc.p(684,49),
    cc.p(411,49),
    cc.p(547,49),
}

return betArea