package Mutt::Net::IPv4;

use common::sense;

use Carp;
use Moose;
use Scalar::Util qw(looks_like_number);

use namespace::clean -except => [qw(meta)];

use constant VALID_DOTTED_IPV4 => qr/^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/;

has dotted => (
	is => 'rw',
	isa => 'Str',
);

has integer => (
	is => 'rw',
	isa => 'Int',
);

sub from_dotted {
	my $self   = shift;
	my $dotted = shift;

	croak "Invalid dotted IPv4 address: $dotted"
		unless ($dotted =~ VALID_DOTTED_IPV4);

	my @octets = split (/\./, $dotted);

	my $integer = $octets[0];
	$integer = ($integer << 8) + $octets[1];
	$integer = ($integer << 8) + $octets[2];
	$integer = ($integer << 8) + $octets[3];

	$self->dotted ($dotted);
	$self->integer ($integer);

	return $self;
}

sub from_int {
	my $self    = shift;
	my $integer = shift;

	croak "Invalid 32-bit integer value: $integer"
		unless (looks_like_number ($integer) && $integer >= 0 && ($integer <= 2**32-1));

	my @octets;
	$octets[3] = $integer & 0xff;
	$octets[2] = ($integer >>  8) & 0xff;
	$octets[1] = ($integer >> 16) & 0xff;
	$octets[0] = ($integer >> 24) & 0xff;

	my $dotted = join ('.', @octets);

	$self->dotted ($dotted);
	$self->integer ($integer);

	return $self;
}

__PACKAGE__->meta->make_immutable;

1;
