#!/usr/bin/perl -w
use Getopt::Long;
my $bar_minute;
my $zero_position=1;
GetOptions(
	"bar_minute=s" 	=>	\$bar_minute,
	"zero_position=s"=>	\$zero_position,
); 
my %mctr;
my %sym_pos;
my %sym_lastp;
my %sym_lastctr;
my %sym_lastt;
&load_mainctr();
&cal_return();

sub cal_return()
{
	my $fi="./ind_$bar_minute.txt";
	open(IN ,"$fi") or die "cannot open file $fi\n";
	while(<IN>)
	{		
		my ($sym,$t,$lp,$lon,$dkx)=(split/,/)[0,1,5,8,9];
		my($dt)=($t=~/(^\d{8})/);
		my $nowctr=$mctr{$sym}{$dt};
		$sym_lastctr{$sym}//=$nowctr;
		$sym_pos{$sym}//=0;
		
		if ($sym_lastctr{$sym} ne $nowctr)
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
		elsif(($lon<0 and $sym_pos{$sym}>0) and $zero_position)
		{
			$sym_pos{$sym}=0;
		}
		elsif(($lon>0 and $sym_pos{$sym}<0) and $zero_position)
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
