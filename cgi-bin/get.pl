#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request;

my $ua = LWP::UserAgent->new();

# Create a request
my $req = HTTP::Request->new( 'GET' => 'http://localhost:5544' );
$req->content_type("text/xml");
$req->content(<<"HTML");
<?xml version="1.0" encoding="UTF-8"?>
<x>
  <a></a>
</x>
HTML

# Pass request to the user agent and get a response back
my $res = $ua->request($req);

# Check the outcome of the response
if ( $res->is_success ) {
    print length( $res->content );
}
else {
    print $res->status_line, "\n";
}
