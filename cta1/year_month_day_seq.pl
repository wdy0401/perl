#!/usr/bin/perl -w
opendir(DH,"./nd1") or die "cannot open dir ./nd\n";
for my $file(readdir DH)
{
	next unless $file=~/csv/;
	print"$file\n";
	&fixfile($file);
	#&fixfile("a1509.csv");
	#exit;
}

sub fixfile(@)
{
	my $f=shift @_;
	my $fi="./nd1/$f";
	my $fo="./tick/$f";
	return unless -s $fi;
	open(IN ,"$fi") or die "cannot open file $fi\n";
	open(OUT," >$fo")or die "cannot open file $fo\n";
	while(<IN>)
	{		
		my @a=(split/,/);
		my $tmp=$a[0];
		next if $tmp=~/date/;
		$tmp=$tmp." 0:00" if $tmp!~/\s/;
		my($date,$ms)=(split/\s/,$tmp);
		my($y,$m,$d)=(split/\//,$date);
		#print STDERR "$tmp\t#$date,$ms\t#$y,$m,$d\n";
		if($y>1000)
		{
			$tmp=$y*10000+$m*100+$d;
		}
		else
		{
			$tmp=$y*100+$m+$d*10000;
		}
		$tmp="$tmp,$ms:00";
		$a[0]=$tmp;
		my $l=join",",@a;
		print OUT $l;
	}
	close IN;
	close OUT;
}