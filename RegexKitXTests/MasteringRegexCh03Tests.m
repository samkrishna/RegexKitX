//
//  MasteringRegexCh03Tests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 2/11/26.
 Copyright © 2026 Sam Krishna. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Sam Krishna nor the names of RegexKitX's contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Tests derived from "Mastering Regular Expressions, 3rd Edition" by Jeffrey E.F. Friedl
// Chapter 3: Overview of Regular Expression Features and Flavors (pp.83-142)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh03Tests : XCTestCase
@end

@implementation MasteringRegexCh03Tests

#pragma mark - Unicode Letter Category Properties

- (void)testUnicodeLetterCategoryProperties
{
    // MRE3 pp.119-121: Unicode general categories for letters
    // \p{Lu} = uppercase, \p{Ll} = lowercase, \p{Lt} = titlecase, \p{Lo} = other letter

    // Uppercase letters
    XCTAssertTrue([@"A" isMatchedByRegex:@"\\p{Lu}"]);
    XCTAssertFalse([@"a" isMatchedByRegex:@"^\\p{Lu}$"]);

    // Lowercase letters
    XCTAssertTrue([@"a" isMatchedByRegex:@"\\p{Ll}"]);
    XCTAssertFalse([@"A" isMatchedByRegex:@"^\\p{Ll}$"]);

    // \p{L} matches any letter
    NSString *text = @"Caf\u00E9 na\u00EFve";
    NSArray<NSString *> *letters = [text substringsMatchedByRegex:@"\\p{L}+"];
    XCTAssertEqual(letters.count, 2);
    XCTAssertEqualObjects(letters[0], @"Caf\u00E9");
    XCTAssertEqualObjects(letters[1], @"na\u00EFve");

    // \p{Lo} matches CJK ideographs (they have no case)
    XCTAssertTrue([@"\u4E16" isMatchedByRegex:@"\\p{Lo}"]); // 世
}

#pragma mark - Unicode Number Category Properties

- (void)testUnicodeNumberCategoryProperties
{
    // MRE3 p.120: \p{Nd} = decimal digit, \p{Nl} = letter number, \p{No} = other number
    XCTAssertTrue([@"5" isMatchedByRegex:@"\\p{Nd}"]);

    // Arabic-Indic digits are \p{Nd}
    XCTAssertTrue([@"\u0664" isMatchedByRegex:@"\\p{Nd}"]); // ٤ (Arabic-Indic 4)

    // Roman numeral characters are \p{Nl}
    XCTAssertTrue([@"\u2164" isMatchedByRegex:@"\\p{Nl}"]); // Ⅴ (Roman numeral five)

    // Superscript 2 is \p{No}
    XCTAssertTrue([@"\u00B2" isMatchedByRegex:@"\\p{No}"]); // ²

    // \p{N} matches any numeric character
    NSString *mixed = @"3\u0664\u2164\u00B2";
    NSArray<NSString *> *numerics = [mixed substringsMatchedByRegex:@"\\p{N}"];
    XCTAssertEqual(numerics.count, 4);
}

#pragma mark - Unicode Punctuation and Symbol Properties

- (void)testUnicodePunctuationAndSymbolProperties
{
    // MRE3 pp.120-121: \p{P} = punctuation, \p{S} = symbol, \p{Z} = separator

    // Punctuation
    XCTAssertTrue([@"," isMatchedByRegex:@"\\p{P}"]);
    XCTAssertTrue([@"!" isMatchedByRegex:@"\\p{P}"]);
    XCTAssertTrue([@"\u2014" isMatchedByRegex:@"\\p{P}"]); // em dash

    // Symbols
    XCTAssertTrue([@"$" isMatchedByRegex:@"\\p{S}"]);
    XCTAssertTrue([@"\u00A9" isMatchedByRegex:@"\\p{S}"]); // ©
    XCTAssertTrue([@"+" isMatchedByRegex:@"\\p{S}"]);

    // Separators
    XCTAssertTrue([@" " isMatchedByRegex:@"\\p{Z}"]);
    XCTAssertTrue([@"\u00A0" isMatchedByRegex:@"\\p{Z}"]); // non-breaking space

    // Extract all punctuation from a sentence
    NSString *sentence = @"Hello, world! How's it going?";
    NSArray<NSString *> *punctuation = [sentence substringsMatchedByRegex:@"\\p{P}"];
    XCTAssertEqual(punctuation.count, 4); // , ! ' ?
}

#pragma mark - Unicode Script Properties

- (void)testUnicodeScriptPropertyGreek
{
    // MRE3 p.121: \p{Greek} matches Greek script characters
    NSString *greek = @"\u03B1\u03B2\u03B3"; // αβγ
    NSArray<NSString *> *matches = [greek substringsMatchedByRegex:@"\\p{Greek}+"];
    XCTAssertEqual(matches.count, 1);
    XCTAssertEqualObjects(matches[0], @"\u03B1\u03B2\u03B3");

    // Mixed text: extract Greek from Latin
    NSString *mixed = @"The Greek letter alpha is \u03B1 and beta is \u03B2.";
    NSArray<NSString *> *greekLetters = [mixed substringsMatchedByRegex:@"\\p{Greek}"];
    XCTAssertEqual(greekLetters.count, 2);
}

- (void)testUnicodeScriptPropertyCyrillic
{
    // MRE3 p.121: \p{Cyrillic} matches Cyrillic script
    NSString *russian = @"\u041F\u0440\u0438\u0432\u0435\u0442"; // Привет
    XCTAssertTrue([russian isMatchedByRegex:@"^\\p{Cyrillic}+$"]);

    // Latin characters should not match Cyrillic
    XCTAssertFalse([@"Hello" isMatchedByRegex:@"\\p{Cyrillic}"]);

    // Extract Cyrillic words from mixed text
    NSString *mixed = @"Say \u041F\u0440\u0438\u0432\u0435\u0442 in Russian";
    NSString *cyrillicWord = [mixed stringMatchedByRegex:@"\\p{Cyrillic}+"];
    XCTAssertEqualObjects(cyrillicWord, @"\u041F\u0440\u0438\u0432\u0435\u0442");
}

- (void)testUnicodeScriptPropertyCJK
{
    // MRE3 p.121: \p{Han} for CJK ideographs, \p{Hiragana} for Japanese hiragana
    NSString *kanji = @"\u4E16\u754C"; // 世界 (sekai = world)
    XCTAssertTrue([kanji isMatchedByRegex:@"^\\p{Han}+$"]);

    NSString *hiragana = @"\u3053\u3093\u306B\u3061\u306F"; // こんにちは
    XCTAssertTrue([hiragana isMatchedByRegex:@"^\\p{Hiragana}+$"]);

    // Mixed Japanese: extract kanji vs hiragana
    NSString *japanese = @"\u4E16\u754C\u306E\u5E73\u548C"; // 世界の平和 (sekai no heiwa)
    NSArray<NSString *> *kanjiMatches = [japanese substringsMatchedByRegex:@"\\p{Han}+"];
    XCTAssertEqual(kanjiMatches.count, 2); // 世界 and 平和
    NSArray<NSString *> *hiraganaMatches = [japanese substringsMatchedByRegex:@"\\p{Hiragana}+"];
    XCTAssertEqual(hiraganaMatches.count, 1); // の
}

#pragma mark - Unicode Block Properties

- (void)testUnicodeBlockProperties
{
    // MRE3 p.122: \p{InBasicLatin} for Unicode blocks
    XCTAssertTrue([@"A" isMatchedByRegex:@"\\p{InBasicLatin}"]);
    XCTAssertFalse([@"\u00E9" isMatchedByRegex:@"^\\p{InBasicLatin}$"]); // é is Latin-1 Supplement

    // CJK Unified Ideographs block
    XCTAssertTrue([@"\u4E16" isMatchedByRegex:@"\\p{InCJKUnifiedIdeographs}"]); // 世
    XCTAssertFalse([@"A" isMatchedByRegex:@"\\p{InCJKUnifiedIdeographs}"]);
}

#pragma mark - Mode Modifiers

- (void)testInlineModeModifiers
{
    // MRE3 pp.110-112: (?i), (?m), (?s), (?x) inline mode modifiers

    // (?i) for case-insensitive
    XCTAssertTrue([@"HELLO" isMatchedByRegex:@"(?i)hello"]);
    XCTAssertTrue([@"Hello" isMatchedByRegex:@"(?i)hello"]);

    // (?i) toggled off with (?-i)
    NSString *regex = @"(?i)hello(?-i)WORLD";
    XCTAssertTrue([@"helloWORLD" isMatchedByRegex:regex]);
    XCTAssertTrue([@"HELLOworld" isMatchedByRegex:regex] == NO);

    // (?m) for multiline (^ and $ match at line boundaries)
    NSString *text = @"abc\ndef";
    NSArray<NSString *> *lines = [text substringsMatchedByRegex:@"(?m)^\\w+$"];
    XCTAssertEqual(lines.count, 2);

    // (?s) for dotall (dot matches newline)
    NSString *dotallMatch = [text stringMatchedByRegex:@"(?s)a.+f"];
    XCTAssertEqualObjects(dotallMatch, @"abc\ndef");

    // Without (?s), dot does not match newline
    NSString *noDotallMatch = [text stringMatchedByRegex:@"a.+f"];
    XCTAssertNil(noDotallMatch);
}

- (void)testModeModifiedSpans
{
    // MRE3 p.112: (?i:...) applies mode only within the group
    // Case-insensitive only for "abc", then case-sensitive for "DEF"
    NSString *regex = @"(?i:abc)DEF";
    XCTAssertTrue([@"abcDEF" isMatchedByRegex:regex]);
    XCTAssertTrue([@"ABCDEF" isMatchedByRegex:regex]);
    XCTAssertFalse([@"ABCdef" isMatchedByRegex:regex]);
    XCTAssertTrue([@"AbcDEF" isMatchedByRegex:regex]);
}

#pragma mark - Atomic Grouping and Possessive Quantifiers

- (void)testAtomicGroupingBehavior
{
    // MRE3 pp.139-140: (?>...) atomic group prevents backtracking into the group
    // (?>a|ab)b — the atomic group tries 'a', matches, locks it in; then needs 'b'.
    // Against "ab": atomic group matches 'a', then needs 'b' -> finds 'b' -> matches
    // Against "abb": same -> matches "ab" (first 'a' + 'b')
    // Against "b": atomic group cannot match 'a' or 'ab' -> fails
    XCTAssertTrue([@"ab" isMatchedByRegex:@"(?>a|ab)b"]);

    // With normal grouping, "ab" against (a|ab)b:
    // tries 'a', then needs 'b' -> 'b' is there -> matches
    XCTAssertTrue([@"ab" isMatchedByRegex:@"(a|ab)b"]);

    // Key difference: "abc" with atomic vs non-atomic
    // Normal group (a|ab)c: tries 'a', needs 'c', fails at 'b'; backtracks, tries 'ab', needs 'c' -> 'c' matches
    XCTAssertTrue([@"abc" isMatchedByRegex:@"(a|ab)c"]);
    // Atomic group (?>a|ab)c: tries 'a', locks it, needs 'c', fails at 'b'; cannot backtrack -> fails
    XCTAssertFalse([@"abc" isMatchedByRegex:@"(?>a|ab)c"]);
}

- (void)testPossessiveQuantifiers
{
    // MRE3 p.142: a++ is equivalent to (?>a+) — possessive, no backtracking
    // Possessive quantifier \d++ grabs all digits and never gives back
    // So \d++\d can never match because \d++ consumes all digits
    XCTAssertFalse([@"12345" isMatchedByRegex:@"^\\d++\\d$"]);
    // But greedy \d+\d can match: \d+ gives back one digit for the trailing \d
    XCTAssertTrue([@"12345" isMatchedByRegex:@"^\\d+\\d$"]);

    // Possessive *+ and ?+
    XCTAssertFalse([@"aaa" isMatchedByRegex:@"^a*+a$"]); // a*+ eats all, nothing left for trailing a
    XCTAssertTrue([@"aaa" isMatchedByRegex:@"^a*a$"]);   // greedy a* gives back one

    XCTAssertFalse([@"a" isMatchedByRegex:@"^a?+a$"]);   // a?+ eats the 'a', nothing left
    XCTAssertTrue([@"a" isMatchedByRegex:@"^a?a$"]);     // greedy a? gives back
}

#pragma mark - String-Level Anchors

- (void)testStringAnchorsAZz
{
    // MRE3 pp.129-130: \A matches start of string, \Z matches end (before final newline), \z matches very end
    NSString *text = @"first\nsecond\nthird\n";

    // \A always matches start of string, regardless of multiline mode
    NSString *startMatch = [text stringMatchedByRegex:@"\\A\\w+" options:RKXMultiline];
    XCTAssertEqualObjects(startMatch, @"first");

    // With multiline, ^ matches at each line start, but \A only at string start
    NSArray<NSString *> *caretMatches = [text substringsMatchedByRegex:@"^\\w+" options:RKXMultiline];
    XCTAssertEqual(caretMatches.count, 3);
    NSArray<NSString *> *anchorAMatches = [text substringsMatchedByRegex:@"\\A\\w+" options:RKXMultiline];
    XCTAssertEqual(anchorAMatches.count, 1); // \A only matches once at string start

    // \z matches at the very end of string (after final \n)
    XCTAssertTrue([text isMatchedByRegex:@"\\n\\z"]);
    // \Z matches before the final newline OR at the very end
    XCTAssertTrue([text isMatchedByRegex:@"third\\Z" options:RKXMultiline]);
}

#pragma mark - Character Class Intersection

- (void)testCharacterClassIntersection
{
    // MRE3 p.125: [a-z&&[^aeiou]] matches lowercase consonants only (ICU supports this)
    NSString *regex = @"[a-z&&[^aeiou]]";
    NSString *text = @"azbycxdwe";
    NSArray<NSString *> *consonants = [text substringsMatchedByRegex:regex];
    // z, b, y, c, x, d, w are consonants (y is not a vowel in regex)
    XCTAssertEqual(consonants.count, 7);
    XCTAssertEqualObjects(consonants[0], @"z");
    XCTAssertEqualObjects(consonants[1], @"b");
    XCTAssertEqualObjects(consonants[2], @"y");
    XCTAssertEqualObjects(consonants[3], @"c");
    XCTAssertEqualObjects(consonants[4], @"x");
    XCTAssertEqualObjects(consonants[5], @"d");
    XCTAssertEqualObjects(consonants[6], @"w");

    // Vowels should not match
    XCTAssertFalse([@"a" isMatchedByRegex:@"^[a-z&&[^aeiou]]$"]);
    XCTAssertFalse([@"e" isMatchedByRegex:@"^[a-z&&[^aeiou]]$"]);
    XCTAssertTrue([@"b" isMatchedByRegex:@"^[a-z&&[^aeiou]]$"]);
}

#pragma mark - Lookbehind

- (void)testLookbehindFixedWidthConstraint
{
    // MRE3 p.133: Lookbehind must be fixed-width in most engines (including ICU)
    // Fixed-width lookbehind works
    NSString *text = @"USD100 EUR200 GBP300";
    NSArray<NSString *> *amounts = [text substringsMatchedByRegex:@"(?<=USD)\\d+"];
    XCTAssertEqual(amounts.count, 1);
    XCTAssertEqualObjects(amounts[0], @"100");

    // Alternation in lookbehind with same-length alternatives works
    NSArray<NSString *> *multiAmounts = [text substringsMatchedByRegex:@"(?<=USD|EUR|GBP)\\d+"];
    XCTAssertEqual(multiAmounts.count, 3);

    // Variable-width lookbehind like (?<=a+) should fail (invalid regex)
    NSError *error = nil;
    BOOL valid = [@"(?<=a+)b" isRegexValidWithOptions:RKXNoOptions error:&error];
    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

#pragma mark - Comments

- (void)testCommentGroupSyntax
{
    // MRE3 p.110: (?#comment) allows inline comments in patterns
    NSString *regex = @"\\d+(?# match one or more digits)\\.(?# a literal dot)\\d+(?# more digits)";
    XCTAssertTrue([@"3.14" isMatchedByRegex:regex]);
    XCTAssertFalse([@"abc" isMatchedByRegex:regex]);

    // Comments with (?x) mode: # to end of line is a comment
    NSString *verboseRegex = @""
        "\\d+     # integer part\n"
        "\\.      # decimal point\n"
        "\\d+     # fractional part";
    NSString *match = [@"pi is about 3.14159" stringMatchedByRegex:verboseRegex options:RKXIgnoreWhitespace];
    XCTAssertEqualObjects(match, @"3.14159");
}

#pragma mark - Capture Count

- (void)testNonCapturingVsCapturingGroupCount
{
    // MRE3 p.114: (?:...) does not count as a capture group
    NSString *capturingRegex = @"(a)(b)(c)";
    NSString *nonCapturingRegex = @"(?:a)(b)(?:c)";
    NSString *mixedRegex = @"(a)(?:b)(c)";

    NSUInteger capCount = [capturingRegex captureCountWithOptions:RKXNoOptions error:NULL];
    NSUInteger nonCapCount = [nonCapturingRegex captureCountWithOptions:RKXNoOptions error:NULL];
    NSUInteger mixedCount = [mixedRegex captureCountWithOptions:RKXNoOptions error:NULL];

    XCTAssertEqual(capCount, 3);
    XCTAssertEqual(nonCapCount, 1);
    XCTAssertEqual(mixedCount, 2);
}

@end
