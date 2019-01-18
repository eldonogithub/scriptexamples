#!/usr/bin/perl
#

for my $j ( 0, 37273 ) {
  for my $k ( 'KT', 'SKT') {
    for my $l ('OTP') {
      for my $m (0, 37273 ) {
	for my $n ('', 'Your verification code for Samsung Messaging: ' ) {
          my $mv = "OTP";
	  print join(",", "OTP", $j, $k, $l, $m, $n, $mv, $n . $mv ), "\n";
	}
      }
    }
  }
}

for my $j ( 0, 37273 ) {
  for my $k ( 'KT', 'SKT') {
    for my $l ('NRCR') {
      for my $m (0, 37273 ) {
	for my $n ('', 'Your verification code for Samsung Messaging: ' ) {
	  for my $o ('Dynamic', 'Static' ) {
            my $mv = $o eq "Static" ? "NIRSMS0001" : "IMSI-rcscfg";
	    print join(",", "IMSI", $j, $k, $l, $m, $n, $o, $mv, $n . $mv ), "\n";
	  }
	}
      }
    }
  }
}
