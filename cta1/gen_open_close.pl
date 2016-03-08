#!/usr/bin/perl -w
use Getopt::Long;
my $bar_minute;
my $with_zero_position=1;
my $keep_dkx=0;
my $fi;
GetOptions(
	"bar_minute=s" 	=>	\$bar_minute,
	"with_zero_position=s"=>	\$with_zero_position,
	"keep_dkx=s"=>\$keep_dkx,
  "ind_file=s"=>\$fi,
); 
$fi//="./ind_$bar_minute.txt";
my %mctr;
my %sym_pos;
my %sym_lastp;
my %sym_lastctr;
my %sym_lastt;
my %sym_lastdkx;
&load_mainctr();
&cal_return();

sub cal_return()
{
	open(IN ,"$fi") or die "cannot open file $fi\n";
	while(<IN>)
	{		
		my ($sym,$t,$lp,$lon,$dkx)=(split/,/)[0,1,5,8,9];
		my($dt)=($t=~/(^\d{8})/);
		my $nowctr=$mctr{$sym}{$dt};
		$sym_lastctr{$sym}//=$nowctr;
		$sym_pos{$sym}//=0;
		if($keep_dkx)
		{
      $sym_lastdkx{$sym}//=$dkx;
      if($dkx!=0)
      {
        $sym_lastdkx{$sym}=$dkx;
      }
      else
      {
        $dkx=$sym_lastdkx{$sym};
      }
		}
		
		if ($sym_lastctr{$sym} ne $nowctr)#roll contract
		{
			print "$sym_lastctr{$sym},$sym_lastt{$sym},$sym_lastp{$sym},0\n";
			print "$nowctr,$t,$lp,$sym_pos{$sym}\n";
		}
		if($lon>0 and $dkx>0)
		{
			$sym_pos{$sym}=1;
		}
		elsif($lon<0 and $dkx<0)
		{
			$sym_pos{$sym}=-1;
		}
		elsif(($lon<0 and $sym_pos{$sym}>0) and $with_zero_position)
		{
			$sym_pos{$sym}=0;
		}
		elsif(($lon>0 and $sym_pos{$sym}<0) and $with_zero_position)
		{
			$sym_pos{$sym}=0;
		}
		
		print "$nowctr,$t,$lp,$sym_pos{$sym}\n";
		
		$sym_lastp{$sym}=$lp;
		$sym_lastctr{$sym}=$mctr{$sym}{$dt};
		$sym_lastt{$sym}=$t;
		
		
	}
	close IN;
}
sub load_mainctr()
{
	my $fi="./0214mainctr.txt";
	open(IN ,"$fi") or die "cannot open file $fi\n";
	while(<IN>)
	{		
		my ($sym,$dt,$ctr)=(split);
		$mctr{$sym}{$dt}=$ctr;		
	}
	close IN;
}
