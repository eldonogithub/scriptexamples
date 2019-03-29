#!/usr/bin/perl

use IO::Socket::IP;
use Socket qw(getnameinfo);

my $server = IO::Socket::IP->new(LocalPort => 12345, Listen => 1) or
die "Cannot listen - $@";
my $socket = $server->accept or die "accept: $!";
my ($err, $hostname, $servicename) = getnameinfo($socket->peername);
die "Cannot getnameinfo - $err" if $err;
print "The peer is connected from $hostname\n";
