#!/usr/bin/perl

=head1 SYNOPSIS

bz.pl [options] [filename]+

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

=back

=head1 DESCRIPTION

B<bz.pl> queries Bugzilla for all changed tickets since yesterday, will do more as I need it

=head1 FUNCTIONS

=cut

use strict;
use warnings;

use local::lib '/home/eldon.olmstead/examples/cgi-bin/perl5';

use BZ::Client;
use BZ::Client::Bug;
use BZ::Client::Bugzilla;
use BZ::Client::Bug::Comment;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP qw();
use Email::MIME;
use HTML::Escape;
use URI::Escape;
use URI;
use Date::Calc;
use DateTime;

use Pod::Usage;
use Getopt::Long;

our $VERSION = "0.001";

my $man  = 0;
my $help = 0;
my $trace = 0;      # no debugging output by default
my $sendemail = 1; # default always send email
my $end_delta = 0;
my $days = 0;       # offset calculated time by a number of days
my $hours = 0;      # offset calculated time by a number of days

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions(
  'help|?' => \$help,
  man      => \$man,
  'trace' => \$trace,
  'sendemail!' => \$sendemail,
  'days=i' => \$days,
  'hours=i' => \$hours,
  'end=i' => \$end_delta,
) or pod2usage( -verbose => 0 );

pod2usage( -verbose => 1 ) if $help;
pod2usage( -verbose => 2 ) if $man;

my $SMTP_HOSTNAME = 'localhost';
my $SMTP_PORT     = 25;

eval {
  my $client = BZ::Client->new(
    url       => 'https://bugzilla.newpace.ca',
    user      => 'eldon.olmstead@sigmastcomms.com',
    password  => 'Neptune2017',
    autologin => 0
  );

  # Login to Bugzilla
  $client->login() || die "Unable to login";

  # compute the current hour
  my $current_hour = DateTime->now(time_zone => 'Canada/Atlantic')->truncate( to=> 'hour');
  print "Current Hour: $current_hour\n" if ( $trace );
  my $prev_time = $current_hour->clone();

  # if the current hour is the starting business day hour
  if ( $current_hour->hour() == 8 ) {
    if ( $current_hour->day_of_week() == 1 ) {
      # query for all changes since over the weekend
      $prev_time->add( days => -2, hours => -15 );
    }
    else {
      # query for all changes since yesterday
      $prev_time->add( hours => -15 );
    }
  }
  else {
    # hourly report
    $prev_time->add( hours => -1 );
  }

  if ( $days != 0 || $hours != 0 ) {
    $prev_time = $current_hour->clone();
    $prev_time->add( days => $days, hours => $hours );
  }

  my $bzLastChangeTime = $prev_time->strftime("%Y-%m-%dT%H:%M:%S");

  print "Start time: " . $bzLastChangeTime . "\n" if ( $trace );

  my $assigned = BZ::Client::Bug->search(
    $client,
    {
      bug_status => [
         'UNCONFIRMED', 'CONFIRMED', 'IN_PROGRESS', 'DEV_BLOCKED',
         'ON_HOLD', 'RESOLVED', 'RELEASED', "IN_REVIEW", "DONE"
      ],
      assigned_to => [
        'eldon.olmstead@sigmastcomms.com', 'isselmou.sneiguel@sigmastcomms.com',
        'spencer.guthro@sigmastcomms.com', 'hiren.pandya@sigmastcomms.com', 
        'matthew.egener@sigmastcomms.com'
      ],
      # target_milestone => "6.5.2",
      last_change_time => $bzLastChangeTime,
      include_fields   => [
        'id',      'summary',
        'product', 'target_milestone',
        'status',  'assigned_to', 'creator',
        'last_change_time'
      ]
    }
  );

  my $reported = BZ::Client::Bug->search(
    $client,
    {
      bug_status => [
         'UNCONFIRMED', 'CONFIRMED', 'IN_PROGRESS', 'DEV_BLOCKED',
         'ON_HOLD', 'RESOLVED', 'RELEASED', "IN_REVIEW", "DONE"
      ],
      creator => [
        'eldon.olmstead@sigmastcomms.com', 'isselmou.sneiguel@sigmastcomms.com',
        'spencer.guthro@sigmastcomms.com', 'hiren.pandya@sigmastcomms.com', 
        'matthew.egener@sigmastcomms.com'
      ],
      # target_milestone => "6.5.2",
      last_change_time => $bzLastChangeTime,
      include_fields   => [
        'id',      'summary',
        'product', 'target_milestone',
        'status',  'assigned_to', 'creator',
        'last_change_time'
      ]
    }
  );

  print "Assigned: \n" if ( $trace );
  map { print $_->id() . "\n"; } @$assigned if ( $trace );
  print "Reported: \n" if ( $trace );
  map { print $_->id() . "\n"; } @$reported if ( $trace );

  print "Subtotals: assigned_to: " . @$assigned . ", reported: " . @$reported . "\n" if ( $trace );

  my %visited;
  my @bugs = grep { !$visited{$_->id()}++ } @$assigned, @$reported;

  my $rows = "";
  
  # sort bugs by the following explicit sort routine
  sub sort_by_milestone {
    return $a->{"target_milestone"} cmp $b->{"target_milestone"} || 
           $a->product() cmp $b->product() ||
           $a->id() <=> $b->id();
  }

  my $content;
  my $subject;

  if ( @bugs == 0 ) {
    $subject = "Bugzilla Team - No Changes Since $bzLastChangeTime";
    $content = <<HTML;
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style type="text/css">
.nobugs {
  color: grey;
}
    </style>
  </head>
  <body>
    <p class="nobugs" style="color: grey;">No bugs changed</p>
  <body>
</html>
HTML
  }
  else {
    my $total_tickets = 0;
    foreach my $entry ( sort sort_by_milestone @bugs ) {
     
      my $id = $entry->id();
      print "$id Process ticket \n" if ( $trace );

      # grab first element of the returned list
      my ($history) = $entry->history( $client, { ids => [ $entry->id() ] } );
      my $comments = BZ::Client::Bug::Comment->get( $client, { ids => [ $entry->id() ] } );

      my $uri =
	URI->new( 'https://bugzilla.newpace.ca/show_bug.cgi?id=' . $entry->id() );
      my $bug_encoded = $uri->as_string();
      my $summary     = $entry->summary();
      my $change      = $entry->last_change_time()->set_time_zone('Canada/Atlantic');
      my $product     = $entry->product();
      my $target      = $entry->{"target_milestone"};
      my $assigned_to = $entry->{"assigned_to"} =~ s/\@.*$//r;
      my $status      = $entry->{"status"};

      my $anchor = '<a href="' . $bug_encoded . '">' . $id . '</a>';
      my $product_html = HTML::Escape::escape_html($product);
      my $target_html  = HTML::Escape::escape_html($target);
      my $assigned_html = HTML::Escape::escape_html($assigned_to);
      my $summary_html = HTML::Escape::escape_html($summary);
      my $status_html = HTML::Escape::escape_html($status);

      my $ticket_comments = 0;
      my ( $bug ) = keys %{$comments->{'bugs'}};

      my @comment_links;

      # process all comments in the bug
      my $cid = -1;
      for my $comment ( @{$comments->{'bugs'}->{$bug}} ) {
        $cid++;
	my $when = $comment->{'time'};
	if ( DateTime->compare($when, $prev_time) >= 0 ) {
          print "$id commentId=$cid\n" if ($trace);
          $ticket_comments++;
          my $uri =
	    URI->new( 'https://bugzilla.newpace.ca/show_bug.cgi?id=' . $entry->id() . '#c' . $cid );

          # save the comment reference in a simple list
          push(@comment_links, { "uri" => $uri->as_string(), "cid" => $cid } );
        }
      }

      # if there are no comments, I don't want to see the ticket show up.
      # Changes to status aren't as important.
      if ( $ticket_comments == 0 ) {
        print "$id Skipping - no comments\n" if ( $trace );
        next;
      }

      my $ticket_changes = 0;

      # determine how many changes have occured
      for my $update ( @{ $history->{"history"} } ) {
	my $when = $update->{'when'};

	if ( DateTime->compare($when, $prev_time) >= 0 ) {
	  $ticket_changes++;
          for my $change ( @{$update->{'changes'}} ) {
            my $field_name = $change->{'field_name'};
            my $removed = $change->{'removed'};
            my $added = $change->{'added'};
            print "$id $field_name: $removed => $added\n" if ($trace);
          }
	}
      }

      print "$id,$product,$target,$status,$summary,$ticket_changes\n" if ($trace);

      $total_tickets++;
      my @anchors = map { "<a href=\"" . $_->{"uri"} . "\">c" . $_->{"cid"} . "</a>"; } @comment_links;
      my $comments_html = join(", ", @anchors);

      print "$id comments_html=$comments_html\n" if ( $trace);

      $rows .= <<ROW;
	<tr>
	  <td>$anchor</td>
	  <td>$target_html</td>
	  <td>$assigned_html</td>
	  <td>$status_html</td>
	  <td class="summary" style="display: block; width: 400px; white-space: nowrap; text-overflow: ellipsis; overflow: hidden; max-width: 400px;">$summary</td>
	  <td class="change" style="white-space: nowrap;">$change</td>
	  <td>$ticket_comments $comments_html</td>
	  <td>$ticket_changes</td>
	</tr>
ROW
    }

    # was all tickets filtered out?
    if ( $total_tickets == 0 ) {
      print "All tickets filtered\n" if ( $trace );
      $subject = "Bugzilla Team - No Changes Since $bzLastChangeTime";
      $content = <<HTML;
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style type="text/css">
.nobugs {
  color: grey;
}
    </style>
  </head>
  <body>
    <p class="nobugs" style="color: grey;">No bugs changed</p>
  <body>
</html>
HTML
    }
    else {
      print "Total tickets = $total_tickets\n" if ( $trace );
      $subject = "Bugzilla Team - ($total_tickets) Changes Since $bzLastChangeTime";
      $content = <<HTML;
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <style type="text/css">
.bugs_table {
  border: 1px;
  border-collapse: collapse;
}

.summary {
  display: block; 
  width: 400px; 
  white-space: nowrap; 
  text-overflow: ellipsis; 
  overflow: hidden; 
  max-width: 300px;
}

.change {
  white-space: nowrap;
}
    </style>
  <h1>$subject</h1>
  <table border="1" class="bugs_table" style="border: 1px; border-collapse: collapse;">
    <thead>
      <tr>
	<th>Bug</th>
	<th>Target Milestone</th>
	<th>Assigned To</th>
	<th>Status</th>
	<th>Summary</th>
	<th>Last Change</th>
	<th>Comments</th>
	<th>Changes</th>
      </tr>
    </thead>
    <tbody>
  $rows
    </tbody>
  </table>
  </body>
</html>
HTML
    }
  }

  print "Subject: $subject\n" if ( $trace );
  if ( ! $sendemail ) {
    print "Not sending email\n" if ( $trace );
  }
  else {
    my $from = 'eldon.olmstead@sigmastcomms.com';
    my $to = 'eldon.olmstead@sigmastcomms.com';

    print "Sending email to: $to\n" if ( $trace );
    my $body = Email::MIME->create(
      attributes => {
	content_type => "text/html",
	charset      => "US-ASCII",
	encoding     => "quoted-printable",
      },
      body_str => $content,
    );

    my $email          = Email::MIME->create(
      header_str => [
	From    => $from,
	To      => $to,
	Subject => $subject
      ],
      parts => [$body],
    );

    Email::Sender::Simple->send(
      $email,
      {
	from      => 'eldon.olmstead@sigmastcomms.com',
	transport => Email::Sender::Transport::SMTP->new(
	  {
	    host => $SMTP_HOSTNAME,
	    port => $SMTP_PORT,
	  }
	),
      }
    );
  }
};

if ($@) {
  use Data::Dumper;
  print STDERR "Error: " . Dumper($@);
}

