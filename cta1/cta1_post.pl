#!/usr/bin/perl -w 

use FindBin qw($Bin);
use Getopt::Long;
use File::Path;
use POSIX;
use 5.22.0;

use lib "c:/code";
use WMATH;

my $ctr="cu1601";
my $date=20151228;
my $logfile;
my $tickfile;
GetOptions(
	"ctr=s" 	=>	\$ctr,
	"logfile=s" =>	\$logfile,
	"tickfile=s" =>	\$tickfile,
); 

__DATA__
1	�ҵ���������symbol���ļ�
2	���ƴ��ļ� 

3	���ü�¼��tick������һ��T������
4	���ܵ�������ʵʱ���ݶԱ�

5	�ϲ�symbol�ļ�  ���ú�T+1��
6	����T��Ӧ�гֲ�����