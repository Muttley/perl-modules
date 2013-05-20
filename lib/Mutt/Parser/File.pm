package Mutt::Parser::File;

use common::sense;

use Carp;
use Moose;

use namespace::clean -except => [qw(meta)];

has 'fh' => (
	is => 'ro',
	isa => 'FileHandle',
	lazy => 1,
	default => sub {
		my $self = shift;

		open (my $fh, '<:utf8', , $self->filename)
			|| croak "Unable to open file: $!";

		return $fh;
	}
);

has 'filename' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

sub slurp {
	my $self = shift;

	my $fh = $self->fh;

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
