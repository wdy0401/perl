#!/usr/bin/perl -w
my $dir="C:/report";
my @arr=();
opendir(DH,"$dir") or die "cannot open dir $dir\n";
for my $file(readdir DH)
{
#	print STDERR "FILE $file\n";
	next unless -d "$dir/$file";
	next unless $file=~/\d{8}/;
	opendir(SUBDH,"$dir/$file/cta1") or die "cannot open dir $dir/$file/cta1\n";
	for my $subfile(readdir SUBDH)
	{
      next if -d "$dir/$file/cta1/$subfile";
      next if $subfile=~/pre/;
      next if $subfile=~/\_/;
      my ($sym)=($subfile=~/^(\w+)\./);
      @arr=(@arr,&readfile("$dir/$file/cta1/$subfile",$sym))    
	}
}
print join"",@arr;

sub readfile(@)
{
	my ($f,$sym)=@_;
	return() unless -s $f;
	print STDERR "$f\n";
	open(IN ,"$f") or die "cannot open file $f\n";
	my @re;
	while(<IN>)
	{		
		push @re,"$sym,$_";
	}
	close IN;
	return @re;
}
