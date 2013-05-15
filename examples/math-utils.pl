#!/usr/bin/env perl

use lib '../lib';

use common::sense;

use Mutt::Math::Utils qw(count_set_bits);

say "Counting set bits...";

for my $i (1 .. 255) {
	print "$i:" . count_set_bits ($i) . "  ";
	unless ($i % 10) {
		print "\n";
	}
}
