use strict;
use warnings;
open(IN,"./receiver/test_receiver.exe |");
while(<IN>)
{
	print STDERR "ERROR $_\n";
	print STDERR "$_\n";
}