#!/usr/bin/perl

use IO::Socket::INET;
use Socket qw(SOL_SOCKET SO_RCVBUF IPPROTO_IP IP_TTL);
my $socket = IO::Socket::INET->new( LocalPort => 0, Proto => 'udp' )
  or die "Cannot create socket: $@";
$socket->setsockopt( SOL_SOCKET, SO_RCVBUF, 64 * 1024 )
  or die "setsockopt: $!";
print "Receive buffer is ", $socket->getsockopt( SOL_SOCKET, SO_RCVBUF ),
  " bytes\n";
print "IP TTL is ", $socket->getsockopt( IPPROTO_IP, IP_TTL ), "\n";
