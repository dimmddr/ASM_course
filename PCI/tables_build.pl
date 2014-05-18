use 5.016;
use warnings;
use Data::Dumper;
open pci_device, "list.txt";
#�������, � ������� ����!
my %dev;
my $i = 0; my %cnt;
my $max = -1;
foreach (<pci_device>) {
	chomp; 
	s/^"(.*)"$/$1/; 
	my @a = split '\",\"';
	#������������� �������� ������
	#� ���� ������ ���������� ���� ����� ��� ��� �� ���������. ��������� ������ ������ �������
	$a[0] =~ s/^0x([0-9A-Fa-f]{4})/$1/;
	if(!($a[1] =~ /^0(x|X)([0-9A-Fa-f]{4}$)/)) {
		if($a[1] =~ /^0x([0-9a-f]{3}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{3}$)/0$+{id}/i;
		} elsif($a[1] =~ /^0x([0-9a-f]{2}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{2}$)/00$+{id}/i;
		} elsif($a[1] =~ /^0x([0-9a-f]{1}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{1}$)/000$+{id}/i;
		} else { next }
	}
	$dev{$a[0]}{$a[1]} = join " ", $a[2..4];
	$max = length(join " ", $a[2..4]) if($max < length(join " ", $a[2..4]));
	# print $a[0]." -> ";
	# print $a[1]." -> ";
	# say $dev{$a[0]}{$a[1]};
}
#��� �������� �����?
say $max;
