use FindBin qw($Bin);
use Getopt::Long;
use File::Path;
use POSIX;
use 5.22.0;

my $cmd="";
for my $with_zero_position(0,1)
{
  for my $keep_dkx(0,1)
  {
    $cmd="perl gen_open_close.pl -bar_minute 15 -keep_dkx $keep_dkx -with_zero_position $with_zero_position -ind_file ./result_day/ind_15.txt > open_close_15_15_with_zero_pos_${with_zero_position}_keep_dkx_${keep_dkx}.txt";
    print "$cmd\n";
    system($cmd);
    $cmd="perl split_netvalue.pl -bar_minute 15 -outdir with_zero_pos_${with_zero_position}_keep_dkx_${keep_dkx} -infile open_close_15_15_with_zero_pos_${with_zero_position}_keep_dkx_${keep_dkx}.txt ";
    print "$cmd\n";
    system($cmd);
  }
}
