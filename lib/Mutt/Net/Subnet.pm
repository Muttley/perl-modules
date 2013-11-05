package Mutt::Net::Subnet;

use common::sense;

use Carp;
use Moose;
use Mutt::Math qw(count_set_bits);
use Mutt::Net::IPv4;
use Scalar::Util qw(blessed looks_like_number);

use namespace::clean -except => [qw(meta)];

use constant VALID_CIDR => qr/^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\/([8-9]|[1-2][0-9]|3[0-2])$/;

has end_address => (
	is => 'ro',
	isa => 'Mutt::Net::IPv4',
	lazy => 1,
	default => sub {
		return Mutt::Net::IPv4->new;
	},
);

has start_address => (
	is => 'ro',
	isa => 'Mutt::Net::IPv4',
	lazy => 1,
	default => sub {
		return Mutt::Net::IPv4->new;
	},
);

has subnet_mask => (
	is => 'ro',
	isa => 'Mutt::Net::IPv4',
	lazy => 1,
	default => sub {
		return Mutt::Net::IPv4->new;
	},
);

sub _calculate_bitmask {
	my $self = shift;
	my $mask_length = shift;

	croak "Invalid subnet mask length: $mask_length"
		unless (looks_like_number ($mask_length) && $mask_length >= 8 && $mask_length <= 32);

	return (2 ** 32 - (2 ** (32 - $mask_length)));
}

sub _calculate_end_address {
	my $self = shift;

	my $start_int = $self->start_address->integer;
	my $bitmask = $self->subnet_mask->integer;

	my $end_int = (($start_int & $bitmask) + ~$bitmask) & 0xffffffff;

	$self->end_address->from_int ($end_int);
}

sub _validate_start_address {
	my $self = shift;

	# If the provided address is actually an address inside the subnet
	# demarcation as calculated from the given address/mask, then we ensure
	# that the start address is set to the real subnet start address.
	my $start_int = $self->start_address->integer;
	my $bitmask = $self->subnet_mask->integer;

	$self->start_address->from_int ($start_int & $bitmask);
}

sub from_cidr {
	my $self = shift;
	my $cidr = shift;

	croak "Invalid CIDR format: $cidr"
		unless ($cidr =~ VALID_CIDR);

	my ($dotted, $mask_length) = split (/\//, $cidr);

	$self->start_address->from_dotted ($dotted);

	my $bitmask = $self->_calculate_bitmask ($mask_length);
	$self->subnet_mask->from_int ($bitmask);

	$self->_validate_start_address;
	$self->_calculate_end_address;

	return $self;
}

sub from_dotted {
	my $self = shift;
	my $dotted_ipv4 = shift;
	my $dotted_mask = shift;

	$self->start_address->from_dotted ($dotted_ipv4);
	$self->subnet_mask  ->from_dotted ($dotted_mask);

	$self->_validate_start_address;
	$self->_calculate_end_address;

	return $self;
}

sub get_cidr {
	my $self = shift;

	return $self->start_address->dotted . '/' . $self->mask_length;
}

sub mask_length {
	return count_set_bits (shift->subnet_mask->integer);
}

sub split_subnet {
	my $self = shift;
	my $mask_length = shift;

	croak "New mask length must be larger than existing."
		unless ($mask_length > $self->mask_length);

	my @subnets;

	my $first_address = $self->start_address->dotted;
	my $last_address  = 0;

	while ($last_address < $self->end_address->integer) {
		my $subnet = Mutt::Net::Subnet->new->from_cidr ("$first_address/$mask_length");

		$last_address  = $subnet->end_address->integer;
		$first_address = Mutt::Net::IPv4->new->from_int ($last_address + 1)->dotted;

		push @subnets, $subnet;
	}

	return \@subnets;
}

sub subnet_overlaps {
	my $self = shift;
	my $subnet = shift;

	croak "Invalid subnet object."
		unless (blessed ($subnet) && $subnet->isa (__PACKAGE__));

	my $left_start = $self->start_address->integer;
	my $left_end   = $self->end_address  ->integer;

	my $right_start = $subnet->start_address->integer;
	my $right_end   = $subnet->end_address  ->integer;

	return ($left_start <= $right_end) && ($right_start <= $left_end);
}

__PACKAGE__->meta->make_immutable;

1;
