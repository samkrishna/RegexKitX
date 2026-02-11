//
//  MasteringRegexCh01Tests.m
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
// Chapter 1: Introduction to Regular Expressions (pp.1-33)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh01Tests : XCTestCase
@end

@implementation MasteringRegexCh01Tests

#pragma mark - Character Classes

- (void)testCharacterClassAlternation
{
    // MRE3 p.3: gr[ea]y matches both "grey" and "gray"
    NSString *regex = @"\\bgr[ea]y\\b";
    NSString *text = @"Is it grey or gray? Not griy.";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"grey");
    XCTAssertEqualObjects(matches[1], @"gray");
    XCTAssertFalse([@"griy" isMatchedByRegex:regex]);
}

- (void)testNegatedCharacterClasses
{
    // MRE3 p.5: [^...] matches characters NOT in the class
    NSString *regex = @"[^aeiouAEIOU\\s\\d\\W]";
    NSString *text = @"hello";
    NSArray<NSString *> *consonants = [text substringsMatchedByRegex:regex];
    // h, l, l are consonants in "hello"
    XCTAssertEqual(consonants.count, 3);
    XCTAssertEqualObjects(consonants[0], @"h");
    XCTAssertEqualObjects(consonants[1], @"l");
    XCTAssertEqualObjects(consonants[2], @"l");
}

#pragma mark - Dot Metacharacter

- (void)testDotAsWildcard
{
    // MRE3 p.4: dot matches any character (except newline by default)
    NSString *text = @"abc\ndef";

    // Without RKXDotAll, dot should NOT match across newline
    NSString *greedyDot = @"^.+$";
    NSString *matchDefault = [text stringMatchedByRegex:greedyDot];
    XCTAssertNil(matchDefault, @"Without multiline or dotall, ^.+$ should not match across newline");

    // With RKXDotAll, dot matches newline too
    NSString *matchDotAll = [text stringMatchedByRegex:greedyDot options:RKXDotAll];
    XCTAssertEqualObjects(matchDotAll, @"abc\ndef");

    // With RKXMultiline, ^ and $ match at line boundaries
    NSArray<NSString *> *lines = [text substringsMatchedByRegex:greedyDot options:RKXMultiline];
    XCTAssertEqual(lines.count, 2);
    XCTAssertEqualObjects(lines[0], @"abc");
    XCTAssertEqualObjects(lines[1], @"def");
}

#pragma mark - Alternation

- (void)testAlternationOperator
{
    // MRE3 p.6: alternation with | for multiple alternatives
    NSString *regex = @"\\b(?:first|1st)\\b";
    NSString *text = @"The first place or 1st place, not 21st.";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"first");
    XCTAssertEqualObjects(matches[1], @"1st");
}

#pragma mark - Quantifiers

- (void)testOptionalQuantifier
{
    // MRE3 p.7: ? makes the preceding item optional
    NSString *colorRegex = @"\\bcolou?r\\b";
    XCTAssertTrue([@"color" isMatchedByRegex:colorRegex]);
    XCTAssertTrue([@"colour" isMatchedByRegex:colorRegex]);
    XCTAssertFalse([@"colouur" isMatchedByRegex:colorRegex]);

    // MRE3 p.8: ? on a group: "4th" or "4"
    NSString *ordinalRegex = @"\\b4(?:th)?\\b";
    XCTAssertTrue([@"4th" isMatchedByRegex:ordinalRegex]);
    XCTAssertTrue([@"4" isMatchedByRegex:ordinalRegex]);
    XCTAssertFalse([@"44th" isMatchedByRegex:ordinalRegex]);
}

- (void)testQuantifierRangeMinMax
{
    // MRE3 p.9: {min,max} interval quantifier
    NSString *regex = @"\\b\\w{4,6}\\b";
    NSString *text = @"I am the very best of us all";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    // "very" (4), "best" (4)
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"very");
    XCTAssertEqualObjects(matches[1], @"best");

    // Words that are too short or too long should not match
    XCTAssertFalse([@"cat" isMatchedByRegex:@"^\\w{4,6}$"]);
    XCTAssertFalse([@"extraordinary" isMatchedByRegex:@"^\\w{4,6}$"]);
    XCTAssertTrue([@"hello" isMatchedByRegex:@"^\\w{4,6}$"]);
}

#pragma mark - Anchors

- (void)testAnchorsCaretDollar
{
    // MRE3 p.5: ^ matches start of line, $ matches end of line
    NSString *text = @"apple\nbanana\navocado";

    // Without multiline, ^ and $ match start/end of entire string
    XCTAssertEqualObjects([text stringMatchedByRegex:@"^\\w+"], @"apple");

    // With RKXMultiline, ^ and $ match at line boundaries
    NSArray<NSString *> *lineStarts = [text substringsMatchedByRegex:@"^\\w+" options:RKXMultiline];
    XCTAssertEqual(lineStarts.count, 3);
    XCTAssertEqualObjects(lineStarts[0], @"apple");
    XCTAssertEqualObjects(lineStarts[1], @"banana");
    XCTAssertEqualObjects(lineStarts[2], @"avocado");

    // $ at end of lines
    NSArray<NSString *> *lineEnds = [text substringsMatchedByRegex:@"\\w+$" options:RKXMultiline];
    XCTAssertEqual(lineEnds.count, 3);
}

#pragma mark - Word Boundaries

- (void)testWordBoundaryVsNonWordBoundary
{
    // MRE3 p.6: \b is a word boundary, \B is a non-word boundary
    NSString *text = @"The cat concatenated the caterpillar catalog";

    // \bcat\b matches only the standalone word "cat"
    NSArray<NSString *> *wordMatches = [text substringsMatchedByRegex:@"\\bcat\\b"];
    XCTAssertEqual(wordMatches.count, 1);
    XCTAssertEqualObjects(wordMatches[0], @"cat");

    // \Bcat\B matches "cat" embedded within a word (non-word-boundary on BOTH sides)
    NSArray<NSString *> *embeddedMatches = [text substringsMatchedByRegex:@"\\Bcat\\B"];
    // "concatenated": ...n-c-a-t-e... -> \B before c (word char n), \B after t (word char e) ✓
    // "caterpillar": \b before c (space), so no match
    // "catalog": \b before c (space), so no match
    XCTAssertEqual(embeddedMatches.count, 1);
    XCTAssertEqualObjects(embeddedMatches[0], @"cat");
}

#pragma mark - Shorthand Character Classes

- (void)testShorthandClasses
{
    // MRE3 pp.15-17: \w, \d, \s and their negations \W, \D, \S
    NSString *mixed = @"Hello 42 World!";

    // \d+ matches digit sequences
    NSArray<NSString *> *digits = [mixed substringsMatchedByRegex:@"\\d+"];
    XCTAssertEqual(digits.count, 1);
    XCTAssertEqualObjects(digits[0], @"42");

    // \w+ matches word-character sequences
    NSArray<NSString *> *words = [mixed substringsMatchedByRegex:@"\\w+"];
    XCTAssertEqual(words.count, 3);
    XCTAssertEqualObjects(words[0], @"Hello");
    XCTAssertEqualObjects(words[1], @"42");
    XCTAssertEqualObjects(words[2], @"World");

    // \s+ matches whitespace sequences
    NSArray<NSString *> *spaces = [mixed substringsMatchedByRegex:@"\\s+"];
    XCTAssertEqual(spaces.count, 2);

    // \D+ matches non-digit sequences
    NSArray<NSString *> *nonDigits = [mixed substringsMatchedByRegex:@"\\D+"];
    XCTAssertEqual(nonDigits.count, 2);
    XCTAssertEqualObjects(nonDigits[0], @"Hello ");
    XCTAssertEqualObjects(nonDigits[1], @" World!");

    // \W matches non-word characters
    NSArray<NSString *> *nonWords = [mixed substringsMatchedByRegex:@"\\W+"];
    XCTAssertEqual(nonWords.count, 3); // space, space, !
}

#pragma mark - Grouping and Capturing

- (void)testGroupingVsCapturing
{
    // MRE3 p.10: (...) captures, (?:...) groups without capturing
    NSString *text = @"abcabc";

    // Capturing group: has 1 capture
    NSUInteger capturingCount = [@"(abc)+" captureCountWithOptions:RKXNoOptions error:NULL];
    XCTAssertEqual(capturingCount, 1);

    // Non-capturing group: has 0 captures
    NSUInteger nonCapturingCount = [@"(?:abc)+" captureCountWithOptions:RKXNoOptions error:NULL];
    XCTAssertEqual(nonCapturingCount, 0);

    // Verify both still match the same text
    XCTAssertTrue([text isMatchedByRegex:@"(abc)+"]);
    XCTAssertTrue([text isMatchedByRegex:@"(?:abc)+"]);

    // Capturing group returns captured content
    NSArray<NSString *> *captures = [text captureSubstringsMatchedByRegex:@"(abc)+"];
    XCTAssertEqual(captures.count, 2); // index 0 = full match, index 1 = capture group 1
    XCTAssertEqualObjects(captures[0], @"abcabc");
    XCTAssertEqualObjects(captures[1], @"abc");
}

#pragma mark - Greedy vs Lazy

- (void)testGreedyVsLazyBasics
{
    // MRE3 p.11: greedy .* vs lazy .*?
    NSString *html = @"<b>bold</b> and <i>italic</i>";

    // Greedy: <.*> matches from first < to LAST >
    NSString *greedyMatch = [html stringMatchedByRegex:@"<.*>"];
    XCTAssertEqualObjects(greedyMatch, @"<b>bold</b> and <i>italic</i>");

    // Lazy: <.*?> matches from first < to NEXT >
    NSString *lazyMatch = [html stringMatchedByRegex:@"<.*?>"];
    XCTAssertEqualObjects(lazyMatch, @"<b>");

    // All lazy matches
    NSArray<NSString *> *allTags = [html substringsMatchedByRegex:@"<.*?>"];
    XCTAssertEqual(allTags.count, 4);
    XCTAssertEqualObjects(allTags[0], @"<b>");
    XCTAssertEqualObjects(allTags[1], @"</b>");
    XCTAssertEqualObjects(allTags[2], @"<i>");
    XCTAssertEqualObjects(allTags[3], @"</i>");
}

@end
