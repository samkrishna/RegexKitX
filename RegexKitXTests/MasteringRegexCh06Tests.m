//
//  MasteringRegexCh06Tests.m
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
// Chapter 6: Crafting an Efficient Expression (pp.221-284)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh06Tests : XCTestCase
@end

@implementation MasteringRegexCh06Tests

#pragma mark - Unrolling the Loop: Quoted Strings

- (void)testUnrolledLoopQuotedString
{
    // MRE3 pp.261-264: The "unrolling the loop" technique for matching quoted strings
    // Pattern: "[^"\\]*(?:\\.[^"\\]*)*"
    // Normal*  (Special Normal*)*
    // Normal = [^"\\]  (any char except quote or backslash)
    // Special = \\.     (backslash followed by any char)
    NSString *unrolledRegex = @"\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"";

    // Simple quoted string
    NSString *simple = @"value = \"hello world\" here";
    NSString *simpleMatch = [simple stringMatchedByRegex:unrolledRegex];
    XCTAssertEqualObjects(simpleMatch, @"\"hello world\"");

    // Quoted string with escaped quotes
    NSString *escaped = @"msg = \"say \\\"hi\\\" please\" done";
    NSString *escapedMatch = [escaped stringMatchedByRegex:unrolledRegex];
    XCTAssertEqualObjects(escapedMatch, @"\"say \\\"hi\\\" please\"");

    // Quoted string with escaped backslash
    NSString *backslash = @"path = \"C:\\\\Users\\\\test\" end";
    NSString *bsMatch = [backslash stringMatchedByRegex:unrolledRegex];
    XCTAssertEqualObjects(bsMatch, @"\"C:\\\\Users\\\\test\"");

    // Empty quoted string
    NSString *empty = @"empty = \"\" here";
    NSString *emptyMatch = [empty stringMatchedByRegex:unrolledRegex];
    XCTAssertEqualObjects(emptyMatch, @"\"\"");
}

- (void)testUnrolledLoopSingleQuotedString
{
    // MRE3 p.264: Same technique applied to single-quoted strings
    // Pattern: '[^'\\]*(?:\\.[^'\\]*)*'
    NSString *regex = @"'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'";

    NSString *text = @"He said 'it\\'s great' and 'ok'";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"'it\\'s great'");
    XCTAssertEqualObjects(matches[1], @"'ok'");
}

#pragma mark - Unrolling the Loop: C Comments

- (void)testUnrolledLoopCComment
{
    // MRE3 pp.265-268: Unrolled loop for C-style /* ... */ comments
    // Pattern: /\*[^*]*\*+(?:[^/*][^*]*\*+)*/
    // Open: /\*
    // Normal: [^*]     (anything except *)
    // Special: [^/*]   (after a *, anything except / or * restarts the loop)
    // Close: \*/
    NSString *regex = @"/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/";

    // Simple comment
    NSString *code1 = @"int x; /* a comment */ int y;";
    NSString *match1 = [code1 stringMatchedByRegex:regex];
    XCTAssertEqualObjects(match1, @"/* a comment */");

    // Comment with stars inside
    NSString *code2 = @"/* stars ** inside *** here */";
    NSString *match2 = [code2 stringMatchedByRegex:regex];
    XCTAssertEqualObjects(match2, @"/* stars ** inside *** here */");

    // Multiple comments
    NSString *code3 = @"/* first */ code /* second */";
    NSArray<NSString *> *matches = [code3 substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"/* first */");
    XCTAssertEqualObjects(matches[1], @"/* second */");

    // Comment that starts with ** (like a doc comment)
    NSString *code4 = @"/** doc comment **/";
    NSString *match4 = [code4 stringMatchedByRegex:regex];
    XCTAssertEqualObjects(match4, @"/** doc comment **/");
}

#pragma mark - Unrolling the Loop: HTML Content

- (void)testUnrolledLoopHTMLContent
{
    // MRE3 pp.268-270: Unrolled loop for matching content between HTML tags
    // Extract text between <b> and </b>, handling other tags inside
    NSString *text = @"<b>bold <i>and italic</i> text</b> rest";

    // Using dotall lazy approach: <b>(.*?)</b>
    NSString *lazyMatch = [text stringMatchedByRegex:@"<b>(.*?)</b>" range:text.stringRange capture:1 options:RKXDotAll error:NULL];
    XCTAssertEqualObjects(lazyMatch, @"bold <i>and italic</i> text");

    // Using negated character class approach for simple cases: <b>([^<]*)</b>
    // This only works when there are no nested tags
    NSString *simpleText = @"<b>just bold</b> rest";
    NSString *negatedMatch = [simpleText stringMatchedByRegex:@"<b>([^<]*)</b>" capture:1];
    XCTAssertEqualObjects(negatedMatch, @"just bold");
}

#pragma mark - Leading Character Discrimination

- (void)testLeadingCharacterOptimization
{
    // MRE3 pp.245-248: Anchoring patterns with a literal start character helps
    // the engine skip positions that can't possibly match

    // Compare: this|that|other vs [to](?:his|hat|ther)
    // Both match the same strings, but the second has a single-char start for discrimination
    NSString *text = @"Find this and that and other things in the text";

    NSArray<NSString *> *matches1 = [text substringsMatchedByRegex:@"\\b(?:this|that|other)\\b"];
    NSArray<NSString *> *matches2 = [text substringsMatchedByRegex:@"\\b(?:th(?:is|at)|other)\\b"];

    // Both produce the same results
    XCTAssertEqual(matches1.count, matches2.count);
    XCTAssertEqual(matches1.count, 3);
    XCTAssertEqualObjects(matches1[0], matches2[0]);
    XCTAssertEqualObjects(matches1[1], matches2[1]);
    XCTAssertEqualObjects(matches1[2], matches2[2]);
}

- (void)testAnchoredPatternAvoidsFalseStarts
{
    // MRE3 p.247: Anchoring with ^ or \A avoids trying at every position
    NSString *text = @"Hello World 123";

    // Without anchor, engine tries at every position
    XCTAssertTrue([text isMatchedByRegex:@"Hello"]);

    // With anchor, engine only tries at position 0
    XCTAssertTrue([text isMatchedByRegex:@"^Hello"]);
    XCTAssertFalse([text isMatchedByRegex:@"^World"]);
}

#pragma mark - Exposing Literal Text

- (void)testExposingLiteralText
{
    // MRE3 pp.248-250: Making literal text visible to the engine's optimizer
    // Instead of (this|that), use th(?:is|at) -- exposes "th" as a fixed prefix
    NSString *text = @"this thing and that thing";

    // The factored version exposes common prefix "th"
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:@"\\bth(?:is|at)\\b"];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"this");
    XCTAssertEqualObjects(matches[1], @"that");

    // Similarly, instead of (?:com|org|net), use (?:com|org|net) factored when possible
    NSString *domains = @"foo.com bar.org baz.net qux.edu";
    NSArray<NSString *> *tlds = [domains substringsMatchedByRegex:@"\\.(?:com|org|net)\\b"];
    XCTAssertEqual(tlds.count, 3);
}

#pragma mark - Lazy vs Greedy Performance

- (void)testLazyMatchingWhenTargetIsNearStart
{
    // MRE3 pp.252-254: Lazy quantifier is faster when the target is near the beginning
    // (avoids consuming everything and backtracking)
    NSString *text = @"<title>Page Title</title> followed by lots of other content here that is very long indeed";

    // Lazy: stops at first </title>
    NSString *lazyMatch = [text stringMatchedByRegex:@"<title>(.*?)</title>" capture:1];
    XCTAssertEqualObjects(lazyMatch, @"Page Title");

    // Greedy with negated class: also efficient
    NSString *negatedMatch = [text stringMatchedByRegex:@"<title>([^<]*)</title>" capture:1];
    XCTAssertEqualObjects(negatedMatch, @"Page Title");

    // Both produce the same result
    XCTAssertEqualObjects(lazyMatch, negatedMatch);
}

- (void)testGreedyMatchingWhenTargetIsNearEnd
{
    // MRE3 pp.254-256: Greedy quantifier can be faster when the target is near the end
    NSString *text = @"lots of prefix content here before the tag <end>FOUND</end>";

    // Greedy with anchor: goes to end, backtracks to find <end>
    NSString *greedyMatch = [text stringMatchedByRegex:@".*<end>(.*?)</end>" capture:1];
    XCTAssertEqualObjects(greedyMatch, @"FOUND");
}

#pragma mark - Splitting Quantifiers

- (void)testSplitQuantifiersForClarity
{
    // MRE3 pp.257-259: Breaking up quantified groups for efficiency and clarity
    // Instead of (.{1,50}) for a limited-length match, be more specific

    // Match a "word" of 3 to 8 word characters
    NSString *text = @"a bb ccc dddd eeeee fffffffffff";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:@"\\b\\w{3,8}\\b"];
    XCTAssertEqual(matches.count, 3);
    XCTAssertEqualObjects(matches[0], @"ccc");
    XCTAssertEqualObjects(matches[1], @"dddd");
    XCTAssertEqualObjects(matches[2], @"eeeee");
    // "a" and "bb" are too short, "fffffffffff" is too long
}

#pragma mark - Atomic Grouping for Performance

- (void)testAtomicGroupingPreventsExponentialBacktracking
{
    // MRE3 pp.259-261: Atomic grouping prevents catastrophic backtracking
    // Example: matching a quoted string where the closing quote is missing

    // With a normal pattern on a non-matching string, backtracking can be expensive.
    // With atomic grouping, once the group matches, the engine doesn't try alternatives.

    // (?>regex) is the atomic group syntax
    // Test: possessive quantifier (equivalent to atomic group) on a pattern that matches
    NSString *text = @"\"properly quoted string\"";
    NSString *atomicRegex = @"\"[^\"]*+\"";
    NSString *normalRegex = @"\"[^\"]*\"";

    NSString *atomicMatch = [text stringMatchedByRegex:atomicRegex];
    NSString *normalMatch = [text stringMatchedByRegex:normalRegex];
    XCTAssertEqualObjects(atomicMatch, normalMatch);
    XCTAssertEqualObjects(atomicMatch, @"\"properly quoted string\"");
}

- (void)testAtomicGroupingFailsFastOnNoMatch
{
    // MRE3 p.260: When the overall match fails, atomic grouping fails faster
    // because it doesn't try backtracking alternatives

    // Missing closing quote: with atomic [^"]*+, engine tries all non-quotes,
    // locks them in, then fails at the closing " without backtracking
    NSString *noClose = @"\"no closing quote here";
    XCTAssertFalse([noClose isMatchedByRegex:@"^\"[^\"]*+\"$"]);
    XCTAssertFalse([noClose isMatchedByRegex:@"^\"[^\"]*\"$"]); // normal also fails, just slower

    // Atomic group with alternation: (?>one|two|three) fails fast
    XCTAssertFalse([@"four" isMatchedByRegex:@"^(?>one|two|three)$"]);
}

#pragma mark - Benchmark Equivalent Patterns

- (void)testEquivalentPatternsProduceSameResults
{
    // MRE3 pp.275-280: Different regex patterns that produce identical results
    // but may have different performance characteristics
    NSString *text = @"The quick brown fox jumps over the lazy dog.";

    // Pattern 1: Simple alternation
    NSArray<NSString *> *alt = [text substringsMatchedByRegex:@"\\b(?:quick|brown|lazy)\\b"];

    // Pattern 2: Character class start + alternation (better discrimination)
    NSArray<NSString *> *opt = [text substringsMatchedByRegex:@"\\b(?:[qb](?:uick|rown)|lazy)\\b"];

    XCTAssertEqual(alt.count, opt.count);
    XCTAssertEqual(alt.count, 3);
    for (NSUInteger i = 0; i < alt.count; i++) {
        XCTAssertEqualObjects(alt[i], opt[i]);
    }
}

- (void)testNegatedClassVsLazyDot
{
    // MRE3 p.276: [^x]*x is generally more efficient than .*?x
    // because [^x]* can't overshoot (no backtracking), while .*? extends one char at a time
    NSString *text = @"prefix:value:more:data";

    // Both find the same first colon-delimited segment
    NSString *negated = [text stringMatchedByRegex:@"^([^:]*):"];
    NSString *lazy = [text stringMatchedByRegex:@"^(.*?):"];
    XCTAssertEqualObjects(negated, lazy);
    XCTAssertEqualObjects(negated, @"prefix:");

    // Extract all colon-separated values using both approaches
    NSArray<NSString *> *parts1 = [text substringsSeparatedByRegex:@":"];
    XCTAssertEqual(parts1.count, 4);
    XCTAssertEqualObjects(parts1[0], @"prefix");
    XCTAssertEqualObjects(parts1[1], @"value");
    XCTAssertEqualObjects(parts1[2], @"more");
    XCTAssertEqualObjects(parts1[3], @"data");
}

#pragma mark - Avoiding Catastrophic Backtracking

- (void)testAvoidNestedQuantifiersOnOverlappingClasses
{
    // MRE3 pp.271-273: Nested quantifiers on overlapping character classes
    // can cause exponential backtracking
    // BAD: (\w+)+ -- nested quantifiers on overlapping class
    // GOOD: \w+ -- simple, no nesting

    // Both match the same thing when they succeed
    NSString *text = @"abcdef";
    NSString *bad = [text stringMatchedByRegex:@"^(\\w+)+$"];
    NSString *good = [text stringMatchedByRegex:@"^\\w+$"];
    XCTAssertEqualObjects(bad, good);
    XCTAssertEqualObjects(bad, @"abcdef");

    // With possessive quantifier, the nested version is safe
    // (\\w++)+ -- possessive inner quantifier prevents backtracking into it
    NSString *safe = [text stringMatchedByRegex:@"^(\\w++)+$"];
    XCTAssertEqualObjects(safe, @"abcdef");
}

- (void)testPossessiveQuantifiersForSafeNesting
{
    // MRE3 p.272: Possessive quantifiers make nested constructs safe
    // (?:[a-z]++\\.)*+[a-z]++ -- safe hostname pattern with possessive quantifiers
    NSString *hostname = @"www.example.com";
    NSString *regex = @"(?:[a-z]++\\.)*+[a-z]++";
    NSString *match = [hostname stringMatchedByRegex:regex options:RKXCaseless];
    XCTAssertEqualObjects(match, @"www.example.com");

    // With possessive *+, the outer group locks in all "prefix." segments greedily.
    // For "www.example.", the group consumes "www." then "example." (both match [a-z]++\.),
    // then [a-z]++ tries to match the empty remainder and fails.
    // Because *+ is possessive, it cannot give back "example." -- so the whole match fails.
    NSString *invalidHost = @"www.example.";
    NSString *partialMatch = [invalidHost stringMatchedByRegex:regex options:RKXCaseless];
    XCTAssertNil(partialMatch); // possessive quantifier prevents backtracking

    // But a non-possessive version would match by giving back the last "example." segment
    NSString *nonPossessiveRegex = @"(?:[a-z]++\\.)*[a-z]++";
    NSString *nonPossessiveMatch = [invalidHost stringMatchedByRegex:nonPossessiveRegex options:RKXCaseless];
    XCTAssertEqualObjects(nonPossessiveMatch, @"www.example");
}

#pragma mark - Comma Insertion (Number Formatting)

- (void)testCommaInsertionWithLookaround
{
    // MRE3 pp.277-279: Insert commas into numbers using lookahead and lookbehind
    // Pattern: (?<=\d)(?=(\d{3})+(?!\d)) matches positions for comma insertion
    NSString *number = @"1234567890";
    NSString *formatted = [number stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+(?!\\d))" withTemplate:@","];
    XCTAssertEqualObjects(formatted, @"1,234,567,890");

    // Works with various lengths
    NSString *short3 = @"123";
    NSString *formatted3 = [short3 stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+(?!\\d))" withTemplate:@","];
    XCTAssertEqualObjects(formatted3, @"123"); // no comma needed for 3 digits

    NSString *four = @"1234";
    NSString *formatted4 = [four stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+(?!\\d))" withTemplate:@","];
    XCTAssertEqualObjects(formatted4, @"1,234");

    NSString *seven = @"1234567";
    NSString *formatted7 = [seven stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+(?!\\d))" withTemplate:@","];
    XCTAssertEqualObjects(formatted7, @"1,234,567");
}

#pragma mark - Password Strength Validation with Multiple Lookaheads

- (void)testPasswordStrengthWithStackedLookaheads
{
    // MRE3 pp.279-280: Using multiple lookaheads at position zero to enforce
    // multiple independent conditions (like password strength rules)
    // At least 8 chars, at least one uppercase, one lowercase, one digit
    NSString *strongPassword = @"^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$";

    XCTAssertTrue([@"Password1" isMatchedByRegex:strongPassword]);
    XCTAssertTrue([@"MyP@ss99" isMatchedByRegex:strongPassword]);
    XCTAssertFalse([@"password" isMatchedByRegex:strongPassword]);  // no uppercase, no digit
    XCTAssertFalse([@"PASSWORD1" isMatchedByRegex:strongPassword]); // no lowercase
    XCTAssertFalse([@"Short1" isMatchedByRegex:strongPassword]);    // too short
    XCTAssertFalse([@"12345678" isMatchedByRegex:strongPassword]);  // no letters
}

- (void)testMultipleLookaheadConditions
{
    // MRE3 p.280: Stacked lookaheads as independent conditions at the same position
    // Match a word that contains both a vowel and a digit
    NSString *regex = @"\\b(?=\\S*[aeiou])(?=\\S*\\d)\\S+\\b";

    NSString *text = @"hello world h3llo w0rld test a1b pure 42";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex options:RKXCaseless];
    // "a1b" has vowel (a) and digit (1)
    XCTAssertTrue(matches.count >= 1);
    XCTAssertTrue([matches containsObject:@"a1b"]);
    XCTAssertTrue([@"a1b" isMatchedByRegex:regex options:RKXCaseless]);
    XCTAssertFalse([@"hello" isMatchedByRegex:regex options:RKXCaseless]); // no digit
    XCTAssertFalse([@"42" isMatchedByRegex:regex options:RKXCaseless]);    // no vowel
    XCTAssertTrue([@"h3ello" isMatchedByRegex:regex options:RKXCaseless]); // vowel 'e' and digit '3'
}

@end
