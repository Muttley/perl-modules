#!/usr/bin/env perl

use lib '../lib';

use common::sense;

use Data::Dump qw(pp);
use Mutt::Net::IPv4;

my $ip1 = Mutt::Net::IPv4->new->from_dotted ("255.255.255.255");
say pp $ip1;

my $int = $ip1->integer;

my $ip2 = Mutt::Net::IPv4->new->from_int ($int);
say pp $ip2;

eval {
	my $ip3 = Mutt::Net::IPv4->new->from_int ($int + 1);
	say pp $ip3;
};
warn $@ if $@;

eval {
	my $ip4 =Mutt::Net::IPv4->new->from_int (0);
	say pp $ip4;
};
warn $@ if $@;

eval {
	my $ip5 =Mutt::Net::IPv4->new->from_int (-120);
	say pp $ip5;
};
warn $@ if $@;
