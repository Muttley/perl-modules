package Mutt::Parser::File;

use common::sense;

use Carp;
use Moose;

use namespace::clean -except => [qw(meta)];

use constant EOL => "\n";
use constant EOF => "\0";

use constant NEW_LINE_READ => -1;
use constant NO_LINES_READ => -2;

has '_chars' => (
	is => 'rw',
	isa => 'ArrayRef[Str]',
	lazy => 1,
	default => undef,
	init_arg => undef,
);

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

has '_line' => (
	is => 'rw',
	isa => 'Str',
	lazy => 1,
	default => undef,
	init_arg => undef,
);

has 'current_position' => (
	is => 'rw',
	isa => 'Int',
	lazy => 1,
	default => NO_LINES_READ,
	init_arg => undef,
);

has 'filename' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

has 'line_number' => (
	is => 'rw',
	isa => 'Int',
	lazy => 1,
	default => 0,
	init_arg => undef,
);

sub at_end_of_file {
	my $self = shift;

	if ($self->current_position == NO_LINES_READ) {
		$self->read_line;
	}

	return $self->_line ? 0 : 1;
}

sub at_end_of_line {
	my $self = shift;

	return ($self->_line != undef) && ($self->current_position == $self->line_length);
}

sub current_char {
	my $self = shift;

	if ($self->current_position == NO_LINES_READ) {
		$self->read_line;
	}

	unless ($self->_line) {
		return EOF;
	}

	my $current_position = $self->current_position;
	if ($current_position == NEW_LINE_READ || $current_position == $self->line_length) {
		return EOL;
	}

	if ($current_position > $self->line_length) {
		$self->read_line;
		return $self->next_char;
	}

	return $self->_chars->[$self->current_position];
}

sub line_length {
	return length (shift->_line) || 0;
}

sub next_char {
	my $self = shift;

	if ($self->current_position == NO_LINES_READ) {
		$self->read_line;
	}

	my $current_position = $self->current_position;
	$self->current_position (++$current_position);

	return $self->current_char;
}

sub peek_char {
	my $self = shift;

	if ($self->current_position == NO_LINES_READ) {
		$self->read_line;
	}

	unless ($self->_line) {
		return EOF;
	}

	my $next_position = $self->current_position;
	$next_position++;

	return ($next_position < $self->line_length) ? $self->_chars->[$next_position] : EOL;
}

sub read_line {
	my $self = shift;

	my $fh   = $self->_fh;
	my $line = <$fh>;

	$self->_line ($line);

	my @chars = split (//, $line);
	$self->_chars (\@chars);

	$self->current_position (NEW_LINE_READ);

	return unless ($self->_line);

	my $line_number = $self->line_number;
	$self->line_number (++$line_number);

	#say $self->line_number . ": " . $self->_line;
}

sub skip_line {
	my $self = shift;

	if ($self->_line) {
		my $line_length = $self->line_length;
		$self->current_position (++$line_length);
	}
}

sub slurp {
	my $self = shift;

	my $contents;
	while (!$self->at_end_of_file) {
		$contents .= $self->_line;
		$self->read_line;
	}

	return $contents;
}

__PACKAGE__->meta->make_immutable;

1;
