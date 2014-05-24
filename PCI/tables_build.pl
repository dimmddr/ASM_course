use 5.016;
use warnings;
use Data::Dumper;
open pci_device, "list.txt";
open my $out1, ">smth";
open my $out2, ">smth2";
open my $text, ">names.txt";
my %dev;	#Всего лишь хэш хэшей
my $i = 0;
my $max = 135;
foreach (<pci_device>) {
	chomp; 
	s/^"(.*)"$/$1/;  #Регексп, я вызываю тебя!
	my @a = split '\",\"';
	#Корректировка значений списка
	#Я буду только дописывать нули слева там где их нехватает. Остальные косяки просто пропущу
	$a[0] =~ s/^0x([0-9A-Fa-f]{4})/$1/;
	if(!($a[1] =~ /^0(x|X)([0-9A-Fa-f]{4}$)/)) {
		if($a[1] =~ /^0x([0-9a-f]{3}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{3}$)/0$+{id}/i;
		} elsif($a[1] =~ /^0x([0-9a-f]{2}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{2}$)/00$+{id}/i;
		} elsif($a[1] =~ /^0x([0-9a-f]{1}$)/i) {
			$a[1] =~ s/^0x(?<id>[0-9a-f]{1}$)/000$+{id}/i;
		} else { next }
	} else {
		$a[1] =~ s/^0x(?<id>[0-9a-f]{4}$)/$+{id}/i;
	}
	#Делаем строки одинаковыми по длине, чтобы можно было считать смещения для строки относительно начала файла
	my $str = join " ", @a[2, 3, 4];
	if(length($str) <= $max) {
		$str = $str.' 'x($max - length($str)) if(length($str) < $max);
		$dev{$a[0]}{$a[1]} = $str;
	}
}
# print Dumper %dev
binmode($out1);
binmode($out2);
my $out = $out1;
foreach my $v (sort keys %dev){
	foreach my $p (sort keys $dev{$v}) {
		print $out (, hex($v));
		# print $out $v;
		print $out $p;
		my $str = sprintf("%X", $i);
		$str = '0'x(4 - length($str)).$str; 
		#Если сделать в каждом файле свою нумерацию, то можно превратить 4 в 3. 
		#Впрочем это даст выигрыш в ~2Кб, не так уж и много, а вот проблем от этого...
		print $out $str;
		print $text $dev{$v}{$p};
		$i++;
		if(3685 == $i) { #3685 is MAGIC!!! 42
			$out = $out2;
			print $v.$p;
		}
	}	
}
print "\n";
say $i;