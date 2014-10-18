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


package Bot::BasicBot::Pluggable::Module::WikiLinker;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

use strict;
use warnings;
use MediaWiki::API;
use Data::Dumper;
use WikiLinkParser;

my %channels_urls = (
    '#wikinews-en'   => 'https://en.wikinews.org/w/api.php',
    '#wikinews-ru'   => 'https://ru.wikinews.org/w/api.php',
    '#wikinews'      => 'https://en.wikinews.org/w/api.php',
    '#wikipedia-ru'  => 'https://ru.wikipedia.org/w/api.php',
    '#wikipedia-ru2'  => 'https://ru.wikipedia.org/w/api.php',
    '#wikinews-ko'  =>  'https://ko.wikinews.org/w/api.php',
);
my %mw;

# Secondary variables.
for my $channel_name (keys %channels_urls) {
    $mw{$channel_name} = MediaWiki::API->new();
    $mw{$channel_name}->{config}->{api_url} = $channels_urls{$channel_name};
}

sub told{
    shift->process_message(@_);
}

sub emoted {
    shift->process_message(@_);
}

sub process_message{
    my ($self, $msg, $pri) = @_;
    my $body = $msg->{body};
    my $who  = $msg->{who};
    my $channel  = $msg->{'channel'};
    if (!grep { $_ eq $channel } keys %channels_urls){
        return;
    }
    if ($body =~ m{\[\[(.*?)\]\]} or $body =~ m{\{\{(.*?)\}\}}g){
        return join " ", @{WikiLinkParser->get_urls_by_text($body, $mw{$channel})};
    }
    return;
}

sub help{
return "parser for [[*]] in messages";
}

1;

#_ _END_ _

