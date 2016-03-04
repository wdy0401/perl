#!/usr/bin/perl -w 

#perl cta1.pl -date 20151030 -tick_type tr_tick -ctr cf1601 -logfile c:/report/20151030/cta1/cf.txt -tickfile ./split_tick/20151030/cf1601.csv
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
my $tick_type="2015_tick";#tr_tick
my $today_begin=0;
my $bar_minute=15;
my $lon_daily=0;
my $is_tail=0;
GetOptions(
	"date=s"	  		=>	\$date,
	"ctr=s" 			=>	\$ctr,
	"logfile=s" 		=>	\$logfile,
	"tickfile=s" 		=>	\$tickfile,
	"lon_daily=s" 	=> 	\$lon_daily,
	"tick_type=s" 	=>	\$tick_type,
	"bar_minute=s"=>	\$bar_minute,
); 

my %bar;
my %dkxb;
my %lonb;
my %bar_exist;
my $barcount=0;#第一个bar的最开始不打印
my $last_check_time=0;#15：00这个bar数据14：45 所以没有15：00开始的bar
my ($sym)=($ctr=~/^(\D+)/);
&init();
&load_cta1();
&run();

sub init()
{
	$SIG{'INT'}='on_close';
	$|=1;
	# 这三个都不解决taskkill的问题 taskkill时并不出发on_close
	# $SIG{'STOP'}='on_close';
	# $SIG{'KILL'}='on_close';
	# $SIG{'QUIT'}='on_close';
	$logfile//=strftime("c:/report/$date/cta1/${sym}_%Y%m%d_%H_%M_%S",localtime()).".txt";
	mkpath "c:/report/$date/cta1" unless -d "c:/report/$date/cta1";
	open(OUT_LOG,">$logfile")or die "Cannot open prelog file $logfile\n";
}

sub load_cta1(@)
{
	my $file="c:/report/$date/cta1/pre_$sym.txt";
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
	$tickfile//="E:/receiver/20151228.txt";
	open(IN,$tickfile) or die "Cannot open tick file $tickfile\n";

	my $lastoi=undef;
	my $lastap=0;
	my $lastv=0;
	my $lastto=0;
	while(<IN>)
	{	
		#对于不同版本的数据来源 采取不同的解析办法  #1为截至10150121最前的数据版本
		#1 my($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$avp,$turnover,$volume,$oi,$o,$h,$l,$hlimit,$llimit,$presp,$precp,$preoi)=(split/,/);
		my($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$h,$l,$oi,$v);
		if($tick_type eq "2015_tick")
		{
			($d,$t,$lt,$ctr,$bp,$ap,$bv,$av,$lp,$h,$l,$oi)=(split/,/);
			next unless /^201/;
			next unless &match_ctr($ctr);
			next unless &match_time($t,$lt);
		
		}
		elsif($tick_type eq "tr_tick")
		{
			($d,$t,undef,undef,undef,$lp,undef,undef,$v,$oi)=(split/,/);
			$lt=undef;
			next unless &match_time($t,$lt);
		}
		if(&new_bar($t,$lt))
		{
			&check_pos();
			&print_log();
			$barcount++;
			$lastoi=undef;
		}
		$bar{$barcount}{'t'}//=$t;
		$last_check_time=$t;
		
		$bar{$barcount}{'o'}//=$lp;
		$bar{$barcount}{'h'}//=$lp;$bar{$barcount}{'h'}=$lp>$bar{$barcount}{'h'}?$lp:$bar{$barcount}{'h'};
		$bar{$barcount}{'l'}//=$lp;$bar{$barcount}{'l'}=$lp<$bar{$barcount}{'l'}?$lp:$bar{$barcount}{'l'};
		$bar{$barcount}{'c'}=$lp;
		
		$lastoi//=$oi;
		if($tick_type eq "2015_tick")
		{
			$bar{$barcount}{'v'}//=undef;		
		}
		elsif($tick_type eq "tr_tick")
		{
			$bar{$barcount}{'v'}//=0;
			$bar{$barcount}{'v'}+=$v;
		}
	}
	close IN;
	&on_tail();
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
      #考虑夜盘
			return 1;
		}
	}	
}
sub new_bar(@)
{
	my($t,$lt)=@_;
	
	my $ret=0;
	my ($h,$m,$s)=(split":",$t);
	my $summin=0;
	$summin=($h-9)*60+$m if($sym ne "IF" and $sym ne "IH" and $sym ne "IC" and $sym ne "TF" and $sym ne "T");
	$summin=($h-9)*60+$m-30 unless ($sym ne "IF" and $sym ne "IH" and $sym ne "IC" and $sym ne "TF" and $sym ne "T");
	my $count=$bar_minute*int($summin/$bar_minute);
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
	
	return $ret && morning_break($h,$m);
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
	if(! $lon_daily)
	{
		my $lc=$bar{$barcount-1}{'c'};
		my $vid;
		if(			
				(
					abs($bar{$barcount-1}{'h'}	+	$bar{$barcount-2}{'h'})
				+	abs($bar{$barcount-1}{'h'}	-	$bar{$barcount-2}{'h'})
				-	abs($bar{$barcount-1}{'l'}		+	$bar{$barcount-2}{'l'})
				+	abs($bar{$barcount-1}{'l'}		-	$bar{$barcount-2}{'l'})
				)==0
			)
			{
				$vid=0;
			}
			else
			{
				$vid=($bar{$barcount-1}{'v'}+$bar{$barcount-2}{'v'})/
				(
					(
						abs($bar{$barcount-1}{'h'}	+	$bar{$barcount-2}{'h'})
					+	abs($bar{$barcount-1}{'h'}	-	$bar{$barcount-2}{'h'})
					-	abs($bar{$barcount-1}{'l'}		+	$bar{$barcount-2}{'l'})
					+	abs($bar{$barcount-1}{'l'}		-	$bar{$barcount-2}{'l'})
					)
				*50
				);
			}
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
	else
	{
		if($is_tail)
		{
		}
		else
		{
		}
	}
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
	if($today_begin==0)
	{
		$today_begin=1;
		return;
	}
	
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
	
	print OUT_LOG "$date:$t,$o,$h,$l,$c,$i,$v,$lon,$dkx,$lc,$vid,$rc,$long,$diff,$dea,$a,$dkx_b,$dkx_d,$nowdkx\n";
}
sub on_close()
{
	&check_pos();
	&print_log();
	close OUT_LOG;
	die "ctrl + c reveived\n";
}
sub on_tail()
{
	if(&need_fix_tail())
	{
		&check_pos();
		&print_log();
	}
	if($lon_daily)
	{
		$is_tail=1;
		&check_pos();
		&print_log();
	}
	close OUT_LOG;
}
sub need_fix_tail()
{
	my $last_k=$last_check_time;
	my($h,$m)=($last_k=~/^(\d+):(\d+)/);	
	if
	(		
			$sym eq 'IF'
		||	$sym eq 'IH'
		||	$sym eq 'IC'
	)
	{
		return 0 if $h>=15;
	}
	elsif
	(		
			$sym eq 'TF'
		||	$sym eq 'T'
	)
	{
		return 0 if (($h==15 and $m>=15) or $h>15)
	}
	else
	{
    #相当于不考虑最后的时间段
    return 1;
		#return 0 if $h>=15;
	}
	return 1;
}
sub morning_break(@)
{	
	#除了中金所  都有节间休息
	my($h,$m)=@_;
	if
	(		
			$sym eq 'IF'
		||	$sym eq 'IH'
		||	$sym eq 'IC'
		||	$sym eq 'TF'
		||	$sym eq 'T'
	)
	{
		return 1;
	}
	else
	{
		if($h==10 and ($m>=15 && $m<30))
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
}
__DATA__
20160304 
对于lon线使用日线数据 
问题在于在此系统内无法以日为单位读取数据
	当日数据可以解决
	t-1日数据已然无法得到其 o h l
	t-2日数据 完全不可得到
		pre里有相应数据 可以得到
对于lon数据的使用  可以通过在当日的每一次调用均使用前次数据来实现
对于lon数据的生成  在on_tail生成  并加入到print中