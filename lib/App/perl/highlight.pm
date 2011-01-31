use perl5i::2;

use Syntax::Highlight::Perl::Improved;

package App::perl::highlight;
# ABSTRACT: Syntax highlight your source code

sub new {
    my $class = shift;

    my $self = {};
    return bless $self, $class;
}

# perl -MText::Highlight -E '$h=Text::Highlight->new(ansi=>1); my $text=do{local $/; open my $fh, "<", $ARGV[0]; <$fh>}; say $h->highlight("Perl", $text);'
sub run {
    my $self = shift;
    my $opts = shift;
    my $args = shift;

    if ($opts->{version}) {
        require File::Basename;
        my $this = File::Basename::basename($0); # __PACKAGE__?
        my $this_ver = (defined __PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev');
        say "$this version $this_ver" and exit;
    }

    my $formatter = Syntax::Highlight::Perl::Improved->new();
    if ($opts->{html}) {
        my $color_table = {
            'Variable_Scalar'   => 'color:#080;',
            'Variable_Array'    => 'color:#f70;',
            'Variable_Hash'     => 'color:#80f;',
            'Variable_Typeglob' => 'color:#f03;',
            'Subroutine'        => 'color:#980;',
            'Quote'             => 'color:#00a;',
            'String'            => 'color:#00a;',
            'Comment_Normal'    => 'color:#069;font-style:italic;',
            'Comment_POD'       => 'color:#014;font-family:garamond,serif;font-size:11pt;',
            'Bareword'          => 'color:#3A3;',
            'Package'           => 'color:#900;',
            'Number'            => 'color:#f0f;',
            'Operator'          => 'color:#000;',
            'Symbol'            => 'color:#000;',
            'Keyword'           => 'color:#000;',
            'Builtin_Operator'  => 'color:#300;',
            'Builtin_Function'  => 'color:#001;',
            'Character'         => 'color:#800;',
            'Directive'         => 'color:#399;font-style:italic;',
            'Label'             => 'color:#939;font-style:italic;',
            'Line'              => 'color:#000;',
        };
        # HTML escapes.
        $formatter->define_substitution('<' => '&lt;',
                                        '>' => '&gt;',
                                        '&' => '&amp;');

        # install the formats set up above
        while ( my ( $type, $style ) = each %{$color_table} ) {
            $formatter->set_format( $type, [ qq{<span style="$style">}, qq{</span>} ] );
        }
    }
    else {
        require Term::ANSIColor;
        Carp::croak 'This requires Term::ANSIColor 3.0'
            unless $Term::ANSIColor::VERSION >= 3.00;

        my $color_table = { # Readability is not so good -- play with it more
            'Bareword'          => 'bright_green',
            'Builtin_Function'  => 'blue',
            'Builtin_Operator'  => 'bright_red',
            'Character'         => 'bold bright_red',
            'Comment_Normal'    => 'bright_blue',
            'Comment_POD'       => 'bright_black',
            'Directive'         => 'bold bright_black',
            'Keyword'           => 'white',
            'Label'             => 'bright_magenta',
            'Line'              => 'white',
            'Number'            => 'bright_red',
            'Operator'          => 'white',
            'Package'           => 'bold bright_red',
            'Quote'             => 'blue',
            'String'            => 'blue',
            'Subroutine'        => 'yellow',
            'Symbol'            => 'white',
            'Variable_Array'    => 'cyan',
            'Variable_Hash'     => 'magenta',
            'Variable_Scalar'   => 'green',
            'Variable_Typeglob' => 'bright_red',
        };

        # install the formats set up above
        while ( my ( $type, $style ) = each %{$color_table} ) {
            $formatter->set_format( $type, [ Term::ANSIColor::color($style), Term::ANSIColor::color('reset') ] );
        }
    }

    while (<STDIN>) {
        print $formatter->format_string;
    }
}
