#!/usr/bin/perl -w

my $f="0214mainctr.txt";
open(IN ,"$f") or die "cannot open file $f\n";
my @re;
my @syms=qw!cf j jm l p rb ta!;
while(<IN>)
{		
	s/\s+$//;
	my ($sym,$dt,$ctr)=(split);
	next unless $sym ~~ @syms;
	print"$sym\t$dt\t$ctr\n";
	system("perl cta1.pl -date $dt -tick_type tr_tick -ctr $ctr -logfile c:/report/$dt/cta1/$sym.txt -tickfile ./split_tick/$dt/$ctr.csv");
	system("perl cta1_post.pl -date $dt -sym $sym");
}
close IN;
