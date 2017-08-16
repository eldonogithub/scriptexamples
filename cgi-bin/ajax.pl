#!/usr/bin/env perl

use strict;
use warnings FATAL => "all";

use local::lib('/home/eldon.olmstead/examples/cgi-bin/perl5');

use Template;
use JSON;

use CGI;

# create reference to CGI module N.B., this module is deprecated for a while now
my $cgi = CGI->new();

sub process {
  # Create Template Toolkit reference.
  my $tt = Template->new(
    'STRICT' => 1,

    #    'DEBUG' => 'dirs',
    #    'DEBUG_FORMAT' => '// $file line $line : $text',
  );

  my @tns;
  my $max = 1026;

  # generate a large number of rows
  for ( my $i = 0 ; $i < $max - 3 ; $i++ ) {

    my $pn = "1613456" . sprintf( "%.4d", $i );

    my $row = {
      "row"          => $i + 4,
      "aor"          => "sip:+$pn\@newpace.com",
      "imsi"         => "$pn",
      "msisdn"       => "+$pn",
      "operatorId"   => "201",
      "creationDate" => "1493900876"
    };
    push( @tns, $row );
  }

  # some canned data
  my $data = [
    {
      "row"          => 1,
      "aor"          => "sip:+16132607803\@newpace.com",
      "imsi"         => "16132607803",
      "msisdn"       => "+16132607803",
      "operatorId"   => "201",
      "creationDate" => "1497531156"
    },
    {
      "row"          => 2,
      "aor"          => "sip:+16132624318\@newpace.com",
      "imsi"         => "6132624318",
      "msisdn"       => "+16132624318",
      "operatorId"   => "201",
      "creationDate" => "1493900876"
    },
    {
      "row"          => 3,
      "aor"          => "sip:+16138572750\@newpace.com",
      "imsi"         => "6138572750",
      "msisdn"       => "+16138572750",
      "operatorId"   => "201",
      "creationDate" => "1493738542"
    }
  ];

  # append all the data together
  push( @$data, @tns );

  my $total = @$data;

  # object to pass back as JSON
  my $db = {
    "draw" => '"' . int( $cgi->param("draw") ) . '"',

    #  "recordsTotal" => $total,
    "status" => "Success"
  };
  
  # get search string
  my $search = $cgi->param('search[value]');
  if ( defined($search) ) {
    print STDERR "Filtering imsi by: $search\n";
  }

  my $start  = int( $cgi->param('start') );
  my $length = int( $cgi->param('length') );
  my $end    = $start + $length - 1;

  my @filtered;
  if ( defined($search) && $search ne "" ) {
    $search = quotemeta($search);
    @filtered = ( grep { $_->{imsi} =~ /^$search/ } @$data );
  }
  else {
    @filtered = @$data;
  }

  my $total_filtered = @filtered;
  my $counter        = 1;
  map { $_->{"row"} = $counter++ } @filtered;

  # determine the slice
  if ( $total_filtered < $end ) {

    # $end = $total_filtered - 1;
  }

  # compute array slice and filter out nulls
  my @slice = grep defined $_, (@filtered)[ $start .. $end ];

  # current length
  my $total_slice = @slice;

  # Add starting point
  my $recordsFiltered = $start + $total_slice;

  if ( $recordsFiltered < $total_filtered ) {
    $db->{"recordsFiltered"} = $recordsFiltered + 1;
  }
  else {
    $db->{"recordsFiltered"} = $recordsFiltered;
  }

  # add data slice
  $db->{"data"} = [@slice];

  my $dbobj = new JSON;

  my $content = $dbobj->pretty(1)->encode($db);


  return $content;
}

my $content;
eval { $content = process(); };

if ($@) {
  use HTML::Escape qw/escape_html/;

  my $error = escape_html($@);
  my $json = {
    "draw" => '"' . int( $cgi->param("draw") ) . '"',
    "data" => [],
    "recordsFiltered" => 0,
    "status" => "Failed",
    "error" => $error,
  };

  my $dbobj = new JSON;
  $content = $dbobj->pretty(1)->encode($json);
}
my $content_length = length($content);

print "Status: 200 Ok\r\n";
print "Content-Length: $content_length\r\n";
print "Content-type: application/json\r\n";
print "\r\n";

print $content;
