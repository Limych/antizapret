#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Socket qw(inet_pton AF_INET6);
use File::Basename;

$| = 1;

my $scriptdir = dirname(__FILE__);

my $fetcher;
if (@ARGV) {
    $fetcher = 'cat "' . $ARGV[0] . '"';
}
else {
    $fetcher = `which fetch curl wget`;
    $fetcher =~ s/^(\S+)\s.*$/$1/s;
    if ($fetcher =~ /fetch/) {
        $fetcher .= ' -o -'
    }
    elsif ($fetcher =~ /curl/) {
        # pass
    }
    elsif ($fetcher =~ /wget/) {
        $fetcher .= ' -O -'
    }
    else {
        die "ERROR: Can't find a program to download data.";
    }
    $fetcher .= ' "https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv"';
}

my @ips = `$fetcher | sed 1d | LC_CTYPE=C cut -d ';' -f 1 | tr "\\|" "\\n" | sed 's/^[ \\t]*//;s/[ \\t]*\$//'`;

my $whitelist;
if (open $whitelist, "$scriptdir/white.list") {
    while( my $line = <$whitelist>)  {
        next if ($line eq "\n");
        chomp($line);
        my $isv6 = ($line =~ /:/);
        if ($isv6) {
            $line = join(":", unpack("H4H4H4H4H4H4H4H4", inet_pton(AF_INET6, $line)));
            push @ips, $line;
        } else {
            $line =~ s/^address:\s+//;
            if ($line =~ /^\d{1,3}(?:\.\d{1,3}){3}$/) {
                push @ips, $line;
            } else {
                $line = `nslookup $line | grep "Address:" | grep -v "#"`;
                chomp($line);
                $line =~ s/Address:\s+//ig;
                push @ips, map { "$_\n" } split /\n/, $line;
            }
        }
    }
    close $whitelist;
}

my @unique_ips = do { my %seen; grep { !$seen{$_}++ } @ips };

my $buf = '';
my $cnt = 0;
my $mask = undef;
my $ip_norm;

foreach my $ip (map {lc} @unique_ips) {
    next if ($ip eq "\n");
    $ip_norm = $ip;
    chomp($ip_norm);
    my $isv6 = ($ip_norm =~ /:/);
    $ip_norm = join(":", unpack("H4H4H4H4H4H4H4H4", inet_pton(AF_INET6, $ip_norm))) if ($isv6);
    if (defined $mask && substr($ip_norm, 0, length($mask)) eq $mask) {
        $buf .= $ip;
        $cnt++;
    }
    else {
        if ($cnt >= 10) {
            print($mask !~ /:/ ? "${mask}0/24\n" : "${mask}00/108\n");
        }
        else {
            print $buf;
        }
        if (!$isv6) {
            ($mask) = ($ip_norm =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)/);
        }
        else {
            ($mask) = ($ip_norm =~ /^((?:[0-9a-f]{4}\:){7}[0-9a-f]{2})/);
        }
        $buf = $ip;
        $cnt = 1;
    }
}
