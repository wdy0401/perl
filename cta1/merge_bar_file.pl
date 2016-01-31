#!/usr/bin/perl -w
opendir(DH,"./000") or die "cannot open dir ./nd\n";
for my $file(readdir DH)
{
	next unless $file=~/csv/;
	print"$file\n";
	&merge("./nd/$file","./000/$file","./nd1/$file")
}

sub merge(@)
{
	my($f1,$f2,$mf)=@_;
	my %outh;
	my @fc1=&readfile($f1);
	my @fc2=&readfile($f2);
	for(@fc1,@fc2)
	{
		$outh{&getcount($_)}=$_;
	}
	open(OUT,"> $mf");
	for my $count(sort{$a<=>$b} keys %outh)
	{
		print OUT $outh{$count};
	}
	close OUT;
}
sub readfile(@)
{
	my $f=shift @_;
	return() unless -s $f;
	open(IN ,"$f") or die "cannot open file $f\n";
	my @re;
	while(<IN>)
	{		
		my @a=(split/,/);
		$a[0]="$a[0] 0:00" if $a[0]!~/\s/ and $a[0]!~/date/;
		my $l=join",",@a;
		push @re,$l;
	}
	close IN;
	return @re;
}
sub getcount(@)
{
	my $line=shift @_;
	return 0 if $line=~/date/;
	my $t=(split/,/,$line)[0];
	#11/17/2014 9:09
	my($m,$d,$y,$h,$min)=($line=~/(\d+)\/(\d+)\/(\d+)\s+(\d+)\:(\d+)/);
	return (((($y*100+$m)*100+$d)*100+$h)*100)+$min;
}