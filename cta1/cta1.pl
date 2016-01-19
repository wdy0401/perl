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
GetOptions(
	"ctr=s" =>\$ctr,
); 

my %bar;
my %dkxb;
my %lonb;
my $barcount=0;
my ($sym)=($ctr=~/^(\D+)/);
&init();
&load_cta1();
&run();

sub init()
{
	$SIG{'INT'}='on_close';
	my $logfile=strftime("c:/report/$date/cta1/${ctr}_%Y%m%d_%H_%M_%S",localtime()).".txt";
	open(OUT_LOG,">$logfile")or die "Cannot open prelog file $logfile\n";
}

sub load_cta1(@)
{
	my $file="c:/report/$date/cta1/$sym.txt";
	unless (open(IN,"$file"))
	{
		print STDERR "Cannot open CTA1 file $file\n";
		return;
	}
	while(<IN>)
	{
		s/\s+$//;
		next unless $_;	
		my($t,$o,$h,$l,$c,$v,$i,$lon,$dkx,$lc,$vid,$rc,$long,$diff,$dea,$a,$dkx_b,$dkx_d,$nowdkx)=(split/,/);
		$barcount++;
		$bar{$barcount}{'t'}=$t;
		$bar{$barcount}{'o'}=$o;
		$bar{$barcount}{'h'}=$h;
		$bar{$barcount}{'l'}=$l;
		$bar{$barcount}{'c'}=$c;
		$bar{$barcount}{'i'}=$i;
		$bar{$barcount}{'v'}=$v;
		$bar{$barcount}{'lon'}=$lon;
		$bar{$barcount}{'dkx'}=$dkx;
		
		$bar{$barcount}{'lc'}=$lc;
		$bar{$barcount}{'vid'}=$vid;
		$bar{$barcount}{'rc'}=$rc;
		$bar{$barcount}{'long'}=$long;
		$bar{$barcount}{'diff'}=$diff;
		$bar{$barcount}{'dea'}=$dea;
		
		$bar{$barcount}{'a'}=$a;
		$bar{$barcount}{'dkx_b'}=$dkx_b;
		$bar{$barcount}{'dkx_d'}=$dkx_d;
		$bar{$barcount}{'nowdkx'}=$nowdkx;
	}
}
sub run()
{

	open(IN,"E:/receiver/20151228.txt") or die "Cannot open tick file\n";

	my $lastoi=undef;
	my $lastap=0;
	my $lastv=0;
	my $lastto=0;
	while(<IN>)
	{	
		# 20151223,21:30:58:0,21:30:55:379,MA605,1710,1711,476,1248,1710,1717,1705,758718996,1711,1692
		# 20151223,21:30:58:0,21:30:55:386,MA609,1729,1730,2,86,1729,1739,1727,12113608,1732,1712
		# 20151223,21:30:57:0,21:30:55:386,OI605,5656,5658,10,50,5656,5664,5652,41688144,5658,5644
		# 20151223,21:30:57:0,21:30:55:387,OI607,5548,5790,1,4,5646,0,0,0,0,5646    
		

		# os<< pDepthMarketData->TradingDay;
		# os<< "," << pDepthMarketData->UpdateTime;
		# os<< ":" << pDepthMarketData->UpdateMillisec;
		# os<<"," << dt.currentDateTime().toString("hh:mm:ss:zzz").toStdString();
		# os<< "," << pDepthMarketData->InstrumentID;
		# os<< "," << pDepthMarketData->BidPrice1;
		# os<< "," << pDepthMarketData->AskPrice1;
		# os<< "," << pDepthMarketData->BidVolume1;
		# os<< "," << pDepthMarketData->AskVolume1;
		# os<< "," << pDepthMarketData->LastPrice;
		# os<< "," << pDepthMarketData->AveragePrice;//当日均价
		# os<< "," << pDepthMarketData->Turnover;//成交金额
		# os<< "," << pDepthMarketData->Volume;//数量
		# os<< "," << pDepthMarketData->OpenInterest;//持仓量
		# os<< "," << pDepthMarketData->OpenPrice;//今开
		# os<< "," << pDepthMarketData->HighestPrice;//今高
		# os<< "," << pDepthMarketData->LowestPrice;//今低
		# os<< "," << pDepthMarketData->UpperLimitPrice;//涨停板价格
		# os<< "," << pDepthMarketData->LowerLimitPrice;//跌停板价格
		# os<< "," << pDepthMarketData->PreSettlementPrice;//昨结算
		# os<< "," << pDepthMarketData->PreClosePrice;//昨收盘
		# os<< "," << pDepthMarketData->PreOpenInterest;//昨持仓
		# os<< endl;

		#有待更新  因ctp_record更新之缘故
		#my($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$avp,$turnover,$volume,$oi,$o,$h,$l,$hlimit,$llimit,$presp,$precp,$preoi)=(split/,/);
		my($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$h,$l,$oi)=(split/,/);
		next unless /^201/;
		next unless &match_ctr($ctr);
		next unless &match_time($t,$lt);
		if(&new_bar($t,$lt))
		{
			&check_pos();
			&print_log();
			$barcount++;
			print"$t,$barcount\n";
			$lastoi=undef;
		}
		$bar{$barcount}{'t'}//=$t;
		$bar{$barcount}{'o'}//=$lp;
		$bar{$barcount}{'h'}//=$lp;$bar{$barcount}{'h'}=$lp>$bar{$barcount}{'h'}?$lp:$bar{$barcount}{'h'};
		$bar{$barcount}{'l'}//=$lp;$bar{$barcount}{'l'}=$lp<$bar{$barcount}{'l'}?$lp:$bar{$barcount}{'l'};
		$bar{$barcount}{'c'}=$lp;
		
		$lastoi//=$oi;
		$bar{$barcount}{'i'}//=0;
		$bar{$barcount}{'i'}+=$oi-$lastoi;#有待检查
		
		#$bar{$barcount}{'v'}//=$v;#有待检查
	
		
		#print "$oi\n";
		#print STDERR "$_\n";
	}
	close IN;
}
sub display(@)
{
	my($a)=@_;
}
sub match_ctr(@)
{
	my $nowctr=shift  @_;
	return 1 if uc $nowctr eq uc $ctr;
	return 0;
}
sub match_time(@)
{
	my($t,$lt)=@_;
	my ($h,$m,$s)=(split":",$t);
	if#股指期货交易时间
	(
			(uc $sym eq 'IF')
		or	(uc $sym eq 'IH')
		or	(uc $sym eq 'IC')
	)
	{
		if
		(
				($h==9 and $m>=30)
			or	($h==10)
			or	($h==11 and $m<30)
			or	($h==11 and $m==30 and $s==0)
			or	($h==13)
			or	($h==14)
			or	($h==15 and $m==0 and $s==0)
		)
		{
			return 1;
		}
		else
		{
			return 0;
		}		
	}
	elsif#国债期货交易时间
	(
			(uc $sym eq 'TF')
		or	(uc $sym eq 'T')
	)
	{
		if
		(
				($h==9 and $m>=15)
			or	($h==10)
			or	($h==11 and $m<30)
			or	($h==11 and $m==30 and $s==0)
			or	($h==13)
			or	($h==14)
			or	($h==15 and $m<15)
			or	($h==15 and $m==15 and $s==0)
		)
		{
			return 1;
		}
		else
		{
			return 0;
		}		
	}
	else
	{
		if#商品期货日盘交易时间
		(
				($h==9)
			or	($h==10)
			or	($h==11 and $m<30)
			or	($h==11 and $m==30 and $s==0)
			or	($h==13)
			or	($h==14)
			or	($h==15 and $m==0 and $s==0)
		)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}	
}
sub new_bar(@)
{
	my($t,$lt)=@_;
	state %bar_exist;
	
	my $ret=0;
	my ($h,$m,$s)=(split":",$t);
	
	my $count=15*int($m/15);
	$count="$h:$count";
	if(defined $bar_exist{$count})
	{
		$ret=0;
	}
	else
	{
		$ret=1;
	}
	$bar_exist{$count}=1;
	
	return $ret;
}
sub check_pos(@)
{
	$bar{$barcount}{'lon'}=&cal_lon();
	$bar{$barcount}{'dkx'}=&cal_dkx();

	if($barcount<40)
	{
		return 0;
	}
}
sub cal_lon()
{
	return 0 if $barcount==0;
	return 0 unless $barcount>2; #计算vid需求
	my $lc=$bar{$barcount-1}{'c'};
	my $vid=($bar{$barcount-1}{'i'}+$bar{$barcount-2}{'i'})/
		(
			(
				abs($bar{$barcount-1}{'h'}	+	$bar{$barcount-2}{'h'})
			+	abs($bar{$barcount-1}{'h'}	-	$bar{$barcount-2}{'h'})
			-	abs($bar{$barcount-1}{'l'}		+	$bar{$barcount-2}{'l'})
			+	abs($bar{$barcount-1}{'l'}		-	$bar{$barcount-2}{'l'})
			)
		*50
		);
	my $rc=($bar{$barcount}{'c'}-$lc)*$vid;
	my $long=$rc;
	
	$bar{$barcount}{'lc'}=$lc;
	$bar{$barcount}{'vid'}=$vid;
	$bar{$barcount}{'rc'}=$rc;
	$bar{$barcount}{'long'}=$long;
	
	return 0 unless $barcount>22; #计算dea需求
	my $diff=&cal_diff(10);
	my $dea=&cal_diff(20);
	my $lon=$diff-$dea;	


	$bar{$barcount}{'diff'}=$diff;
	$bar{$barcount}{'dea'}=$dea;
	$bar{$barcount}{'lon'}=$lon;
}
sub cal_diff(@)
{
	my $count=shift @_;
	my $ret=0;
	for my $n(0..$count-1)
	{
		$ret+=$bar{$barcount-$n}{'long'};
	}
	return 0 unless $count;
	return $ret/$count;
}
sub cal_dkx()
{
	# 1、当多空线上穿其均线时为买入信号；
	# 2、当多空线下穿其均线时为卖出信号。
	# a：=(3*收盘价+最低价+开盘价+最高价)/6；
	# b：(20*a+19*向前引用(a,1)+18*向前引用(a,2)+17*向前引用(a,3)+16*向前引用(a,4)+15*向前引用(a,5)+14*向前引用(a,6)
	# +13*向前引用(a,7)+12*向前引用(a,8)+11*向前引用(a,9)+10*向前引用(a,10)+9*向前引用(a,11)+8*向前引用(a,12)
	# +7*向前引用(a,13)+6*向前引用(a,14)+5*向前引用(a,15)+4*向前引用(a,16)+3*向前引用(a,17)+2*向前引用(a,18)+
	# 向前引用(a,20))/210；
	# d:简单移动平均(b,m)
	# 当B上穿D时为买入信号；
	# 当B下穿D时为卖出信号；
	return 0 if $barcount==0;
	my $a=($bar{$barcount}{'o'}+$bar{$barcount}{'h'}+$bar{$barcount}{'l'}+3*$bar{$barcount}{'c'})/6;
	$bar{$barcount}{'a'}=$a;
	
	##############################
	return 0 unless $barcount>20; #计算dkx_b需求
	my $sum=0;
	for my $n(0..19)
	{
		$sum+=(20-$n)*$bar{$barcount-$n}{'a'};
	}
	my $dkx_b=$sum/210;
	$bar{$barcount}{'dkx_b'}=$dkx_b;
	
	##############################
	return 0 unless $barcount>30; #计算dkx_d需求
	$sum=0;
	for my $n(0..9)
	{
		$sum+=$bar{$barcount-$n}{'dkx_b'};
	}
	my $dkx_d=$sum/10;
	$bar{$barcount}{'dkx_d'}=$dkx_d;
	if($dkx_d==$dkx_b)
	{
		if(defined $bar{$barcount-1}{'nowdkx'})
		{
			$bar{$barcount}{'nowdkx'}=$bar{$barcount-1}{'nowdkx'};
		}
	}
	else
	{
		$bar{$barcount}{'nowdkx'}=$dkx_b>$dkx_d? 1 : -1;
	}
	
	if(defined $bar{$barcount-1}{'nowdkx'})
	{
		if($bar{$barcount}{'nowdkx'}>$bar{$barcount-1}{'nowdkx'})
		{
			$bar{$barcount}{'dkx'}=1;
		}
		elsif($bar{$barcount}{'nowdkx'}<$bar{$barcount-1}{'nowdkx'})
		{
			$bar{$barcount}{'dkx'}=-1;
		}
		else
		{
			$bar{$barcount}{'dkx'}=0;
		}	
	}
	return $bar{$barcount}{'dkx'};
}
sub print_log()
{
	return unless defined $bar{$barcount}{'t'};
	
	my $t			=defined $bar{$barcount}{'t'}				?	 $bar{$barcount}{'t'}			:	0;
	my $o			=defined $bar{$barcount}{'o'}				?	 $bar{$barcount}{'o'}			:	0;
	my $h			=defined $bar{$barcount}{'h'}				?	 $bar{$barcount}{'h'}			:	0;
	my $l			=defined $bar{$barcount}{'l'}				?	 $bar{$barcount}{'l'}			:	0;
	my $c			=defined $bar{$barcount}{'c'}				?	 $bar{$barcount}{'c'}			:	0;
	my $i			=defined $bar{$barcount}{'i'}				?	 $bar{$barcount}{'i'}			:	0;
	my $v			=defined $bar{$barcount}{'v'}				?	 $bar{$barcount}{'v'}			:	0;
	my $lon		=defined $bar{$barcount}{'lon'}				?	 $bar{$barcount}{'lon'}		:	0;
	my $dkx		=defined $bar{$barcount}{'dkx'}			?	 $bar{$barcount}{'dkx'}		:	0;

	my $lc			=defined $bar{$barcount}{'lc'}				?	 $bar{$barcount}{'lc'}			:	0;
	my $vid		=defined $bar{$barcount}{'vid'}				?	 $bar{$barcount}{'vid'}		:	0;
	my $rc			=defined $bar{$barcount}{'rc'}				?	 $bar{$barcount}{'rc'}			:	0;
	my $long		=defined $bar{$barcount}{'long'}			?	 $bar{$barcount}{'long'}		:	0;
	my $diff		=defined $bar{$barcount}{'diff'}				?	 $bar{$barcount}{'diff'}		:	0;
	my $dea		=defined $bar{$barcount}{'dea'}			?	 $bar{$barcount}{'dea'}		:	0;

	my $a			=defined $bar{$barcount}{'a'}				?	 $bar{$barcount}{'a'}			:	0;
	my $dkx_b	=defined $bar{$barcount}{'dkx_b'}		?	 $bar{$barcount}{'dkx_b'}	:	0;
	my $dkx_d	=defined $bar{$barcount}{'dkx_d'}		?	 $bar{$barcount}{'dkx_d'}	:	0;
	my $nowdkx=defined $bar{$barcount}{'nowdkx'}		?	$bar{$barcount}{'nowdkx'}	:	0;
	
	print OUT_LOG "$t,$o,$h,$l,$c,$i,$v,$lon,$dkx,$lc,$vid,$rc,$long,$diff,$dea,$a,$dkx_b,$dkx_d,$nowdkx\n";
}
sub on_close()
{
	#已写入最后的bar
	if(1)
	{
		&check_pos();
		&print_log();
		close OUT_LOG;
	}
	#写入最后的bar
	else
	{}
	die "ctrl + c reveived\n";
	#关闭输出文件
}
__DATA__
流程  

1	读取历史信息
		1.1	历史信息文件
		1.2	历史信息数据格式
2	接收来自stdin的数据
		2.1	判断时间是否在交易时间
		2.2	判断是否为关注合约（此项可以设计为 每个合约有个一个perl进程，这样可以避免多个合约争夺stdin发生，在子perl进程中，是否判断合约也就不重要了,盖因在主进程中已经判断过了）
		2.3	判断是否为新的bar
		2.4	判断是否需要更新position
		2.5	给出展示信息
		2.6	将信息写入外部文件 信息即为 1.2中所提到的历史信息数据格式 此处每个子perl进程均需open一个文件

1.2
	date barseq begtime endtime o h l c etc

2.4
	2.4.1	计算 lon
	2.4.2	计算 dkx
		2.4.2.1	计算dkx_b
		2.4.2.2	计算dkx_d
		
	


	






