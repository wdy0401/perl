#!/usr/bin/perl -w 

#输出设定仓位与设定时间，最后设定的排在最前 用开始的button就行  上面显示每个合约的目标仓位 双击之后变蓝 双击前是绿色 更新之后重新变为绿色

use FindBin qw($Bin);
use Getopt::Long;
use File::Path;
use 5.010;

use lib "c:/code";
use WMATH;

my $ctr="cu1601";
my $date=20151223;
GetOptions(
	"ctr=s" =>\$ctr,
); 

my %bar;
my %dkxb;
my %lonb;
my $barcount=1;
&load_cta1();
&run();

sub load_cta1(@)
{
	my $file="c:/report/$date/cta1.txt";
	open(IN,"$file") or die "Cannot open CTA1 file $file\n";
	while(<IN>)
	{
		s/\s+$//;
		next unless $_;
		my($t,$o,$h,$l,$c,$v,$i,$lon,$dkx)=(split/,/);
		$bar{$barcount}{'t'}=$t;
		$bar{$barcount}{'o'}=$o;
		$bar{$barcount}{'h'}=$h;
		$bar{$barcount}{'l'}=$l;
		$bar{$barcount}{'c'}=$c;
		$bar{$barcount}{'i'}=$i;
		$bar{$barcount}{'v'}=$v;
		$bar{$barcount}{'lon'}=$lon;
		$bar{$barcount}{'dkx'}=$dkx;
		$barcount++;
	}
}
sub run()
{
#	open(IN,"./receiver/test_receiver.exe |");
	open(IN,"E:/receiver/20151223.txt");
	while(<IN>)
	{	
		# 20151223,21:30:58:0,21:30:55:379,MA605,1710,1711,476,1248,1710,1717,1705,758718996,1711,1692
		# 20151223,21:30:58:0,21:30:55:386,MA609,1729,1730,2,86,1729,1739,1727,12113608,1732,1712
		# 20151223,21:30:57:0,21:30:55:386,OI605,5656,5658,10,50,5656,5664,5652,41688144,5658,5644
		# 20151223,21:30:57:0,21:30:55:387,OI607,5548,5790,1,4,5646,0,0,0,0,5646    os<< pDepthMarketData->TradingDay;
		
		# os<< "," << pDepthMarketData->UpdateTime;
		# os<< ":" << pDepthMarketData->UpdateMillisec;
		# os<<"," << dt.currentDateTime().toString("hh:mm:ss:zzz").toStdString();
		# os<< "," << pDepthMarketData->InstrumentID;
		# os<< "," << pDepthMarketData->BidPrice1;
		# os<< "," << pDepthMarketData->AskPrice1;
		# os<< "," << pDepthMarketData->BidVolume1;
		# os<< "," << pDepthMarketData->AskVolume1;
		# os<< "," << pDepthMarketData->LastPrice;
		# os<< "," << pDepthMarketData->HighestPrice;
		# os<< "," << pDepthMarketData->LowestPrice;
		# os<< "," << pDepthMarketData->Turnover;
		# os<< "," << pDepthMarketData->AveragePrice;
		# os<< "," << pDepthMarketData->PreSettlementPrice;
		next unless /^201/;
		#有待更新  因ctp_record更新之缘故
		my($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$h,$l,$interest)=(split/,/);
		next unless &match_ctr($ctr);
		next unless &match_time($t,$lt);
		if(&new_bar($t,$lt))
		{
			&check_pos();
			$barcount++;
		}
		$bar{$barcount}{'t'}//=$t;
		$bar{$barcount}{'o'}//=$lp;
		$bar{$barcount}{'h'}//=$lp;$bar{$barcount}{'h'}=$lp>$bar{$barcount}{'h'}?$lp:$bar{$barcount}{'h'};
		$bar{$barcount}{'l'}//=$lp;$bar{$barcount}{'l'}=$lp<$bar{$barcount}{'l'}?$lp:$bar{$barcount}{'l'};
		$bar{$barcount}{'c'}=$lp;
		$bar{$barcount}{'i'}//=$interest;#有待检查
		#$bar{$barcount}{'v'}//=$v;#有待检查
	
		
		print "$interest\n";
		#print STDERR "$_\n";
	}
}
sub display(@)
{
	my($a)=@_;
}
sub match_ctr(@)
{
	my $ctr=shift  @_;
	return 0 unless $ctr=~/if1601/i;
	return 1;
}
sub match_time(@)
{
	return 1;
}
sub new_bar(@)
{
	return 1;
}
sub check_pos(@)
{
	return 1;
}






