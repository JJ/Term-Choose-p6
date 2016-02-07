use v6;
unit class Term::Choose::LineFold;

my $VERSION = '0.006';

use Terminal::WCWidth;



sub cut_to_printwidth ( Str $str, Int $avail_w, Int $rest = 0 ) is export( :printwidth_func ) { #
    #my $str_w = wcswidth( $str );
    #die "String with control charakter!" if $str_w == -1;
    #if $str_w <= $avail_w {
    if wcswidth( $str ) <= $avail_w {
        return $str if ! $rest;
        return $str, '';
    }
    my $left = $str.substr( 0, $avail_w );
    my $left_w = wcswidth( $left );
    if $left_w == $avail_w {
        return $left if ! $rest;
        return $left, $str.substr( $avail_w );
    }
    if $avail_w < 2 {
        die "Terminal-width less than charakter-width."; #
    }
    my ( Int $nr_chars, Int $adjust );
    if $left_w > $avail_w {
        $nr_chars = $avail_w div 2;
        $adjust = ( $nr_chars + 1 ) div 2;
        #$nr_chars = ( $avail_w / 4 * 3 ).Int;
        #$adjust = ( $avail_w + 7 ) div 8;
    }
    elsif $left_w < $avail_w {
        $nr_chars = $avail_w + ( $str.chars - $avail_w ) div 2;
        $adjust = ( $str.chars - $nr_chars ) div 2;
    }

    loop {
        $left = $str.substr( 0, $nr_chars );
        $left_w = wcswidth( $left );
        if $left_w + 1 == $avail_w {
            my Int $len_next_char = wcswidth( $str.substr( $nr_chars, 1 ) );
            if $len_next_char == 1 {
                return $str.substr( 0, $nr_chars + 1 ) if ! $rest;
                return $str.substr( 0, $nr_chars + 1 ), $str.substr( $nr_chars + 1 );
            }
            elsif $len_next_char == 2 {
                return $left ~ ' ' if ! $rest;
                return $left ~ ' ' , $str.substr( $nr_chars );
            }
        }
        if $left_w > $avail_w {
            $nr_chars = $nr_chars - $adjust;
        }
        elsif $left_w < $avail_w {
            $nr_chars = $nr_chars + $adjust;
        }
        else {
            return $left if ! $rest;
            return $left, $str.substr( $nr_chars );
        }
        $adjust = ( $adjust + 1 ) div 2;
    }
}


sub line_fold ( Str $str, Int $avail_w, Str $init_tab is copy, Str $subseq_tab is copy ) returns Str is export( :printwidth_func ) { #
    for $init_tab, $subseq_tab {
        if $_ {
            $_.=subst( /\s/,  ' ', :g );
            $_.=subst( /<:C>/, '', :g );
            if $_.chars > $avail_w / 4 {
                $_ = cut_to_printwidth( $_, $avail_w div 2 );
            }
        }
        else {
            $_ = '';
        }
    }
    my $string = $str.subst( /<:Other-:Line_Feed>/, '' , :g );
    if $string !~~ /\n/ && wcswidth( $init_tab ~ $string ) <= $avail_w {
        return $init_tab ~ $string;
    }
    my Str @para;

    ROW: for $string.lines -> $row {
        my Str @lines;
        my Str $pr_line = $init_tab;
        my Str @words = $row.words;

        WORD: for 0 .. @words.end -> $i {
            my $tab = $i == 0 ?? $init_tab !! $subseq_tab;
            if wcswidth( $tab ~ @words[$i] ) > $avail_w {
                if $i != 0 {
                    @lines.push( $pr_line );
                }
                my ( Str $substr_a_line, Str $rest ) = cut_to_printwidth( $tab ~ @words[$i], $avail_w, 1 );
                @lines.push( $substr_a_line );
                loop {
                    ( $substr_a_line, $rest ) = cut_to_printwidth( $subseq_tab ~ $rest, $avail_w, 1 );
                    if ! $rest.chars {
                        $pr_line = $substr_a_line;
                        if wcswidth( $pr_line ~ ' ' ) < $avail_w {
                            $pr_line ~= ' ';
                        }
                        @lines.push( $pr_line ) if $i == @words.end;
                        next WORD;
                    }
                    @lines.push( $substr_a_line );
                }
            }
            else {
                if wcswidth( $pr_line ~ @words[$i] ) <= $avail_w {
                    $pr_line ~= @words[$i];
                    if wcswidth( $pr_line ~ ' ' ) < $avail_w {
                        $pr_line ~= ' ';
                    }
                    else {
                        @lines.push( $pr_line );
                        $pr_line = $subseq_tab;
                    }
                }
                else {
                    @lines.push( $pr_line );
                    $pr_line = $subseq_tab ~ @words[$i];
                }
                if $i == @words.end {
                    @lines.push( $pr_line );
                }
            }
        }
        @para.push( @lines.join( "\n" ) );
    }
    return @para.join( "\n" ) ~ ( $str.ends-with( "\n" ) ?? "\n" !! '' );
}


sub print_columns ( Str $str ) returns Int is export( :printwidth_func ) {
    wcswidth( $str );
}

