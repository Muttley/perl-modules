#!/usr/bin/env perl

use common::sense;

use lib '../lib';

use Data::Dump qw(pp);
use Mutt::Parser::File;

my $file = Mutt::Parser::File->new(filename => "./file.pl");

say pp $file;
my $text = $file->slurp;
say pp $text;
say pp $file;

exit;
for my $i (1 .. 30) {
	say "next_char: " . pp $file->next_char;
	say "peek_char: " . pp $file->peek_char;
	#say pp $file;
}
