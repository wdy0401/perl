my @fs=qw(
cf1201
cf1205
cf1209
cf1301
cf1305
cf1309
cf1401
cf1405
cf1409
cf1501
cf1505
cf1509
cf1601
cf1605
cf1609
j1201
j1205
j1209
j1301
j1305
j1309
j1401
j1405
j1409
j1501
j1505
j1509
j1601
j1605
j1609
jm1309
jm1401
jm1405
jm1409
jm1501
jm1505
jm1509
jm1601
jm1605
jm1609
l1201
l1205
l1209
l1301
l1305
l1309
l1401
l1405
l1409
l1501
l1505
l1509
l1601
l1605
l1609
p1201
p1205
p1209
p1301
p1305
p1309
p1401
p1405
p1409
p1501
p1505
p1509
p1601
p1605
p1609
rb1201
rb1205
rb1210
rb1301
rb1305
rb1310
rb1401
rb1405
rb1410
rb1501
rb1505
rb1510
rb1601
rb1605
ta1201
ta1205
ta1209
ta1301
ta1305
ta1309
ta1401
ta1405
ta1409
ta1501
ta1505
ta1509
ta1601
ta1605
ta1609
);


my $line=' 
    Workbooks.Open Filename:="C:\Users\trader2\Documents\GitHub\perl\cta1\new\AAAA.xlsx"
    ActiveWorkbook.SaveAs Filename:="C:\Users\trader2\Documents\GitHub\perl\cta1\new\AAAA.csv", FileFormat:=xlCSV, _
        CreateBackup:=False
    ActiveWorkbook.Save
    ActiveWindow.Close
	';
for my $f(@fs)
{
	my $nl=$line;
	$nl=~s/AAAA/$f/g;
	print"$nl";
}	
	