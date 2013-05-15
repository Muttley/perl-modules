package Mutt::Platform;

use base 'Exporter';

use common::sense;

our @EXPORT_OK = qw(config_directory is_windows is_linux is_macos is_solaris);

sub config_directory {
	my $dir;

	given (lc ($^O)) {
		when ('mswin32') {
			$dir = $ENV{"APPDATA"};
		}
		when ('linux') {
			$dir = $ENV{"HOME"};
		}
		default {
			$dir = $ENV{"HOME"};
		}
	}

	return $dir;
}

sub is_linux {
	return lc ($^O) =~ m/linux/;
}

sub is_macos {
	return lc ($^O) =~ m/macos/;
}

sub is_solaris {
	return lc ($^O) =~ m/solaris/;
}

sub is_windows {
	return lc ($^O) =~ m/mswin32/;
}

1;
