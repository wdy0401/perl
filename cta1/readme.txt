������Լ���ɷ�ʽ�Ծɻ�����ʽtick�ļ� ��δ����ÿ�ս��յ�tick�ļ�

�ϲ� ind �ļ�

��������ʱ��

ͨ������ʱ����������Լ����ʱ��õ���ֵ










#�ϲ�tick�ļ�

#���volume�ı�� �����ڶ���

#���tick�ļ��ķָ�

#���post

#���pre

  cta1 ����
  cta1_post����
  mainctr ���� ����hbtick


  merge
  yearmonthday
  split_tick
  gen_mainctr
  daily_driver.pl
  mergeind tee ind.txt |awk -F"," '{print $1,$2,$9,$10}' ind.txt | grep -P -v "0$" >ind_short.txt
  gen_open_close


