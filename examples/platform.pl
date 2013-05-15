#!/usr/bin/env perl

use lib '../lib';

use common::sense;

use Mutt::Platform qw(config_directory is_linux is_macos is_solaris is_windows);

print "Platform: ";

if (is_linux) {
	say "Linux";
}
elsif (is_macos) {
	say "MacOS";
}
elsif (is_solaris) {
	say "Solaris";
}
elsif (is_windows) {
	say "Windows";
}

say "Config directory: " . config_directory;
