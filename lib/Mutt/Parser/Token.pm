package Mutt::Parser::Token;

use common::sense;

use Carp;
use Moose;
use Mutt::Parser::File;

use namespace::clean -except => [qw(meta)];

use constant EOL => "\n";
use constant EOF => "\0";

use constant NEW_LINE_READ => -1;
use constant NO_LINES_READ => -2;

has 'file' => (
	is => 'ro',
	isa => 'Mutt::Parser::File',
	required => 1,
);

has 'line_number' => (
	is => 'rw',
	isa => 'Int',
	default => sub {
		return shift->file->line_number;
	},
	init_arg => undef,
);

has 'position' => (
	is => 'rw',
	isa => 'Int',
	default => sub {
		return shift->file->current_position;
	},
	init_arg => undef,
);

has 'text' => (
	is => 'rw',
	isa => 'Str',
	default => sub {
		return shift->current_char;
	}
);

sub current_char {
	return shift->file->current_char;
}

sub next_char {
	return shift->file->next_char;
}

sub peek_char {
	return shift->file->peek_char;
}

__PACKAGE__->meta->make_immutable;

1;
