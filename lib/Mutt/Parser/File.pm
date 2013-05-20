package Mutt::Parser::File;

use common::sense;

use Carp;
use Moose;

use namespace::clean -except => [qw(meta)];

has '_fh' => (
	is => 'ro',
	isa => 'FileHandle',
	lazy => 1,
	default => sub {
		my $self = shift;

		open (my $fh, '<:utf8', , $self->filename)
			|| croak "Unable to open file: $!";

		return $fh;
	},
	init_arg => undef,
);

has 'filename' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

sub slurp {
	my $self = shift;

	my $fh = $self->_fh;

	my $contents;
	eval {
		local $/ = undef;
		$contents = <$fh>;
	};
	croak $@ if $@;

	return $contents;
}

__PACKAGE__->meta->make_immutable;

1;
