open input, "list.txt";
chomp(@inp = <input>);
#�������, � ������� ����!
@lines = map {s/"//g; split ','} @inp;
print @lines[-1];
#������ ���� ����������, ����� � �������� ��� ��������� �������� �� �������