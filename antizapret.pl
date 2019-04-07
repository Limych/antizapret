#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

#my @ips = `fetch -o - https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv | sed 1d | cut -d ';' -f 1 | tr "\\|" "\\n" | sed 's/^[ \\t]*//;s/[ \\t]*\$//' | sort | uniq`;
my @ips = `fetch -o - http://api.antizapret.info/group.php | sort | uniq`;

my $buf = '';
my $cnt = 0;
my $mask = '';

foreach my $ip (@ips) {
    if ($mask eq '') {
        ($mask) = ($ip =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)/);
        $buf = $ip;
        $cnt = 1;
    }
    elsif (starts_with($ip, $mask)) {
        $buf .= $ip;
        $cnt++;
    }
    else {
        if ($cnt >= 10) {
            print $mask . "0/24\n";
        }
        else {
            print $buf;
        }
        ($mask) = ($ip =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)/);
        $buf = $ip;
        $cnt = 1;
    }
}



sub starts_with {
    return substr($_[0], 0, length($_[1])) eq $_[1];
}
