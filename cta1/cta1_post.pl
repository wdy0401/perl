#!/usr/bin/perl -w 


use FindBin qw($Bin);
use Getopt::Long;
use File::Path;
use POSIX;
use 5.22.0;

use lib "c:/code";
use WMATH;
use WDATE;
my $sym="cu";
my $date=20151228;
my $logfile;
my $tickfile;

GetOptions(
	"sym=s" 	=>	\$sym,
	"logfile=s" =>	\$logfile,
	"tickfile=s" =>	\$tickfile,
); 
WDATE->new();
my $nextday=&findnexttradingday($date);
print"$nextday\n";
sub gen_nextday_file(@)
{
	my @files=find_record_file();
	my @message=();
	for my $file(@files)
	{
		open(IN,$file) or die "Cannot open file $file\n";
		while(<IN>)
		{
			push @message,$_;
		}
		close IN;
	}
	my $outfile="c:/report/$nextday/cta1/$sym.txt";
	open(OUT,"> $outfile") or die "Cannot open file $outfile\n";
	print OUT @message;
	close OUT;
}
sub find_next_day()
{
}
sub find_record_file()
{
}
sub recal_record()
{
#just cmd with tickfile para
}
sub set_position_real()
{
}
sub set_position_simu()
{
}
__DATA__
1	找到最近的相关symbol的文件
2	复制此文件 

3	利用记录的tick重新跑一边T日数据
4	重跑的数据与实时数据对比

5	合并symbol文件  设置好T+1日		$sym.txt
6	给出T日应有持仓数据 					cta1.position
