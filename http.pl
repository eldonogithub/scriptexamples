#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request;
use Time::HiRes;

use IPC::SysV qw(IPC_PRIVATE S_IRUSR S_IWUSR S_IRWXU);
use IPC::SharedMem;
use HTTP::Async;

my $children   = shift || 1;
my $iterations = shift || 1;

my $shm = IPC::SharedMem->new( IPC_PRIVATE, $children * 16, S_IRWXU );

my $start = Time::HiRes::time;

for ( my $i = 0 ; $i < $children ; $i++ ) {
  my $pid = fork();
  if ( $pid == 0 ) {
    my $async = HTTP::Async->new;

    # create some requests and add them to the queue.
    my $req     = HTTP::Request->new( "GET", "http://localhost" );
    my $j       = 0;
    my $count   = 0;
    my $success = 0;
    my $length  = 0;

    $async->add($req);
    $j++;

    while ( $async->not_empty ) {
      if ( my $resp = $async->next_response ) {

        # deal with $response

        # count responses
        $count++;

        if ( $resp->is_success() ) {
          $success++;
          $length = length($resp->content());
        }
        if ( $count >= $iterations ) {
          last;
        }
      }

      # continue sending?
      if ( $j < $iterations ) {

        # do something else
        $async->add($req);
        $j++;
      }
    }

    # save the data for the parent
    $shm->write( pack( 'Q', $success ), $i * 16, 8 );
    $shm->write( pack( 'Q', $length ), $i * 16 + 8, 8 );

    exit 0;
  }
}
while ( wait() != -1 ) { }
my $end      = Time::HiRes::time;
my $duration = $end - $start;

my $total = 0;
my $bytes = 0;
for ( my $i = 0 ; $i < $children ; $i++ ) {
  $total += unpack( 'Q', $shm->read( $i * 16, 8 ) );
  $bytes += unpack( 'Q', $shm->read( $i * 16 + 8, 8 ) );
}

$shm->remove();

print "Total: $total\n";
print "Bytes: $bytes\n";
printf "Requests/second: %.4f/s\n", $total / $duration;

