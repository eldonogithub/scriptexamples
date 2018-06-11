#!/usr/bin/perl

use strict;
use warnings FATAL => "all";

use local::lib('/home/eldon.olmstead/examples/cgi-bin/perl5');


use WWW::Bugzilla;

# create new bug
my $bz = WWW::Bugzilla->new( server => 'bugzilla.newpace.ca', 
                             email => 'eldon.olmstead@newpace.com',
                             password => 'Neptune2017' );

# get list of available version choices
my @versions = $bz->available('version');

print @versions;
