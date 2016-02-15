#
my $cmd="";
for my $bar_minute(7,10,15,19,23)
{
	$cmd="perl daily_driver.pl -bar_minute $bar_minute";
	print "$cmd\n";
	system($cmd);
	$cmd="perl merge_ind_file.pl |  tee ind_$bar_minute.txt |awk -F\",\" '{print \$1,\$2,\$9,\$10}' | grep -P -v \"0\$\" >ind_short_$bar_minute.txt";
	print "$cmd\n";
	system($cmd);
	$cmd="perl gen_open_close.pl > open_close_$bar_minute.txt";
	print "$cmd\n";
	system($cmd);
}
