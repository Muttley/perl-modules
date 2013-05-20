#!/usr/bin/env perl

use common::sense;

use lib '../lib';

use Data::Dump qw(pp);
use Mutt::Parser::File;

my $file = Mutt::Parser::File->new(filename => "C:\\Tools\\Bind\\etc\\named.conf");
say pp $file;
my $text = $file->slurp;
say pp $text;
