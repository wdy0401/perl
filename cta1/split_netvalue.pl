#!/usr/bin/perl -w
use Getopt::Long;
my $bar_minute;
GetOptions(
	"bar_minute=s" 	=>	\$bar_minute,
); 
my %dh;
my $f="./open_close_$bar_minute.txt";
open(IN,"$f") or die "Cannot open file $f\n";
while(<IN>)
{
  s/\s+$//;
  my $line=$_;
  my $ctr=(split/,/)[0];
  my($sym)=($ctr=~/^(\D+)/);
  if(!defined $dh{$sym})
  {
    my @a;
    $dh{$sym}=\@a;
  }
  push @{$dh{$sym}},"$sym,$line";
}
close IN;

for my $sym(keys %dh)
{
  my $pn=0;
  my $pos=0;
  my $lastp;
  my $base;
  open(OUT , ">net_value_${sym}_${bar_minute}.txt");
  for(@{$dh{$sym}})
  {
    my ($sym,$ctr,$t,$p,$size)=(split/,/);
    $lastp//=$p;
    $base//=$p;
    if($pos==0)
    {
    }
    elsif($pos==1)
    {
      $pn=$pn+$p-$lastp;
    }
    elsif($pos==-1)
    {
      $pn=$pn-$p+$lastp;
    }
    $pos=$size;
    $lastp=$p;
    my $netvalue=1+$pn/$base;
    print OUT "$sym,$ctr,$t,$p,$size,$pn,$netvalue\n";
  }
  close OUT;
}
