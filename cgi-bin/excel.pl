#!/usr/bin/perl
#
#

use strict;
use warnings FATAL=>'all';

=head1 SYNOPSIS

excel.pl [options] FILE

 Options:
    -?
    -help           brief help message
    -man            full documentation

=head1 OPTIONS

=over 4

=item B<-help|?>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 ARGUMENTS

=over 4

=item B<FILE>

The file with tab delimited columns

=back

=head1 DESCRIPTION

B<excel.pl> converts a tabbed delimited file to Wiki markup

=head1 FUNCTIONS

=cut

use Pod::Usage;
use Getopt::Long;

my $man  = 0;
my $help = 0;
my $configFile;
my $debug_logging = 0;

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
'help|?' => \$help,
man      => \$man,
'd'      => \$debug_logging,
) or pod2usage( -verbose => 0 );
pod2usage( -verbose => 1 ) if $help;
pod2usage( -verbose => 2 ) if $man;

my @headers;
my @rows;

my $header=0;

while (<>) {

  my $row;
  chomp;
  my @cols = split(/\t/, $_ );

  $row = "";
  if ( $header == 0 ) {
    # first row is header
    $header = 1;
    $row .= "|-\n! " . join("\n! ", @cols);
  }
  else {
    # all other rows are data
    $row .= "|-\n| " . join("\n| ", @cols);
  }
  push(@rows, $row);
}

my $content = join("\n", @rows);

print <<WIKI;
{| class="nptable sortable"
|+ '''Account Server State Transitions'''
$content
|}
WIKI
