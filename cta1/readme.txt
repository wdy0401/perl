#合并tick文件

#完成volume的辨别 倒数第二个

#完成tick文件的分割

#完成post

#完成pre

cta1 可跑
cta1_post可用
mainctr 生成 基于hbtick


merge
yearmonthday
split_tick
gen_mainctr
daily_driver.pl

主力合约生成方式仍旧基于老式tick文件 尚未基于每日接收的tick文件