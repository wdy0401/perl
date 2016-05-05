#!/usr/bin/perl -w
use strict;

my @files=&getfile();
my %sh;
for my $file(@files)
{
	&readfile($file);
}
&print_symbol();

sub readfile(@)
{
	my $file=shift @_;
	open (IN,$file) or die "Cannot open file $file\n";
	while(<IN>)
	{
	#日期 品种 合约 开 高 低 收 结算 成交 持仓 今收-昨结 今结-昨结
		my ($dt,$sym,$ctr,$o,$h,$l,$c,$js,$v,$pos,$dif1,$dif2)=(split/,/);
		$sh{$sym}{$dt}{$ctr}{'p'}=$js;
		$sh{$sym}{$dt}{$ctr}{'v'}=$v;
		$sh{$sym}{$dt}{'main'}{'v'}//=0;
		$sh{$sym}{$dt}{'main'}{'p'}//=0;
		$sh{$sym}{$dt}{'main'}{'v'}+=$v;
		$sh{$sym}{$dt}{'main'}{'p'}=($sh{$sym}{$dt}{$ctr}{'v'}*$sh{$sym}{$dt}{$ctr}{'p'}+$sh{$sym}{$dt}{'main'}{'p'}*$sh{$sym}{$dt}{'main'}{'v'})/($sh{$sym}{$dt}{$ctr}{'p'}+$sh{$sym}{$dt}{'main'}{'v'});
	}
}

sub print_symbol()
{
	my %fh;
	for my $sym(sort keys %sh)
	{
		if(!defined $fh{$sym})
		{	
			open($fh{$sym} , " >> ./$sym.csv") or die "Cannot open tickfile $sym.csv\n"; 
		}	
		my $tp=$fh{$sym};
		for my $dt(sort keys %{$sh{$sym}})
		{
			print $tp "$dt,$sym,$dt,$sh{$sym}{$dt}{'main'}{'p'},$sh{$sym}{$dt}{'main'}{'v'}\n"
		}
	}
	for my $hd(keys %fh)
	{
		close $hd;
	}
}
sub getfile()
{
	my @re;
	chdir"./files";
	for(`ls`)
	{
		s/\s+$//;
		push @re,"./files/$_" if /csv/ and /prc/;
	}
	chdir"../";
	return @re;
#	print join"\n",@re;
#	exit;
}