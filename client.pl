#!/usr/bin/perl -w

use strict;
use Socket;
my ( $remote, $port, $iaddr, $paddr, $proto, $line );
$remote = shift || "localhost";
$port   = shift || 2345;          # random port
if ( $port =~ /\D/ ) { $port = getservbyname( $port, "tcp" ) }
die "No port" unless $port;
$iaddr = inet_aton($remote) || die "no host: $remote";
$paddr = sockaddr_in( $port, $iaddr );
$proto = getprotobyname("tcp");
socket( SOCK, PF_INET, SOCK_STREAM, $proto ) || die "socket: $!";
connect( SOCK, $paddr ) || die "connect: $!";

while ( $line = <SOCK> ) {
  print $line;
}

close(SOCK) || die "close: $!";
exit(0);
