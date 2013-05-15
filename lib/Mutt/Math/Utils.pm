package Mutt::Math::Utils;

use base 'Exporter';

use common::sense;

use Carp;
use Scalar::Util qw(looks_like_number);

our @EXPORT_OK = qw(count_set_bits);

sub count_set_bits ($) {
	my $i = shift;

	croak "NaN!" unless (looks_like_number ($i));

	my $c;
	for ($c = 0; $i; $c++) {
		$i &= $i - 1;
	}

	return $c;
}

1;
