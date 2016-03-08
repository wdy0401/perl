#
my $cmd="";
#for my $bar_minute(7,10,15,19,23)
for my $bar_minute(15)
{
	$cmd="perl daily_driver.pl -bar_minute $bar_minute";
	print "$cmd\n";
	system($cmd);
	$cmd="perl merge_ind_file.pl > ind_$bar_minute.txt";
	print "$cmd\n";
	system($cmd);
	$cmd="perl gen_open_close.pl -bar_minute $bar_minute > open_close_$bar_minute.txt";
	print "$cmd\n";
	system($cmd);
	$cmd="perl split_netvalue.pl -bar_minute $bar_minute";
	print "$cmd\n";
	system($cmd);
}
