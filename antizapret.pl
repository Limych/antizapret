#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

$| = 1;

my $fetcher = `which fetch curl wget`;
$fetcher =~ s/^(\S+)\s.*$/$1/s;
if ($fetcher =~ /fetch/) {
    $fetcher .= ' -o -'
} elsif ($fetcher =~ /curl/) {
    # pass
} elsif ($fetcher =~ /wget/) {
    $fetcher .= ' -O -'
} else {
    die "ERROR: Can't find a program to download data.";
}

my @ips = `$fetcher "https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv" | sed 1d | LC_CTYPE=C cut -d ';' -f 1 | tr "\\|" "\\n" | sed 's/^[ \\t]*//;s/[ \\t]*\$//' | sort | uniq`;

my $buf = '';
my $cnt = 0;
my $mask = undef;

foreach my $ip (@ips) {
    next if $ip eq "\n";
    if (defined $mask && substr($ip, 0, length($mask)) eq $mask) {
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
