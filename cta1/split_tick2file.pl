#!/usr/bin/perl -w
use File::Path;
opendir(DH,"./merge") or die "cannot open dir ./merge\n";
for my $file(readdir DH)
{
	next unless $file=~/csv/;
#	next unless $file=~/cu/;
	&split_file($file);
}
sub split_file(@)
{
	my $f=shift @_;
	my %dh=();
	open(IN,"./merge/$f") or die "Cannot open file $f\n";
	while(<IN>)
	{
		my $d=(split/,/)[0];
		if(!defined $dh{$d})
		{
			my @a;
			$dh{$d}=\@a;
		}
		push @{$dh{$d}},"$_";
	}
	close IN;
	for my $date(sort keys %dh)
	{
		mkpath "./split_tick/$date";
		next if -s "./split_tick/$date/$f";
		open(OUT," >./split_tick/$date/$f") or die"Cannot open file ./split_tick/$date/$f\n";
		print OUT join"",@{$dh{$date}};
		close OUT;
	}
}