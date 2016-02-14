#!/usr/bin/perl -w 
use 5.22.0;
use FileHandle;

my %ch;#ch 20151111 a a1405 0 123
my %mctr; #mctr a 20151111 first a1411 

my %re;
my $count=1;
open(IN,"c:/code/bizd.txt");
while(<IN>)
{
	s/\s+//;
	$re{$_}=$count;
	$count++;
}
close IN;

system("mkdir data") unless -d "./data";
chdir "./tick";

&drive_dir();
&get_main();

sub get_main()
{
	for my $dt(sort keys %ch)
	{
		for my $sym(sort keys %{$ch{$dt}})
		{
			for my $ctr(sort keys %{$ch{$dt}{$sym}})
			{			
				$mctr{$sym}{$dt}{'first'}//=$ctr;
				$mctr{$sym}{$dt}{'first_oi'}//=$ch{$dt}{$sym}{$ctr}{'oi'};
								
				if($mctr{$sym}{$dt}{'first_oi'}<$ch{$dt}{$sym}{$ctr}{'oi'})
				{
					$mctr{$sym}{$dt}{'first'}=$ctr;
					$mctr{$sym}{$dt}{'first_oi'}=$ch{$dt}{$sym}{$ctr}{'oi'};
				}				
			}
		}
	}
	
	my %sh;
	for my $sym(sort keys %mctr)
	{
		my $lastctr;
		for my $dt(sort keys %{$mctr{$sym}})
		{
			if(defined $lastctr and $lastctr gt $mctr{$sym}{$dt}{'first'})
			{
#				print "$sym\t$dt\t$lastctr\n";
				$sh{$sym}{$dt}=$lastctr;
			}
			else
			{
#				print "$sym\t$dt\t$mctr{$sym}{$dt}{'first'}\n";
				$lastctr=$mctr{$sym}{$dt}{'first'};
				$sh{$sym}{$dt}=$lastctr;
			}
		}
	}
	for my $sym(sort keys %sh)
	{
		my $lastctr;
		for my $dt(sort keys %{$sh{$sym}})
		{
			if(!defined $lastctr)
			{
				print "$sym\t$dt\t$sh{$sym}{$dt}\n";
			}
			else
			{
				print"$sym\t$dt\t$lastctr\n"
			}
			$lastctr=$sh{$sym}{$dt};
		}
	}
}
sub readfile(@)
{
	my $file=shift @_;
	print STDERR "File $file\n";
	my($ctr)=($file=~/(\S+)\./);
	my($sym)=($ctr=~/(\D+)/);
	open(IN,$file) or die "Cannot open file $file\n";
	while(<IN>)
	{
		next if /date/;
		s/\s+$//;
		s/(\/\d+),/$1 0:00,/ unless /:/;
		my ($dt,$t,$o,$h,$l,$c,$js1,$js2,$vol,$oi)=(split/,/);
		#my ($y,$m,$d)=($t=~/^(\d+)\/(\d+)\/(\d+)/);
		#my $dt=$y*10000+$m*100+$d;
		#$dt=$y*100+$m+$d*10000 if $d>1000;
		next unless defined $re{$dt};
		my ($minute)=($t=~/^(\d+)/);next unless $minute>8 and $minute<16;
		$ch{$dt}{$sym}{$ctr}{'vol'}//=0;
		$ch{$dt}{$sym}{$ctr}{'vol'}+=$vol;
		$ch{$dt}{$sym}{$ctr}{'oi'}=$oi;
	}
	close IN;
}
sub drive_dir()
{
	opendir DH,"./";
	for(readdir DH)
	{
		next unless /csv$/;
#		next unless /^a\d/;
		s/\s+$//;
		&readfile($_);
	}
}


__DATA__
1.生成表 日期 品种 合约 成交量 持仓量 

2.通过表得到每日的主力合约
	主力合约为前日持仓量最大的合约
	合约上市日以当日持仓量最大合约为主力合约
	持仓量相同的以交割日在后的合约为主力合约
	主力合约仅向后调整，不向前调整

3.生成主力合约分钟bar数据