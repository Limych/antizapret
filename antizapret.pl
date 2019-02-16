#!/usr/local/bin/perl

my @ips = `fetch -o - https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | sed 1d | cut -d ';' -f 1 | tr "\\|" "\\n" | sed 's/^[ \\t]*//;s/[ \\t]*\$//' | sort | uniq`;

my $buf = '';
my $cnt = 0;
my $mask = '';

foreach $ip (@ips) {
	if ($mask == '') {
		($mask) = ($ip =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)/);
		$buf = $ip;
		$cnt = 1;
	} elsif (starts_with($ip, $mask)) {
		$buf .= $ip;
		$cnt++;
	} elsif ($cnt >= 10) {
		print $mask."0/24\n";
		$buf = $mask = '';
		$cnt = 0;
	} else {
		print $buf;
		$buf = $mask = '';
		$cnt = 0;
	}
}


sub starts_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

