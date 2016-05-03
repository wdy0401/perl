#@days
#$sh{$date}{$symbol}{$ctr}{'p'}
#$sh{$date}{$symbol}{$ctr}{'v'}
for(@days)
{
	for(@files)
	{
		readfile()
	}
	&print_symbol();
}

sub print_symbol()
{
	print"$date,15:00:00,$symbol,$price,$volume\n";#9:00-15:00
}