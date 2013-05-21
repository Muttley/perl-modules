package Mutt::Parser::Scanner;

use common::sense;

use Carp;
use Moose;
use Mutt::Parser::File;

use namespace::clean -except => [qw(meta)];

use constant EOL => "\n";
use constant EOF => "\0";

use constant NEW_LINE_READ => -1;
use constant NO_LINES_READ => -2;

has '_file' => (
	is => 'ro',
	isa => 'Mutt::Parser::File',
	lazy => 1,
	default => sub {
		return Mutt::Parser::File->new (filename => shift->filename);
	},
	init_arg => undef,
);

has 'current_token' => (
	is => 'rw',
	isa => 'Mutt::Parser::Token',
	lazy => 1,
);

has 'filename' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

sub at_end_of_file {
	return shift->_file->at_end_of_file;
}

sub at_end_of_line {
	return shift->_file->at_end_of_line;
}

sub current_char {
	return shift->_file->current_char;
}

sub extract_token {
	die "This method must be overridden by a subclass of __PACKAGE__";
}

sub next_char {
	return shift->_file->next_char;
}

sub next_token {
	my $self = shift;

	$self->current_token ($self->extract_token);

	return $self->current_token;
}

sub skip_line {
	shift->_file->skip_line;
}

__PACKAGE__->meta->make_immutable;

1;
