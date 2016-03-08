#!/usr/bin/perl -w
use Getopt::Long;
use File::Path;
my $bar_minute;
my $infile;
my $outdir="";
GetOptions(
	"bar_minute=s" 	=>	\$bar_minute,
	"infile=s" =>\$infile,
	"outdir=s" =>\$outdir,
); 
$infile//="./open_close_$bar_minute.txt";
my %dh;
open(IN,"$infile") or die "Cannot open file $infile\n";
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
  mkpath $outdir if $outdir;
  my $outfile="./${outdir}/net_value_${sym}_${bar_minute}.txt" if $outdir;
  $outfile="./net_value_${sym}_${bar_minute}.txt" unless $outdir;
  open(OUT , "> $outfile");
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
