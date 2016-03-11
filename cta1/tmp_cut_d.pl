use 5.22.0;
my $dir=".";
opendir FH,$dir;
for my $file(readdir FH)
{
	next unless -d $file;
	next unless $file=~/with_zero_pos/;
	opendir SFH,"$dir/$file";
	for my $f(readdir SFH)
	{
		next unless $f=~/net_value/;
		&writeinfo($file,"$dir/$file/$f");
	}
	close SFH;
}
close FH;
sub writeinfo(@)
{
	my ($t,$f)=@_;
	$t=~s/\_/\,/ig;
	my $line=`tail -n 1 $f`;
	$line=~s/\s+$//;
	my ($sym,$nv)=(split/,/,$line)[0,-1];
	my $pl="$t,$sym,$nv\n";
	$pl=~s/,/\t/ig;
	print$pl;
}