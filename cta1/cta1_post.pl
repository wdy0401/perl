#!/usr/bin/perl -w 

#输出设定仓位与设定时间，最后设定的排在最前 用开始的button就行  上面显示每个合约的目标仓位 双击之后变蓝 双击前是绿色 更新之后重新变为绿色
#仅处理一个ctr
use FindBin qw($Bin);
use Getopt::Long;
use File::Path;
use POSIX;
use 5.22.0;

use lib "c:/code";
use WMATH;

my $ctr="cu1601";
my $date=20151228;
my $logfile;
my $tickfile;
GetOptions(
	"ctr=s" 	=>	\$ctr,
	"logfile=s" =>	\$logfile,
	"tickfile=s" =>	\$tickfile,
); 

__DATA__
1	找到最近的相关symbol的文件
2	复制此文件 

3	利用记录的tick重新跑一边T日数据
4	重跑的数据与实时数据对比

5	合并symbol文件  设置好T+1日
6	给出T日应有持仓数据