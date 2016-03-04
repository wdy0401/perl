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
my $length_limit=1000;

GetOptions(
	"sym=s" 	=>	\$sym,
	"date=s" 	=>	\$date,
	
	"length_limit=s" =>	\$length_limit,
); 
WDATE->new();
my $nextday=&findnexttradingday($date);
&finish_today();
&prepare_nextday();
sub finish_today()
{
}
sub prepare_nextday()
{
	&gen_nextday_file();
}

sub gen_nextday_file()
{
	my @files=("c:/report/$date/cta1/pre_$sym.txt", "c:/report/$date/cta1/$sym.txt");
	my @message=();
	for my $file(@files)
	{
		open(IN,$file) or (print STDERR "Cannot open file $file\n" and next);
		while(<IN>)
		{
			push @message,$_;
		}
		close IN;
	}
	my $outfile="c:/report/$nextday/cta1/pre_$sym.txt";
	mkpath "c:/report/$nextday/cta1"unless -d "c:/report/$nextday/cta1";
	open(OUT,"> $outfile") or die "Cannot open file $outfile\n";
	my $begpos=@message>$length_limit?@message-$length_limit:0;
	for my $ct($begpos..(@message-1))
	{
		print OUT $message[$ct];
	}
	close OUT;
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

5	合并symbol文件  设置好T+1日		pre_$sym.txt
6	给出T日应有持仓数据 					cta1.position
