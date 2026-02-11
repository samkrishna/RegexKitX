//
//  MasteringRegexCh02Tests.m
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
// Chapter 2: Extended Introductory Examples (pp.35-81)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh02Tests : XCTestCase
@end

@implementation MasteringRegexCh02Tests

#pragma mark - Variable and Template Extraction

- (void)testVariableInterpolationExtraction
{
    // MRE3 p.44: Extracting variable references like $varName
    NSString *regex = @"\\$([a-zA-Z_]\\w*)";
    NSString *template = @"Hello $firstName, your ID is $userId_99 and balance is $balance.";

    NSArray<NSString *> *variables = [template substringsMatchedByRegex:regex capture:1];
    XCTAssertEqual(variables.count, 3);
    XCTAssertEqualObjects(variables[0], @"firstName");
    XCTAssertEqualObjects(variables[1], @"userId_99");
    XCTAssertEqualObjects(variables[2], @"balance");
}

- (void)testStockPricePattern
{
    // MRE3 p.44: Dollar amount matching with optional decimals
    NSString *regex = @"\\$[0-9]+(?:\\.[0-9]+)?";
    NSString *text = @"Stock prices: $100, $42.50, $3.99, and $0.01 per share.";

    NSArray<NSString *> *prices = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(prices.count, 4);
    XCTAssertEqualObjects(prices[0], @"$100");
    XCTAssertEqualObjects(prices[1], @"$42.50");
    XCTAssertEqualObjects(prices[2], @"$3.99");
    XCTAssertEqualObjects(prices[3], @"$0.01");
}

- (void)testFormLetterTemplateReplacement
{
    // MRE3 p.46: Replace template placeholders %name% with values
    NSString *template = @"Dear %NAME%, your order %ORDERID% ships on %DATE%.";
    NSString *result = template;
    result = [result stringByReplacingOccurrencesOfRegex:@"%NAME%" withTemplate:@"Alice"];
    result = [result stringByReplacingOccurrencesOfRegex:@"%ORDERID%" withTemplate:@"#12345"];
    result = [result stringByReplacingOccurrencesOfRegex:@"%DATE%" withTemplate:@"Monday"];
    XCTAssertEqualObjects(result, @"Dear Alice, your order #12345 ships on Monday.");

    // Also verify extraction of placeholder names using captures
    NSArray<NSString *> *placeholders = [template substringsMatchedByRegex:@"%(\\w+)%" capture:1];
    XCTAssertEqual(placeholders.count, 3);
    XCTAssertEqualObjects(placeholders[0], @"NAME");
    XCTAssertEqualObjects(placeholders[1], @"ORDERID");
    XCTAssertEqualObjects(placeholders[2], @"DATE");
}

#pragma mark - HTML and Tag Matching

- (void)testGreedyVsLazyHTMLTagMatching
{
    // MRE3 pp.47-48: Greedy matching grabs too much in HTML
    NSString *html = @"<b>bold</b> and <i>italic</i>";

    // Greedy <.*> overshoots: matches from first < to last >
    NSString *greedyMatch = [html stringMatchedByRegex:@"<.*>"];
    XCTAssertEqualObjects(greedyMatch, @"<b>bold</b> and <i>italic</i>");

    // Negated character class <[^>]*> is the proper approach
    NSArray<NSString *> *properTags = [html substringsMatchedByRegex:@"<[^>]*>"];
    XCTAssertEqual(properTags.count, 4);
    XCTAssertEqualObjects(properTags[0], @"<b>");
    XCTAssertEqualObjects(properTags[1], @"</b>");
    XCTAssertEqualObjects(properTags[2], @"<i>");
    XCTAssertEqualObjects(properTags[3], @"</i>");
}

#pragma mark - Quoted Strings

- (void)testQuotedStringWithEscapedQuotes
{
    // MRE3 p.64: Matching quoted strings that may contain escaped quotes
    // The "unrolled loop" pattern: "[^"\\]*(\\.[^"\\]*)*"
    NSString *regex = @"\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"";
    NSString *text = @"She said \"hello \\\"world\\\"\" and left.";

    NSString *match = [text stringMatchedByRegex:regex];
    XCTAssertEqualObjects(match, @"\"hello \\\"world\\\"\"");

    // Simple quoted string without escapes
    NSString *simple = @"The value is \"42\" today.";
    NSString *simpleMatch = [simple stringMatchedByRegex:regex];
    XCTAssertEqualObjects(simpleMatch, @"\"42\"");

    // Empty quoted string
    NSString *empty = @"Empty string is \"\" here.";
    NSString *emptyMatch = [empty stringMatchedByRegex:regex];
    XCTAssertEqualObjects(emptyMatch, @"\"\"");
}

#pragma mark - Continuation Lines

- (void)testContinuationLineMatching
{
    // MRE3 p.65: Lines ending with \ are continuation lines
    NSString *text = @"CFLAGS=-O2 \\\n  -Wall \\\n  -pedantic\nCC=gcc";
    NSString *regex = @"^.*\\\\\\n(?:.*\\\\\\n)*.*$";

    // Match the multi-line continuation block
    NSString *continuation = [text stringMatchedByRegex:regex options:RKXMultiline];
    XCTAssertTrue([continuation isMatchedByRegex:@"CFLAGS"]);
    XCTAssertTrue([continuation isMatchedByRegex:@"-pedantic"]);
}

#pragma mark - Path Splitting

- (void)testEnvironmentPathSplitting
{
    // MRE3 p.53: Splitting PATH-like strings by delimiter
    NSString *path = @"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    NSArray<NSString *> *components = [path substringsSeparatedByRegex:@":"];
    XCTAssertEqual(components.count, 5);
    XCTAssertEqualObjects(components[0], @"/usr/local/bin");
    XCTAssertEqualObjects(components[1], @"/usr/bin");
    XCTAssertEqualObjects(components[2], @"/bin");
    XCTAssertEqualObjects(components[3], @"/usr/sbin");
    XCTAssertEqualObjects(components[4], @"/sbin");
}

#pragma mark - Doubled Words

- (void)testDoubledWordAdvancedMultiline
{
    // MRE3 pp.69-71: Doubled words across line breaks (case-insensitive)
    NSString *regex = @"(?i)\\b(\\w+)\\s+\\1\\b";

    NSString *singleLine = @"This this is a test test of doubled words.";
    NSArray<NSString *> *matches = [singleLine substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);

    // Across a newline boundary
    NSString *multiLine = @"end of one\none line starts";
    NSString *doubledAcrossLines = [multiLine stringMatchedByRegex:regex];
    XCTAssertEqualObjects(doubledAcrossLines, @"one\none");

    // Verify capture group extracts the repeated word
    NSString *captured = [multiLine stringMatchedByRegex:regex capture:1];
    XCTAssertEqualObjects(captured, @"one");
}

#pragma mark - Lookahead

- (void)testNegativeLookaheadForRestriction
{
    // MRE3 pp.60-62: Negative lookahead (?!...) to exclude patterns
    // Match "cat" NOT followed by "erpillar" or "alog"
    NSString *regex = @"\\bcat(?!erpillar|alog)\\w*\\b";
    NSString *text = @"The cat chased the caterpillar past the catalog and catfish.";

    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"cat");
    XCTAssertEqualObjects(matches[1], @"catfish");
}

#pragma mark - Text Processing

- (void)testTextToHTMLParagraphConversion
{
    // MRE3 pp.73-76: Multi-step regex replacement chain for text-to-HTML
    NSString *text = @"Hello & welcome.\nThis is <great>.\n\nNew paragraph here.";

    // Step 1: Escape HTML entities
    NSString *step1 = [text stringByReplacingOccurrencesOfRegex:@"&" withTemplate:@"&amp;"];
    NSString *step2 = [step1 stringByReplacingOccurrencesOfRegex:@"<" withTemplate:@"&lt;"];
    NSString *step3 = [step2 stringByReplacingOccurrencesOfRegex:@">" withTemplate:@"&gt;"];

    XCTAssertTrue([step3 isMatchedByRegex:@"&amp;"]);
    XCTAssertTrue([step3 isMatchedByRegex:@"&lt;great&gt;"]);
    XCTAssertFalse([step3 isMatchedByRegex:@"<great>"]);

    // Step 2: Convert double newlines to paragraph breaks
    NSString *step4 = [step3 stringByReplacingOccurrencesOfRegex:@"\\n\\n" withTemplate:@"</p><p>"];
    XCTAssertTrue([step4 isMatchedByRegex:@"</p><p>"]);

    // Step 3: Convert remaining newlines to <br>
    NSString *step5 = [step4 stringByReplacingOccurrencesOfRegex:@"\\n" withTemplate:@"<br>"];
    XCTAssertTrue([step5 isMatchedByRegex:@"<br>"]);
    XCTAssertFalse([step5 isMatchedByRegex:@"\\n"]);
}

#pragma mark - IP Address Pattern

- (void)testMatchingDottedQuadsInText
{
    // MRE3 pp.69-70: IP-like dotted quad patterns in running text
    NSString *regex = @"\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b";
    NSString *text = @"Server at 192.168.1.1 and gateway 10.0.0.1, not 999.999.999.999 format.";

    NSArray<NSString *> *ips = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(ips.count, 3);
    XCTAssertEqualObjects(ips[0], @"192.168.1.1");
    XCTAssertEqualObjects(ips[1], @"10.0.0.1");
    XCTAssertEqualObjects(ips[2], @"999.999.999.999");

    // Use named captures to extract octets from the first IP
    NSString *octetRegex = @"\\b(?<first>\\d{1,3})\\.(?<second>\\d{1,3})\\.(?<third>\\d{1,3})\\.(?<fourth>\\d{1,3})\\b";
    NSDictionary *octets = [text dictionaryWithNamedCaptureKeysMatchedByRegex:octetRegex];
    XCTAssertEqualObjects(octets[@"first"], @"192");
    XCTAssertEqualObjects(octets[@"second"], @"168");
    XCTAssertEqualObjects(octets[@"third"], @"1");
    XCTAssertEqualObjects(octets[@"fourth"], @"1");
}

@end
