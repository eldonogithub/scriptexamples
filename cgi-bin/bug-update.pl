#!/usr/bin/perl
#

use strict;
use warnings FATAL => "all";

use local::lib('/home/eldon/scriptexamples/cgi-bin/perl5');

use BZ::Client;
use BZ::Client::Bug::Comment;

# create new bug
print "Connecting...\n";
my $client = BZ::Client->new(
  url      => 'https://bugzilla.newpace.ca',
#   user     => '',
#   password => ''
);

$client->logger(
     sub {
         my ($level, $msg) = @_;
         print STDERR "$level $msg\n";
         return 1;
     });

print "Retrieving comments...\n";
eval {
  my $response = BZ::Client::Bug::Comment->get( $client, { ids => [ 26071 ] } );

  use Data::Dumper;

  foreach my $bug ( keys %{ $response->{bugs} } ) {
    print "  $bug\n";
    my $comments  = $response->{bugs}->{$bug};

    foreach my $comment ( @$comments ) {
      print "    $comment->{text}\n";
    }
  }
};

if (ref($@) eq "HASH" ) {
  print "An Error Occured\n";
  print "Message: ".     $@->message() . "\n";
  print "HTTP Code: ".   $@->http_code() . "\n" if $@->http_code();
  print "XMLrpc Code: ". $@->xmlrpc_code() . "\n" if $@->xmlrpc_code();
}

if ($@ ) {
  print STDERR $@;
}
