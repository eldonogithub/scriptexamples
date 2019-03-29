#!/usr/bin/perl

use local::lib("abc");

use URI::Encode qw(uri_encode);
use URI;

my $encoder = URI::Encode->new({encode_reserved => 0});

my $uri = URI->new();

$uri->scheme("http");
$uri->host("hostname");
$uri->path("the/path/");
$uri->query_form("query" =>"+++1","a"=>"1","b"=>"2","c"=>"3","d"=>"4");
$uri->fragment("fragment=1&a=1&b=2&c=3&d=4");

print $encoder->encode("http://hostname:8080?query=+++1&a=1&b=2&c=3&d=4#fragment=1&a=1&b=2&c=3&d=4") . "\n";
print "URI: $uri\n:";
