my %symh;
my @syms=qw!cf j l p rb ta!;
for my $sym(@syms)
{
	my $file="./result_15min_with_zero_pos_0_keep_dkx_1/net_value_${sym}_15.txt";
	for(`cat $file`)
	{
		s/\s+$//ig;
		next unless $_;
		my ($dt,$nv)=(split/,/)[2,-1];
		($dt)=($dt=~/(\d{8})/);
		next unless $dt;
		$symh{$dt}{$sym}=$nv;
	}
}
print"date,";
print join",",@syms;
print",net\n";
for my $dt(sort keys %symh)
{
	my $count=0;
	my $sum=0;
	print"$dt,";
	for my $sym(@syms)
	{
		$count++ if defined $symh{$dt}{$sym};
		$sum+=$symh{$dt}{$sym}if defined $symh{$dt}{$sym};		
		$symh{$dt}{$sym}//=1;
		print"$symh{$dt}{$sym},";
	}
	my $nt=$sum/$count;
	print"$nt\n";
}