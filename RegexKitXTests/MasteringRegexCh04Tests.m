//
//  MasteringRegexCh04Tests.m
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
// Chapter 4: The Mechanics of Expression Processing (pp.143-184)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh04Tests : XCTestCase
@end

@implementation MasteringRegexCh04Tests

#pragma mark - Leftmost Match Rule

- (void)testLeftmostMatchWins
{
    // MRE3 p.148: The match that begins earliest (leftmost) always wins
    NSString *text = @"The caterpillar caught a cat";
    NSString *match = [text stringMatchedByRegex:@"cat"];
    // Even though "cat" appears standalone at the end, the first "cat" in "caterpillar" wins
    XCTAssertEqualObjects(match, @"cat");
    NSRange range = [text rangeOfRegex:@"cat"];
    XCTAssertEqual(range.location, 4UL); // "cat" starts at index 4 within "caterpillar"
}

- (void)testLeftmostMatchWithAlternation
{
    // MRE3 p.149: Even with alternation, leftmost match position wins
    NSString *text = @"Monday or Tuesday or Friday";
    // "Tuesday" appears before "Friday" in the text, so it matches first even though
    // "Friday" is listed first in the alternation
    NSString *match = [text stringMatchedByRegex:@"Friday|Tuesday"];
    XCTAssertEqualObjects(match, @"Tuesday");
}

#pragma mark - Ordered Alternation (NFA Behavior)

- (void)testNFAAlternationOrderMatters
{
    // MRE3 pp.167-169: In an NFA engine, alternation is ordered (left to right)
    // At the same position, the first alternative that allows an overall match is used

    // "ab|a" vs "a|ab" against "ab": NFA tries alternatives left-to-right
    // With "ab|a": tries "ab" first at position 0, matches -> returns "ab"
    NSString *match1 = [@"ab" stringMatchedByRegex:@"ab|a"];
    XCTAssertEqualObjects(match1, @"ab");

    // With "a|ab": tries "a" first at position 0, matches -> returns "a"
    // (The NFA doesn't continue to check if a longer match exists)
    NSString *match2 = [@"ab" stringMatchedByRegex:@"a|ab"];
    XCTAssertEqualObjects(match2, @"a");
}

- (void)testAlternationOrderAffectsCapture
{
    // MRE3 p.168: NFA alternation order affects what gets captured
    NSString *text = @"export";

    // "ex|export" against "export": "ex" matches first (it's the first alternative at pos 0)
    NSString *match1 = [text stringMatchedByRegex:@"ex|export"];
    XCTAssertEqualObjects(match1, @"ex");

    // "export|ex" against "export": "export" matches first (tried first, succeeds)
    NSString *match2 = [text stringMatchedByRegex:@"export|ex"];
    XCTAssertEqualObjects(match2, @"export");
}

- (void)testAlternationOrderWithAnchors
{
    // MRE3 p.169: Anchors can force the engine to try all alternatives
    NSString *text = @"export";

    // With end anchor, "ex" doesn't match "export$", so engine backtracks to try "export"
    NSString *match = [text stringMatchedByRegex:@"^(?:ex|export)$"];
    XCTAssertEqualObjects(match, @"export");

    // Without anchor, first match wins
    NSString *matchNoAnchor = [text stringMatchedByRegex:@"ex|export"];
    XCTAssertEqualObjects(matchNoAnchor, @"ex");
}

#pragma mark - Greedy Quantifier Backtracking

- (void)testGreedyQuantifierBacktracking
{
    // MRE3 pp.151-155: Greedy .* consumes everything, then backtracks
    NSString *text = @"<tag>content</tag>";

    // Greedy: .* grabs everything from first < to end, then backtracks to find >
    // Result: matches entire string from first < to last >
    NSString *greedyMatch = [text stringMatchedByRegex:@"<.*>"];
    XCTAssertEqualObjects(greedyMatch, @"<tag>content</tag>");

    // With negated class: [^>]* never over-consumes, no backtracking needed
    NSString *negatedMatch = [text stringMatchedByRegex:@"<[^>]*>"];
    XCTAssertEqualObjects(negatedMatch, @"<tag>");
}

- (void)testGreedyBacktrackingWithMultipleMatches
{
    // MRE3 pp.155-157: Greedy quantifier gives back just enough for overall match
    NSString *text = @"123abc456";

    // \d+ grabs all of "123abc456"... wait, \d only matches digits.
    // \d+ grabs "123", then can't match further. That's the match.
    // Better example: \w+ grabs everything, then needs to give back for trailing pattern
    NSArray<NSString *> *captures = [text captureSubstringsMatchedByRegex:@"(\\w+)(\\d+)"];
    // \w+ (greedy) grabs all "123abc456", then backtracks one char for \d+
    // \w+ = "123abc45", \d+ = "6"
    XCTAssertEqualObjects(captures[1], @"123abc45");
    XCTAssertEqualObjects(captures[2], @"6");
}

- (void)testGreedyQuantifierGivesBackMinimum
{
    // MRE3 p.156: Greedy quantifier gives back only as much as needed
    NSString *text = @"aaaaab";

    // a+ab: greedy a+ grabs all 5 a's, then needs "ab"
    // Must give back one 'a' for the literal 'a' before 'b'
    NSArray<NSString *> *captures = [text captureSubstringsMatchedByRegex:@"(a+)(ab)"];
    XCTAssertEqualObjects(captures[1], @"aaaa"); // a+ got 4 a's
    XCTAssertEqualObjects(captures[2], @"ab");    // the literal "ab"
}

#pragma mark - Lazy Quantifier Mechanics

- (void)testLazyQuantifierMinimalMatch
{
    // MRE3 pp.161-163: Lazy .*? matches as little as possible, then extends
    NSString *text = @"<b>bold</b> and <i>italic</i>";

    // Lazy: .*? starts with zero chars, tries to complete match, extends as needed
    NSString *lazyMatch = [text stringMatchedByRegex:@"<.*?>"];
    XCTAssertEqualObjects(lazyMatch, @"<b>");

    // All lazy matches
    NSArray<NSString *> *allMatches = [text substringsMatchedByRegex:@"<.*?>"];
    XCTAssertEqual(allMatches.count, 4);
    XCTAssertEqualObjects(allMatches[0], @"<b>");
    XCTAssertEqualObjects(allMatches[1], @"</b>");
    XCTAssertEqualObjects(allMatches[2], @"<i>");
    XCTAssertEqualObjects(allMatches[3], @"</i>");
}

- (void)testLazyVsGreedyCaptureGroups
{
    // MRE3 pp.163-165: Lazy and greedy affect what capture groups contain
    NSString *text = @"123abc456def789";

    // Greedy: (.+)(\d+) -- .+ grabs maximally, \d+ gets minimum
    NSArray<NSString *> *greedy = [text captureSubstringsMatchedByRegex:@"(.+)(\\d+)"];
    XCTAssertEqualObjects(greedy[1], @"123abc456def78"); // .+ grabs all but last digit
    XCTAssertEqualObjects(greedy[2], @"9");              // \d+ gets just "9"

    // Lazy: (.+?)(\d+) -- .+? grabs minimally, \d+ gets maximum from remainder
    NSArray<NSString *> *lazy = [text captureSubstringsMatchedByRegex:@"(.+?)(\\d+)"];
    XCTAssertEqualObjects(lazy[1], @"1");     // .+? grabs just "1" (minimum)
    XCTAssertEqualObjects(lazy[2], @"23");    // \d+ grabs "23" (then hits 'a')
}

#pragma mark - Backtracking with Nested Quantifiers

- (void)testNestedQuantifierBacktracking
{
    // MRE3 pp.165-167: Nested quantifiers can cause extensive backtracking
    // (a+)+ against "aaab" -- the engine tries many partitions of a's
    // This is safe with a short string but illustrates the concept
    NSString *text = @"aaab";

    // (a+)+b matches: the engine eventually finds the right partition
    XCTAssertTrue([text isMatchedByRegex:@"^(a+)+b$"]);
    XCTAssertEqualObjects([text stringMatchedByRegex:@"(a+)+b"], @"aaab");

    // But (a+)+c against "aaa" fails after extensive backtracking
    // (won't hang for a short string, but demonstrates the failure)
    XCTAssertFalse([@"aaa" isMatchedByRegex:@"^(a+)+c$"]);
}

#pragma mark - Atomic Grouping Prevents Backtracking

- (void)testAtomicGroupPreventsBacktracking
{
    // MRE3 pp.169-173: (?>...) locks in its match, preventing backtracking
    // With normal group: a{1,3} can give back characters
    // With atomic group: (?>a{1,3}) cannot give back

    // Normal: a{1,3}ab can match "aaab" because a{1,3} gives back one 'a'
    XCTAssertTrue([@"aaab" isMatchedByRegex:@"^a{1,3}ab$"]);

    // Atomic: (?>a{1,3})ab cannot match "aaab" -- a{1,3} grabs all 3 a's,
    // then needs "ab" but only "b" remains, and atomic group won't give back
    XCTAssertFalse([@"aaab" isMatchedByRegex:@"^(?>a{1,3})ab$"]);

    // But "aab" works with atomic: a{1,3} grabs "aa" (or all available a's = 2),
    // then "ab" matches remainder... wait, let's think:
    // "aab": (?>a{1,3}) grabs "aa" (greedy, takes 2), needs "ab", only "b" left -> fail
    // Actually no: a{1,3} is greedy so grabs all a's available (2), then locked in.
    // Remaining: "b", needs "ab" -> fails
    XCTAssertFalse([@"aab" isMatchedByRegex:@"^(?>a{1,3})ab$"]);

    // "aaab" with just "b" after atomic: works because after (?>a{1,3}) grabs 3 a's, "b" is left
    XCTAssertTrue([@"aaab" isMatchedByRegex:@"^(?>a{1,3})b$"]);
}

- (void)testAtomicGroupWithAlternation
{
    // MRE3 p.170: Atomic group with alternation: once an alternative matches, it's locked in
    // (?>first|second) in "secondhand": tries "first" -> no match -> tries "second" -> matches -> locked
    XCTAssertTrue([@"secondhand" isMatchedByRegex:@"(?>first|second)hand"]);

    // (?>ab|a)b: tries "ab", if it matches, locked in; then needs "b"
    // Against "ab": (?>ab|a) -> tries "ab", matches -> locked. Needs "b" but string is done -> fails
    XCTAssertFalse([@"ab" isMatchedByRegex:@"^(?>ab|a)b$"]);

    // Against "abb": (?>ab|a) -> tries "ab", matches -> locked. Needs "b" -> "b" is there -> matches
    XCTAssertTrue([@"abb" isMatchedByRegex:@"^(?>ab|a)b$"]);

    // Non-atomic: (ab|a)b against "ab": tries "ab", needs "b" -> fails; backtracks to "a", needs "b" -> matches
    XCTAssertTrue([@"ab" isMatchedByRegex:@"^(ab|a)b$"]);
}

#pragma mark - Possessive Quantifiers

- (void)testPossessiveQuantifiersPreventsBacktracking
{
    // MRE3 p.172: x++ is equivalent to (?>x+) -- possessive, never gives back
    // \d++\d: digits possessively consumed, nothing left for trailing \d
    XCTAssertFalse([@"12345" isMatchedByRegex:@"^\\d++\\d$"]);
    XCTAssertTrue([@"12345" isMatchedByRegex:@"^\\d+\\d$"]); // greedy gives back one

    // [a-z]++[a-z]: possessive consumes all lowercase, trailing [a-z] fails
    XCTAssertFalse([@"hello" isMatchedByRegex:@"^[a-z]++[a-z]$"]);
    XCTAssertTrue([@"hello" isMatchedByRegex:@"^[a-z]+[a-z]$"]);

    // Possessive works correctly when the trailing pattern differs from what was consumed
    XCTAssertTrue([@"hello1" isMatchedByRegex:@"^[a-z]++\\d$"]);
}

- (void)testPossessiveQuantifierVariants
{
    // MRE3 p.172: All quantifier types have possessive forms: *+ ?+ {n,m}+
    // *+ : zero or more, possessive
    XCTAssertFalse([@"aaa" isMatchedByRegex:@"^a*+a$"]);
    XCTAssertTrue([@"aaa" isMatchedByRegex:@"^a*a$"]);

    // ?+ : zero or one, possessive
    XCTAssertFalse([@"a" isMatchedByRegex:@"^a?+a$"]);
    XCTAssertTrue([@"a" isMatchedByRegex:@"^a?a$"]);
    XCTAssertTrue([@"aa" isMatchedByRegex:@"^a?+a$"]); // ?+ takes one, "a" remains for literal a

    // {n,m}+ : range, possessive
    XCTAssertFalse([@"aaa" isMatchedByRegex:@"^a{1,3}+a$"]);
    XCTAssertTrue([@"aaa" isMatchedByRegex:@"^a{1,3}a$"]);
    XCTAssertTrue([@"aaaa" isMatchedByRegex:@"^a{1,3}+a$"]); // {1,3}+ takes 3, "a" remains
}

#pragma mark - Lookahead and Lookbehind Zero-Width

- (void)testLookaheadIsZeroWidth
{
    // MRE3 pp.173-175: Lookahead checks but doesn't consume text
    NSString *text = @"foobar";

    // (?=bar) at position after "foo" checks for "bar" but doesn't consume it
    // So foo(?=bar) matches "foo" (only "foo" is consumed), while "bar" remains unconsumed
    NSString *match = [text stringMatchedByRegex:@"foo(?=bar)"];
    XCTAssertEqualObjects(match, @"foo");
    XCTAssertEqual([text rangeOfRegex:@"foo(?=bar)"].length, 3UL); // only 3 chars consumed

    // We can then match the same "bar" with another part of the pattern
    NSString *fullMatch = [text stringMatchedByRegex:@"foo(?=bar)bar"];
    XCTAssertEqualObjects(fullMatch, @"foobar");

    // Multiple lookaheads at the same position (stacked conditions)
    // Match a position followed by a digit AND followed by something ending in "5"
    NSString *nums = @"15 25 30 45";
    // \b(?=\d+5)\d+ matches numbers ending in 5
    NSArray<NSString *> *endIn5 = [nums substringsMatchedByRegex:@"\\b(?=\\d+5\\b)\\d+"];
    XCTAssertEqual(endIn5.count, 3);
    XCTAssertEqualObjects(endIn5[0], @"15");
    XCTAssertEqualObjects(endIn5[1], @"25");
    XCTAssertEqualObjects(endIn5[2], @"45");
}

- (void)testLookbehindIsZeroWidth
{
    // MRE3 pp.175-177: Lookbehind checks preceding text without consuming it
    NSString *text = @"$100 is USD, 200EUR is not $300";

    // (?<=\$)\d+ matches digits preceded by $ sign
    NSArray<NSString *> *dollarAmounts = [text substringsMatchedByRegex:@"(?<=\\$)\\d+"];
    XCTAssertEqual(dollarAmounts.count, 2);
    XCTAssertEqualObjects(dollarAmounts[0], @"100");
    XCTAssertEqualObjects(dollarAmounts[1], @"300");

    // The $ is not part of the match itself
    NSRange range = [text rangeOfRegex:@"(?<=\\$)\\d+"];
    NSString *matchedSubstring = [text substringWithRange:range];
    XCTAssertEqualObjects(matchedSubstring, @"100");
    XCTAssertEqual(range.location, 1UL); // starts after the $
}

- (void)testCombinedLookaheadAndLookbehind
{
    // MRE3 p.177: Combining lookahead and lookbehind for precise matching
    NSString *text = @"abc123def456ghi";

    // Match digits that are preceded by letters AND followed by letters
    NSArray<NSString *> *sandwichedDigits = [text substringsMatchedByRegex:@"(?<=\\p{L})\\d+(?=\\p{L})"];
    XCTAssertEqual(sandwichedDigits.count, 2);
    XCTAssertEqualObjects(sandwichedDigits[0], @"123");
    XCTAssertEqualObjects(sandwichedDigits[1], @"456");

    // Digits at the end are NOT sandwiched (no following letter)
    NSString *text2 = @"abc123def456";
    NSArray<NSString *> *sandwiched2 = [text2 substringsMatchedByRegex:@"(?<=\\p{L})\\d+(?=\\p{L})"];
    XCTAssertEqual(sandwiched2.count, 1);
    XCTAssertEqualObjects(sandwiched2[0], @"123");
}

#pragma mark - Match Attempt at Each Position

- (void)testEngineTriesEachPosition
{
    // MRE3 p.178: The engine bumps along the string trying each position
    NSString *text = @"xxxabcxxx";

    // The engine tries "abc" at position 0, 1, 2 (all fail), then at position 3 it matches
    NSRange range = [text rangeOfRegex:@"abc"];
    XCTAssertEqual(range.location, 3UL);

    // rangesOfRegex: shows all positions where matches are found
    NSString *text2 = @"abcXabcXabc";
    NSArray<NSValue *> *ranges = [text2 rangesOfRegex:@"abc"];
    XCTAssertEqual(ranges.count, 3);
    XCTAssertEqual([ranges[0] rangeValue].location, 0UL);
    XCTAssertEqual([ranges[1] rangeValue].location, 4UL);
    XCTAssertEqual([ranges[2] rangeValue].location, 8UL);
}

- (void)testEmptyMatchAdvancement
{
    // MRE3 p.179: After an empty match, the engine advances by one position
    // to prevent infinite loops. This is implementation-defined behavior.
    // The regex "a*" can match empty string at every position.
    NSString *text = @"bbb";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:@"a*"];
    // At each position, a* matches zero a's (empty match).
    // Engine advances to next position. For "bbb" there are 4 positions (0,1,2,3).
    // Results in 4 empty matches.
    XCTAssertTrue(matches.count >= 3); // at least one per character position
    // All matches should be empty strings
    for (NSString *match in matches) {
        XCTAssertEqualObjects(match, @"");
    }
}

#pragma mark - Backtracking with Complex Patterns

- (void)testBacktrackingWithMultipleGroupsAndQuantifiers
{
    // MRE3 pp.158-160: Complex backtracking across multiple groups
    NSString *text = @"aaabbbccc";

    // (a+)(b+)(c+) -- each group greedily takes all it can
    NSArray<NSString *> *captures = [text captureSubstringsMatchedByRegex:@"(a+)(b+)(c+)"];
    XCTAssertEqualObjects(captures[1], @"aaa");
    XCTAssertEqualObjects(captures[2], @"bbb");
    XCTAssertEqualObjects(captures[3], @"ccc");

    // (a+)(b+)(c+)c -- trailing 'c' forces c+ to give back one
    NSArray<NSString *> *captures2 = [text captureSubstringsMatchedByRegex:@"(a+)(b+)(c+)c"];
    XCTAssertEqualObjects(captures2[1], @"aaa");
    XCTAssertEqualObjects(captures2[2], @"bbb");
    XCTAssertEqualObjects(captures2[3], @"cc");   // gave back one c

    // (a+)(b+)b(c+) -- trailing 'b' forces b+ to give back one
    NSArray<NSString *> *captures3 = [text captureSubstringsMatchedByRegex:@"(a+)(b+)b(c+)"];
    XCTAssertEqualObjects(captures3[1], @"aaa");
    XCTAssertEqualObjects(captures3[2], @"bb");    // gave back one b
    XCTAssertEqualObjects(captures3[3], @"ccc");
}

- (void)testBacktrackingFailureAndRetry
{
    // MRE3 pp.159-160: When backtracking exhausts all possibilities, engine moves to next position
    NSString *text = @"XY=abc";

    // Pattern attempts to match at position 0 (X), fails, moves to position 1 (Y), fails,
    // moves to position 2 (=), fails, finally tries at position 3 (a)
    NSString *match = [text stringMatchedByRegex:@"[a-z]+"];
    XCTAssertEqualObjects(match, @"abc");
    NSRange range = [text rangeOfRegex:@"[a-z]+"];
    XCTAssertEqual(range.location, 3UL);
}

#pragma mark - Negative Lookahead Mechanics

- (void)testNegativeLookaheadMechanics
{
    // MRE3 pp.173-174: (?!...) succeeds when the contained pattern fails to match
    NSString *text = @"foo123 bar456 foo789 baz000";

    // Match "foo" NOT followed by "123"
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:@"foo(?!123)\\d+"];
    XCTAssertEqual(matches.count, 1);
    XCTAssertEqualObjects(matches[0], @"foo789");

    // (?!.*bad) at start: ensure "bad" doesn't appear anywhere in the string
    XCTAssertTrue([@"this is good" isMatchedByRegex:@"^(?!.*bad).*$"]);
    XCTAssertFalse([@"this is bad stuff" isMatchedByRegex:@"^(?!.*bad).*$"]);
}

- (void)testNegativeLookbehindMechanics
{
    // MRE3 p.176: (?<!...) succeeds when the preceding text doesn't match
    // Note: Negative lookbehind (?<!EUR) only checks at the exact position,
    // so (?<!EUR)\d+ can match partial digit runs within "EUR200" (e.g. "00" at offset
    // where preceding text is "R20", not "EUR"). To match complete amounts,
    // use a lookbehind that covers the currency+start-of-digits boundary.
    NSString *text = @"$100 E200 $300";

    // Simple fixed-width negative lookbehind: match digits NOT preceded by "E"
    NSArray<NSString *> *nonEAmounts = [text substringsMatchedByRegex:@"(?<!E)\\d+"];
    // At "$100": '$' != 'E', matches "100"
    // At "E200": 'E' == 'E', skips position of '2'; but at '00', preceding is '2' != 'E', matches "00"
    // At "$300": '$' != 'E', matches "300"
    XCTAssertEqual(nonEAmounts.count, 3);
    XCTAssertEqualObjects(nonEAmounts[0], @"100");
    XCTAssertEqualObjects(nonEAmounts[1], @"00");  // partial match within "200"
    XCTAssertEqualObjects(nonEAmounts[2], @"300");

    // To avoid partial matches, use a more specific pattern:
    // Match digits preceded by a non-letter (or start of string)
    NSArray<NSString *> *properAmounts = [text substringsMatchedByRegex:@"(?<=\\$)\\d+"];
    XCTAssertEqual(properAmounts.count, 2);
    XCTAssertEqualObjects(properAmounts[0], @"100");
    XCTAssertEqualObjects(properAmounts[1], @"300");
}

#pragma mark - Greedy vs Lazy: Same Overall Match, Different Paths

- (void)testGreedyAndLazyCanProduceSameOverallMatch
{
    // MRE3 pp.164-165: Sometimes greedy and lazy produce the same result
    // but via different internal paths

    // ^.*$ always matches the whole string (or line) regardless of greedy/lazy
    NSString *text = @"hello world";
    NSString *greedyMatch = [text stringMatchedByRegex:@"^.*$"];
    NSString *lazyMatch = [text stringMatchedByRegex:@"^.*?$"];
    XCTAssertEqualObjects(greedyMatch, lazyMatch);
    XCTAssertEqualObjects(greedyMatch, @"hello world");
}

- (void)testGreedyAndLazyProduceDifferentResults
{
    // MRE3 pp.162-163: But usually they differ
    NSString *text = @"<a>one</a><b>two</b>";

    // Greedy <.+> matches from first < to last >
    NSString *greedy = [text stringMatchedByRegex:@"<.+>"];
    XCTAssertEqualObjects(greedy, text); // entire string

    // Lazy <.+?> matches from first < to nearest >
    NSString *lazy = [text stringMatchedByRegex:@"<.+?>"];
    XCTAssertEqualObjects(lazy, @"<a>");
}

@end
