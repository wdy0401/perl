#!/usr/bin/perl -w
use 5.22.0;
use Getopt::Long;
my $bar_minute=15;
GetOptions(
	"bar_minute=s"=>	\$bar_minute,
); 
my $f="0214mainctr.txt";
open(IN ,"$f") or die "cannot open file $f\n";
my @re;
my @syms=qw!cf j jm l p rb ta!;
#my @syms=qw!cf!;
while(<IN>)
{		
	s/\s+$//;
	my ($sym,$dt,$ctr)=(split);
	next unless $sym ~~ @syms;
	print"$sym\t$dt\t$ctr\n";
#	say("perl cta1.pl -date $dt -tick_type tr_tick -ctr $ctr -bar_minute $bar_minute -logfile c:/report/$dt/cta1/$sym.txt -tickfile ./split_tick/$dt/$ctr.csv -lon_daily 1");
#	exit;
	system("perl cta1.pl -date $dt -tick_type tr_tick -ctr $ctr -bar_minute $bar_minute -logfile c:/report/$dt/cta1/$sym.txt -tickfile ./split_tick/$dt/$ctr.csv -lon_daily 1");
	system("perl cta1_post.pl -date $dt -sym $sym");
}
close IN;
