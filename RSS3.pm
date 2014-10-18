package Bot::BasicBot::Pluggable::Module::RSS3;

use warnings;
use strict;
use AnyEvent::Feed;
use Data::Dumper;
use DateTime::Format::ISO8601;
use DateTime::Format::Human::Duration;
use Encode;
use File::Spec;
use HTML::Entities;
use POE;
# use POE::Component::RSSAggregator;
# use AnyEvent::Feed;
# use Digest::MD5 qw(md5_hex);
use String::Format;
use WWW::Shorten::TinyURL;

use base qw(Bot::BasicBot::Pluggable::Module);

our $VERSION = '0.01';

my $iso8601 = DateTime::Format::ISO8601->new;
my $human_duration_parser = DateTime::Format::Human::Duration->new();

sub init {
    my $self = shift;
    
    # Read in the feeds
    $self->{feeds} = $self->get('feeds');
    warn "---";
    warn Dumper $self->{feeds};
    warn "---";

    # Set up listeners for the feeds
    $self->{reading} = {};
    for my $feed_url (keys %{$self->{feeds}}) {
	$self->start_reading($feed_url);
    }
}

sub start_reading{
    my $self = shift;
    my $feed_url = shift;
    # Check whether we are already reading the feed
    if($self->{reading}->{$feed_url}) {return;}
    $self->{reading}->{$feed_url}=1;

    # Set up variables
    my @feedreaders = ();
    my $fetchinterval = 600;

    # Add listener
    warn "adding listener for $feed_url";
    push @feedreaders, AnyEvent::Feed->new (
	url => $feed_url,
	interval => $fetchinterval,
	on_fetch => sub {
	    my ($feed_reader, $new_entries, $feed, $error) = @_;
	    warn "fetching...";
	    if (defined $error) {
		warn "ERROR: $error\n";
		return;
	    }

	    # Process new entries
	    for (@$new_entries) {
		warn "processing new entries for $feed_url";
		my ($hash, $entry) = @$_;
		my $title = $entry->title;
		my $url = $entry->link;
		# Here the original checked for some usedtitles and usedlinks. I'm ignoring this.
		# Shorten the URL
		warn "got url $url";
		my $shortened = makeashorterlink($url);
		warn "shortened to $shortened ******* ";
		# Get the date
		my $dt_c = $entry->issued;
		my $dt_m = $entry->modified;
		my $date = undef;
		if ($dt_m) {$date = $dt_m->iso8601();}
		elsif ($dt_c) {$date = $dt_c->iso8601();}
		my $agoDate;
		warn "$date -- ... \r\n";
#		if($date){
#		$agoDate = $human_duration_parser->format_duration_between(DateTime->now, $iso8601->parse_datetime( $date ), {'locale' => });
#		}

		#GET RID OF &amp; etc
		warn "the title is $title";
		decode_entities($title);
		warn "the decoded title is $title";

		#NORMALIZE WHITE SPACE
		for ($title) {
		    s/\s+/ /g;
		    s/^\s+//;
		}
		utf8::decode $title;
		warn "normalised white space";
#		warn $iso8601->parse_datetime( $date );
#		warn $self->{feeds}->{$feed_url}->{ts};
#		warn $self->{feeds}->{$feed_url}->{ts} < $iso8601->parse_datetime( $date );
		
		# Check the time
		if($date and (!$self->{feeds}->{$feed_url}->{ts} or $self->{feeds}->{$feed_url}->{ts} lt $date )){
		    warn "1";
		    $self->{feeds}->{$feed_url}->{ts} = $date;
		    warn "2";
		    $self->set('feeds', $self->{feeds});
		    warn "3";

		    # Say the news to IRC
		    for my $chan (keys %{$self->{feeds}->{$feed_url}->{'channels'}}){
			warn "im doing this for channel $chan";
			my $locale =  $self->{feeds}->{$feed_url}->{channels}->{$chan};
			$agoDate = $human_duration_parser->format_duration_between(DateTime->now, $iso8601->parse_datetime( $date ), 'locale' => $locale);
			utf8::decode $agoDate;
			my $name = $self->{feeds}->{$feed_url}->{'name'};
			$self->tell($chan, "$shortened $name $title - $agoDate");
			warn "told $chan about ``$shortened $name $title - $agoDate``";
		    }
		}

	    }
	}
	);
}

sub told {
    my ($self,$message) = @_;
    # Only act if we are addressed
    if ($message->{address}) {
	my $body    = $message->{body};
	my $channel = $message->{channel};

	if ($channel eq 'msg') {
	    $channel = $message->{who}
	}

	my @cmds = split(' ',$body);
	if ($cmds[0] eq 'rss') {
	    my %actions = (
		add    => sub { return $self->add_feed( $channel, @_ ) },
		list   => sub { return $self->list_feeds($channel); },
		remove => sub { return $self->remove_feed( $channel, @_ ) },
		);
	    if (!defined($actions{$cmds[1]})) {
		return $self->help();
	    }
	    my $reply = $actions{$cmds[1]}->(@cmds[2,-1]) ;
	    return $reply;
	}
    }
}

sub add_feed {
    my ($self,$channel,$msg) = @_;
    warn "``$msg''";
    my ($locale,$name,$uri) = (split /\*/, $msg);
    warn "$name ... $uri";
    if ($uri and ! $self->{feeds}->{$uri}->{$channel}) {
	$self->{feeds}->{$uri}->{'channels'}->{$channel} = $locale;
	$self->{feeds}->{$uri}->{'name'}=$name;
	$self->set('feeds', $self->{feeds});
	$self->start_reading($uri);
	return "Ok.";
    }
    return "Did you forget the uri or was this channel already added?";
}

sub remove_feed {
    my ($self,$channel,$uri) = @_;
    if ( $self->{feeds}->{$uri}->{'channels'}->{$channel} ) {
	delete $self->{feeds}->{$uri}->{'channels'}->{$channel};
	warn "deleted the channel";
	if (keys %{$self->{feeds}->{$uri}->{'channels'}} == 0) {
	    warn "deleted the URL from all channels";
	    delete $self->{feeds}->{$uri};
	}
	$self->set('feeds', $self->{feeds});
#	$self->set('feeds', keys %{$self->{feeds}});
#	## We remove the feed from poco if it's the last
#	if (!keys %{$self->{feeds}->{$uri}}) {
#	    my $name = md5_hex($uri);
#	    POE::Kernel->call( 'rssagg', 'remove_feed', $name );
#	    delete $self->{feeds}->{$uri};
#	}
	return "Ok.";
    } else {
	return "Mhh, i don't even know about that url";
    }
}

sub list_feeds {
    my ($self,$channel) = @_;
    my $reply;
    for my $uri (keys %{$self->{feeds}}) {
	if ($self->{feeds}->{$uri}->{'channels'}->{$channel} ) {
	    my $name = $self->{feeds}->{$uri}->{'name'};
	    $reply .= "$name - $uri\n" ;
	}
    }
    if ($reply) {
	return $reply;
    } else {
	return 'Nobody added rss feeds to me yet.';
    }
}

sub help {
    return "rss [add uri|remove|list]";
}

1; # End of Bot::BasicBot::Pluggable::Module::RSS

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::RSS - RSS feed aggregator for your bot

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

    !load RSS
    rss add http://search.cpan.org/uploads.rdf
    rss list
    rss remove http://search.cpan.org/uploads.rdf

=head1 DESCRIPTION

This module enables your bot to monitor various RSS feeds for new
headlines and post these to your channels. Every channel has it's
own list of rss feeds, but in case two channels subscribed to the
same rss feeds, it's only checked once and the bot posts changes
to both channels.  Although this module does not block your bot due
the non-blocking interface of L<POE::Component::RSSAggregator>,
adding a lot of fast changing rss feeds will result in sluggish
behaviour.

=head1 VARIABLES

=head2 tmpdir

Directory to keep a cached feed (using Storable) to keep persistance
between instances. This defaults to the first writable directory
from a list of possible temporary directories as provided by
L<File::Spec>.

=head2 debug

Turn debuging on console on. Off by default

=head2 user_init_headlines_seen

Mark all headlines as seen from the intial fetch, and only report
new headlines that appear from that point forward. This defaults
to true.

Changing this variable will not modify any existing feeds.

=head2 user_delay

Number of seconds between updates (defaults to 600).

Changing this variable will not modify any existing feeds.

=head2 user_format

The string defined by user_format will be formated in a printf like
fashion. The actually formatting is done by L<String::Format>. The
formats 'n', 't', and '%' are defined to be a newline, tab, and
'%'. The default format is 'RSS: %h <%u>'.

=over 4

=item %h

The rss headline/title.

=item %u

The rss link/url. URI->canonical is called to attempt to normalize the URL

=item %d

The description of the RSS headline.

=back

=head1 LIMITATIONS

In the moment this module is only able to parse rss feeds and will
throw a lot of warnings at you when you try to add an atom feed as
the underlying wokrhorse of L<POE::Component::RSSAggregator> just
support this one format.

=head1 TODO

The testuite is almost not existing as i'm not yet sure how to
reliable test POE code. I'll have to look into that.

=head1 AUTHOR

Mario Domgoergen, C<< <dom at math.uni-bonn.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bot-basicbot-pluggable-module-rss at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bot-BasicBot-Pluggable-Module-RSS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bot::BasicBot::Pluggable::Module::RSS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bot-BasicBot-Pluggable-Module-RSS>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bot-BasicBot-Pluggable-Module-RSS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bot-BasicBot-Pluggable-Module-RSS>

=item * Search CPAN

L<http://search.cpan.org/dist/Bot-BasicBot-Pluggable-Module-RSS>

=back


=head1 SEE ALSO

L<Bot::BasicBot::Pluggable>, L<POE::Component::RSSAggregator>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Mario Domgoergen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


