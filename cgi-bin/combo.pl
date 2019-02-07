#!/usr/bin/perl
#

my @rcs_states = qw( 0 -1 -2 -3 positive );
my @vers = qw( 0 -1 -2 positive );
 
print "vers\n";
foreach my $ver ( @vers ) {
  foreach my $rcs_state ( @rcs_states ) {
    my $version = $ver;
    my $validity = $ver;
    my $rcsDisabledState = "NA";

    if ( $ver eq "positive" ) {
      $rcsDisabledState = $rcs_state;
    }
    print "positive, positive, $rcs_state, $ver, $version, $validity, $rcsDisabledState\n";
  }
}
