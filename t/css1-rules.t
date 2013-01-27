#!/usr/bin/env perl6

use Test;
use CSS::Grammar::CSS1;

# whitespace
for (' ', '  ', "\t", "\r\n", ' /* hi */ ', '/*there*/', '<!-- zzz -->') {
    ok($_ ~~ /^<CSS::Grammar::CSS1::ws>$/, "ws: $_");
}

# unicode
for ("\\f", "\\012f", "\\012A") {
    ok($_ ~~ /^<CSS::Grammar::CSS1::unicode>$/, "unicode: $_");
}

# latin1
for ('¡', "\o250", 'ÿ') {
    ok($_ ~~ /^<CSS::Grammar::CSS1::latin1>$/, "latin1: $_");
}

for (chr(0), ' ', '~') {
    ok($_ !~~ /^<CSS::Grammar::CSS1::latin1>$/, "not latin1: $_");
} 

for ('Appl8s', 'oranges', 'k1w1-fru1t') {
    ok($_ ~~ /^<CSS::Grammar::CSS1::ident>$/, "ident: $_");
}

for ('8', '-i') {
    ok($_ !~~ /^<CSS::Grammar::CSS1::ident>$/, "not ident: $_");
}

for (q{"Hello"}, q{'world'}, q{''}, q{""}, q{"'"}, q{'"'}, q{"grocer's"}) {
    ok($_ ~~ /^<CSS::Grammar::CSS1::string>$/, "string: $_");
}

for (q{"Hello}, q{world'}, q{'''}, q{"}, q{'grocer's'},) {
    ok($_ !~~ /^<CSS::Grammar::CSS1::string>$/, "not string: $_");
}

for (percentage => '50%',
     id => '#zzz',
     class => '.zippy',
     num => '2.52',
     length => '2.52cm',
     pseudo_class => ':visited',
     url => 'url("http://www.bg.com/pinkish.gif")',
     import => "@import 'file:///etc/passwd';",
     import => "@IMPORT 'file:///etc/group';",
     quotable_char => '(',
     quotable_char => ' ',
     unquoted_escape_seq => '\(',
     unquoted_escape_seq => '\\',
     unquoted_string => 'perl\(6\)\ rocks',
     url => 'url(http://www.bg.com/pinkish.gif)',
     class => '.class',
     selector => 'BODY',
     selector => 'A:visited',
     selector => ':visited',
     selector => '.some_class',
     selector => '.some_class:link',
     name => 'some_class',
     element_name => 'BODY', class => '.some_class',
     simple_selector => 'BODY.some_class',
     pseudo_element => ':first-line',
     selector => 'BODY.some_class:active',
     selector => '#my-id :first-line',
     selector => 'A:first-letter',
     selector => 'A:Link IMG',
     hexcolor => '#eeeeee',
     rgb => 'rgb(17%, 33%, 70%)',
     num => '1',
     num => '.1',
     num => '1.9',
     term => '1cm',
     term => 'em',
     term => '1.1',
     expr => 'RGB (70,133,200 ), #fff',
     expr => '13mm EM',
     expr => '-1CM',
     expr => '2px solid blue',
     declaration => 'line-height: 1.1',
     declaration => 'line-height: 1.1px',
     declaration => 'margin: 1em',
     declaration => 'border: 2px solid blue',
     ruleset => 'H1 { color: blue; }',
     ruleset => 'A:link H1 { color: blue; }',
     dimension => '70deg',  # css3 qty; uknown to css1
     ruleset => 'H2 { color: green; rotation: 70deg; }';
    ) {

    my $p = CSS::Grammar::CSS1.parse( $_.value, :rule($_.key));
    ok($p, $_.key ~ " parse: " ~ $_.value);
}

done;
