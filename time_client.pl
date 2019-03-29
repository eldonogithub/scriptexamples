#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Socket;
my $SECS_OF_70_YEARS = 2208988800;
sub ctime { scalar localtime( shift() || time() ) }
my $iaddr = gethostbyname("localhost");
my $proto = getprotobyname("tcp");
my $port  = getservbyname( "time", "tcp" );
my $paddr = sockaddr_in( 0, $iaddr );
my ($host);
$| = 1;
printf "%-24s %8s %s\n", "localhost", 0, ctime();

foreach $host (@ARGV) {
  printf "%-24s ", $host;
  my $hisiaddr = inet_aton($host) || die "unknown host";
  my $hispaddr = sockaddr_in( $port, $hisiaddr );
  socket( SOCKET, PF_INET, SOCK_STREAM, $proto )
    || die "socket: $!";
  connect( SOCKET, $hispaddr ) || die "connect: $!";
  my $rtime = pack( "C4", () );
  read( SOCKET, $rtime, 4 );
  close(SOCKET);
  my $histime = unpack( "N", $rtime ) - $SECS_OF_70_YEARS;
  printf "%8d %s\n", $histime - time(), ctime($histime);
}
