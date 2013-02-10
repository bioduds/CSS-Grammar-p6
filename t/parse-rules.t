#!/usr/bin/env perl6

use Test;
use CSS::Grammar::CSS1;
use CSS::Grammar::CSS21;
use CSS::Grammar::Actions;

my $css_actions = CSS::Grammar::Actions.new;

for (
    ws => {input => ' '},
    ws => {input => "/* comments\n1 */"},
    ws => {input => "<!-- comments\n2 -->"},
    ws => {input => "<!-- unterminated comment",
           warnings => ['unclosed comment at end of input'],
    },
    ws => {input => "/* unterminated\nstar\ncomment ... ",
           warnings => ['unclosed comment at end of input'],
    },
    name => {input => 'my-class', ast => 'my-class'},
    unicode => {input => '\\021',
                ast => '!',
    },
    string => {input => '"Hello World\\021"',
               ast => 'Hello World!',
               skip => False,
    },
    string => {input => '"Hello Black H',
               ast => 'Hello Black H',
               warnings => ['unterminated string'],
               skip => True,
    },
    num => {input => '2.52', ast => 2.52},
    id => {input => '#z0y\021', ast => 'z0y!'},
    percentage => {input => '50%', ast => 50, units => '%'},
    class => {input => '.zippy', ast => 'zippy'},
    length => {input => '2.52cm', ast => 2.52, units => 'cm'},
    url_spec => {input => '"http://www.bg.com/pinkish.gif"',
                 ast => 'http://www.bg.com/pinkish.gif',
    },
    url_spec => {input => 'http://www.bg.com/pinkish.gif',
                 ast => 'http://www.bg.com/pinkish.gif',
    },
    url => {input => 'url("http://www.bg.com/pinkish.gif")'},
    url => {input => 'URL(http://www.bg.com/pinkish.gif)'},
    url => {input => 'URL(http://www.bg.com/pinkish.gif',
            warnings => ["missing closing ')'"],
            skip => False,
    },
    url => {input => 'URL("http://www.bg.com/pinkish.gif',
            warnings => ["missing closing ')'", 'unterminated string'],
            skip => True,
    },
    rgb => {input => 'Rgb(10, 20, 30)',
            ast => {r => 10, g => 20, b => 30}},
    pseudo => {input => ':visited'},
    import => {input => "@import 'file:///etc/passwd';"},
    import => {input => "@IMPORT 'file:///etc/group';"},
    class => {input => '.class'},
    simple_selector => {input => 'BODY'},
    selector => {input => 'A:visited'},
    selector => {input => ':visited'},
    selector => {input => '.some_class'},
    selector => {input => '.some_class:link'},
    name => {input => 'some_class'},
    element_name => {input => 'BODY', class => '.some_class'},
    simple_selector => {input => 'BODY.some_class'},
    pseudo => {input => ':first-line'},
    selector => {input => 'BODY.some_class:active'},
    selector => {input => '#my-id :first-line'},
    selector => {input => 'A:first-letter'},
    selector => {input => 'A:Link IMG'},
    term => {input => '#eeeeee'},
    term => {input => 'rgb(17%, 33%, 70%)'},
    term => {input => 'rgb(17%, 33%, 70%',
             warnings => ["missing closing ')'"],
    },
    num => {input => '1'},
    num => {input => '.1'},
    num => {input => '1.9'},
    term => {input => '1cm'},
    term => {input => 'em'},
    term => {input => '1.1'},
    expr => {input => 'RGB(70,133,200 ), #fff'},
    expr => {input => '13mm EM'},
    expr => {input => '-1CM'},
    expr => {input => '2px solid blue'},
    declaration => {input => 'line-height: 1.1'},
    declaration => {input => 'line-height: 1.1px'},
    declaration => {input => 'margin: 1em'},
    declaration => {input => 'border: 2px solid blue'},
    ruleset => {input => 'H1 { color: blue; }',},
    ruleset => {input => 'A:link H1 { color: blue; }'},
    ruleset => {input => 'H1#abc { color: blue; }'},
    ruleset => {input => 'A.external:visited { color: blue; }'},
    dimension => {input => '70deg', ast => 70, units => 'deg'},
    ruleset => {input => 'H2 { color: green; rotation: 70deg; }',
                css1 => {
                    warnings => ['unknown dimensioned quantity: 70deg']
                }
    },
    TOP => {input => 'H1 { color: blue; }'},
    ruleset => {input => 'H1 { color }',
                warnings => ['skipping term: color '],
    },
    ruleset => {input => 'H1 { color; }',
                warnings => ['skipping term: color'],
    },
    ruleset => {input => 'H1 { color: }',
                warnings => ['incomplete declaration'],
    },
    ruleset => {input => 'H1 { : blue }',
                warnings => ['skipping term: : blue '],
    },
    ruleset => {input => 'H1 { color blue }',
                warnings => ['skipping term: color blue '],
    },

    # unclosed rulesets
    ruleset => {input => 'H2 { color: green; rotation: 70deg;',
                warnings => ["no closing '}'"],
                css1 => {
                    warnings => ["no closing '}'",
                                 'unknown dimensioned quantity: 70deg']
                }
    },

    ruleset => {input => 'H2 { color: green; rotation: }',
                warnings => "incomplete declaration",
    },

    ruleset => {input => 'H2 { test: "this is not closed',
                warnings => [
                    "no closing '}'",
                    'skipping term: "this is not closed',
                    'unterminated string',
                    ]
    },
    
    ) {

    my $rule = $_.key;
    my %test = $_.value;
    my $input = %test<input>;

    $css_actions.warnings = ();
    my $p1 = CSS::Grammar::CSS1.parse( $input, :rule($rule), :actions($css_actions));
    ok($p1, "css1: " ~ $rule ~ " parse: " ~ $input);

    my $css1 =  %test<css1> // {};
    my $css2 =  %test<css2> // {};

    my @css1_expected_warnings = %$css1<warnings> // %$css2<warnings> // %test<warnings> // ();
    my @css1_warnings = sort $css_actions.warnings;
    is(@css1_warnings, @css1_expected_warnings,
       @css1_expected_warnings ?? 'css1 warnings' !! 'css1 no warnings');

    if defined (my $ast1 = %$css1<ast> // %$css2<ast> // %test<ast>) {
        is($p1.ast, $ast1, 'css1 - ast')
            or diag $p1.ast.perl
    }

    if defined (my $units1 = %$css1<units> // %$css2<units> // %test<units>) {
        if ok($p1.ast.can('units'), "css1 does units") {
            is($p1.ast.units, $units1, 'css1 - units')
                or diag $p1.ast.units
            }
    }

    if defined (my $skip1 = %$css1<skip> // %$css2<skip> // %test<skip>) {
        is($p1.ast.skip, $skip1, 'css1 - skip is ' ~ $skip1);
    }

    $css_actions.warnings = ();
    my $p2 = CSS::Grammar::CSS21.parse( $input, :rule($rule), :actions($css_actions));
    ok($p2, "css2: " ~ $rule ~ " parse: " ~ $input);

    my @css2_expected_warnings = %$css2<warnings> // %test<warnings> // ();
    my @css2_warnings = sort $css_actions.warnings;
    is(@css2_warnings, @css2_expected_warnings,
       @css2_expected_warnings ?? 'css2 warnings' !! 'css2 no warnings');

    if defined (my $ast2 = %$css2<ast> // %test<ast>) {
        is($p2.ast, $ast2, 'css2 - ast')
            or diag $p1.ast.perl
    }

    if defined (my $units2 = %$css2<units> // %test<units>) {
        if ok($p2.ast.can('units'), "css2 does units") {
            is($p2.ast.units, $units2, 'css2 - units')
                or diag $p2.ast.units
            }
    }

    if defined (my $skip2 = %$css2<skip> // %test<skip>) {
        is($p2.ast.skip, $skip2, 'css2 - skip is ' ~ $skip2);
    }

}

done;