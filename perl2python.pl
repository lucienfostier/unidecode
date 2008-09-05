use Getopt::Long;

my $input = ".";
my $output = ".";

$result = GetOptions("input=s" => \$input,
		     "output=s" => \$output);

sub python_escape {
	my $x = shift;

	return '' unless defined($x);

	$x =~ s/\\/\\\\/gs;
	$x =~ s/'/\\'/gs;
	$x =~ s/([\x00-\x1f])/sprintf("\\x%02x", ord($1))/ges;

	return $x;
}

push(@INC, $input);

my $n;
for($n = 0; $n < 256; $n++) {

	eval( sprintf("require x%02x;\n", $n) );

	next unless( $#{$Text::Unidecode::Char[$n]} >= 0 );

	open(PYTHON, sprintf(">%s/x%02x.py", $output, $n));
	print PYTHON "data = (";

	my $first = 1;
	for my $t (@{$Text::Unidecode::Char[$n]}) {
		if( $first ) {
			$first = 0;
		} else {
			print PYTHON ", ";
		}
		print PYTHON "'", &python_escape($t), "'";
	}

	print PYTHON ")\n";
	close(PYTHON)
}
