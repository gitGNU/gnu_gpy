#!/usr/local/bin/perl
# Copyright (C) 2013, 2014 Svetlana Tkachenko
#
#    This file is part of gpy.
#
#    gpy is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    gpy is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with gpy.  If not, see <http://www.gnu.org/licenses/>.

package Bot::BasicBot::Pluggable::Module::WikinewsSpam;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

use strict;
use warnings;
use MediaWiki::API;
use Data::Dumper;
use WWW::Shorten::TinyURL;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;
use DateTime::Format::Human::Duration;


# Settings. You can edit these.
my $s_chan = "#wikinews";
my %check_period = ( # both in seconds
'all' => 60*60*24,
'new' => 60*5,
);

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING

# Secondary variables.
my %check_next = ( # both in seconds
'all' => 0,
'new' => 0,
);

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'https://en.wikinews.org/w/api.php';
my $strp = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%dT%H:%M:%SZ',
    locale    => 'en_AU',
    time_zone => 'UTC',
);
my @known_pageids;
my $human_duration_parser = DateTime::Format::Human::Duration->new();
my $last_full_announce_ago = 0; # minutes

# Announce an article in channel
sub announce_page{
  my $self = shift;
  my $article_ref = shift;
  
  # Get page url by id
  my $info_ref = $mw->api ( {
    action      => 'query',
    prop        => 'info',
    inprop      => 'url',
    pageids     => $article_ref->{pageid},
  } ) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  my $url = WWW::Shorten::TinyURL::makeashorterlink($info_ref->{query}{pages}{$article_ref->{pageid}}{fullurl});
  $url =~ s/^http/https/;
  
  # Human readable time ago
  my $time_now = DateTime->now;
  my $time_published = $strp->parse_datetime($article_ref->{timestamp});
  my $time_ago = $human_duration_parser->format_duration_between($time_now,$time_published);

  # Title
  my $title = $article_ref->{title};
  
  my $message = "$url submitted for review *$time_ago* ago";
  
  # Under review or not?
  my $cat_info_ref = $mw->api ( {
    action      => 'query',
    prop        => 'categories',
    cllimit     => 10,
    clcategories=> 'Category:Under review',
    pageids     => $article_ref->{pageid},
  } ) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  if (exists $$cat_info_ref{query}{pages}{$article_ref->{pageid}}{categories}){
    $message .= " - *under review*";
  }
  
  # Add title and say in channel
  $message .= " - $title";
  $self->say(channel => $s_chan, body => $message);
  
  if (!($article_ref->{pageid} ~~  @known_pageids)){
    push @known_pageids, $article_ref->{pageid};
  }

}

sub get_queue{
  my $articles_ref = $mw->list ( {
    action      => 'query',
    list        => 'categorymembers',
    cmtitle     => 'Category:Review',
    cmprop      => 'ids|title|timestamp',
    cmnamespace => 0,
    cmlimit     => 10,
    cmsort      => 'timestamp',
  } ) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
  return $articles_ref;
}

sub tick{
  my $self = shift;
  my @new_articles;
  
  
   
  # Announce all
  if ($check_next{'all'} == 0){
    my $articles_ref = get_queue();
    my $message = (scalar $articles_ref == 0) ? "Empty review queue" : "Review queue:";
    @new_articles = @{$articles_ref};
    $self->say(channel => $s_chan,
               body    => $message,
    );
  }
  
  # Announce recent
  if ($check_next{'new'} == 0){
    my $articles_ref = get_queue();
    @new_articles 
     = grep {!($_->{pageid} ~~ @known_pageids)} @{$articles_ref};
  }
  
  for my $article (@new_articles)  {$self->announce_page($article);}
  
  #$self->say(channel=>$s_chan,body=>"First known pageid: $known_pageids[0]");
  
  # Increment checked_last times
  foreach(keys %check_next){
    $check_next{$_} 
      = $check_next{$_} <= 0
        ? $check_period{$_}
        : $check_next{$_} - 5;
  }
}


sub help{
return "Wikinews Review queue spam module.";
}

1;

#_ _END_ _

