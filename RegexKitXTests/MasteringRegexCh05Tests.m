//
//  MasteringRegexCh05Tests.m
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
// Chapter 5: Practical Regex Techniques (pp.185-219)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh05Tests : XCTestCase
@end

@implementation MasteringRegexCh05Tests

#pragma mark - Delimited Strings

- (void)testDelimitedSingleQuotedString
{
    // MRE3 p.196: Simple single-quoted string
    NSString *simpleRegex = @"'[^']*'";
    NSString *text = @"She said 'hello' and 'goodbye' to us.";
    NSArray<NSString *> *matches = [text substringsMatchedByRegex:simpleRegex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"'hello'");
    XCTAssertEqualObjects(matches[1], @"'goodbye'");

    // MRE3 p.198: Escape-aware single-quoted string (unrolled loop)
    NSString *escapeRegex = @"'[^'\\\\]*(\\\\.[^'\\\\]*)*'";
    NSString *escaped = @"She said 'it\\'s fine' and 'ok'.";
    NSArray<NSString *> *escMatches = [escaped substringsMatchedByRegex:escapeRegex];
    XCTAssertEqual(escMatches.count, 2);
    XCTAssertEqualObjects(escMatches[0], @"'it\\'s fine'");
    XCTAssertEqualObjects(escMatches[1], @"'ok'");
}

- (void)testDelimitedDoubleQuotedString
{
    // MRE3 p.198: Double-quoted string with unrolled loop for escaped chars
    NSString *regex = @"\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"";
    NSString *text = @"config = \"path\\\\to\\\\file\" and name = \"hello \\\"world\\\"\"";

    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"\"path\\\\to\\\\file\"");
    XCTAssertEqualObjects(matches[1], @"\"hello \\\"world\\\"\"");
}

#pragma mark - Balanced Parentheses

- (void)testBalancedParenthesesOneLevel
{
    // MRE3 p.200: Match single-level balanced parentheses
    NSString *regex = @"\\([^()]*\\)";
    NSString *text = @"func(a, b) + calc(x + y)";

    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"(a, b)");
    XCTAssertEqualObjects(matches[1], @"(x + y)");

    // Should not match nested parens at top level
    NSString *nested = @"func(a, (b + c))";
    NSArray<NSString *> *nestedMatches = [nested substringsMatchedByRegex:regex];
    // Only matches the inner (b + c) since outer has nested parens
    XCTAssertEqual(nestedMatches.count, 1);
    XCTAssertEqualObjects(nestedMatches[0], @"(b + c)");
}

- (void)testBalancedParenthesesTwoLevels
{
    // MRE3 p.200: Two-level nested parentheses
    NSString *regex = @"\\([^()]*(?:\\([^()]*\\)[^()]*)*\\)";
    NSString *text = @"func(a, (b + c)) and calc(x)";

    NSArray<NSString *> *matches = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(matches.count, 2);
    XCTAssertEqualObjects(matches[0], @"(a, (b + c))");
    XCTAssertEqualObjects(matches[1], @"(x)");
}

#pragma mark - HTML Tag Matching

- (void)testHTMLTagWithAttributes
{
    // MRE3 p.201: Matching HTML tags with attributes
    NSString *regex = @"<(\\w+)(?:\\s+\\w+(?:\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^'\">\\s]+))?)*\\s*/?>";
    NSString *text = @"<div class=\"main\" id='content'> and <br/> and <img src=\"pic.jpg\" alt=\"A photo\">";

    NSArray<NSString *> *tags = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(tags.count, 3);
    XCTAssertTrue([tags[0] isMatchedByRegex:@"^<div"]);
    XCTAssertEqualObjects(tags[1], @"<br/>");

    // Extract tag names using capture group
    NSArray<NSString *> *tagNames = [text substringsMatchedByRegex:regex capture:1];
    XCTAssertEqual(tagNames.count, 3);
    XCTAssertEqualObjects(tagNames[0], @"div");
    XCTAssertEqualObjects(tagNames[1], @"br");
    XCTAssertEqualObjects(tagNames[2], @"img");
}

- (void)testHTMLLinkHrefExtraction
{
    // MRE3 p.203: Extract href attribute from anchor tags
    NSString *regex = @"<a\\b[^>]*\\bhref\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')";
    NSString *html = @"Visit <a href=\"https://example.com\" class=\"link\">Example</a> or <a class='x' href='https://other.org'>Other</a>.";

    NSArray<NSArray *> *captures = [html arrayOfCaptureSubstringsMatchedByRegex:regex];
    XCTAssertEqual(captures.count, 2);
    // First link: double-quoted href in capture 1
    XCTAssertEqualObjects(captures[0][1], @"https://example.com");
    // Second link: single-quoted href in capture 2
    XCTAssertEqualObjects(captures[1][2], @"https://other.org");
}

#pragma mark - C Comment Matching

- (void)testCCommentMatchingVariants
{
    // MRE3 pp.204-205: Matching C-style /* ... */ comments
    // Unrolled loop: /\*[^*]*\*+([^/*][^*]*\*+)*/
    NSString *unrolledRegex = @"/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/";

    NSString *code = @"int x = 1; /* first comment */ int y = 2; /* second ** comment */";
    NSArray<NSString *> *comments = [code substringsMatchedByRegex:unrolledRegex];
    XCTAssertEqual(comments.count, 2);
    XCTAssertEqualObjects(comments[0], @"/* first comment */");
    XCTAssertEqualObjects(comments[1], @"/* second ** comment */");

    // Multi-line comment
    NSString *multiline = @"/* this\nspans\nlines */ code /* short */";
    NSArray<NSString *> *mlComments = [multiline substringsMatchedByRegex:unrolledRegex options:RKXDotAll];
    XCTAssertEqual(mlComments.count, 2);
    XCTAssertTrue([mlComments[0] isMatchedByRegex:@"spans"]);
    XCTAssertEqualObjects(mlComments[1], @"/* short */");

    // Verify it does not match across two separate comments
    NSString *separated = @"/* one */ code /* two */";
    NSArray<NSString *> *sepComments = [separated substringsMatchedByRegex:unrolledRegex];
    XCTAssertEqual(sepComments.count, 2);
}

#pragma mark - Filename Extraction

- (void)testUnixFilenameExtraction
{
    // MRE3 p.206: Extract filename from Unix path
    NSString *filenameRegex = @"([^/]+)$";
    NSString *path = @"/usr/local/bin/program";
    NSString *filename = [path stringMatchedByRegex:filenameRegex capture:1];
    XCTAssertEqualObjects(filename, @"program");

    // Extract file extension
    NSString *extRegex = @"\\.([^./]+)$";
    NSString *filePath = @"/home/user/document.txt";
    NSString *extension = [filePath stringMatchedByRegex:extRegex capture:1];
    XCTAssertEqualObjects(extension, @"txt");

    // File with multiple dots
    NSString *multiDot = @"/var/log/app.2024.01.log";
    NSString *ext = [multiDot stringMatchedByRegex:extRegex capture:1];
    XCTAssertEqualObjects(ext, @"log");

    // No extension
    NSString *noExt = @"/usr/bin/make";
    NSString *noExtResult = [noExt stringMatchedByRegex:extRegex capture:1];
    XCTAssertNil(noExtResult);
}

#pragma mark - Continuation Lines

- (void)testContinuationLines
{
    // MRE3 p.207: Joining continuation lines (lines ending with backslash)
    // Build the string with literal backslash-newline sequences
    // "OBJS=foo.o \<newline>  bar.o \<newline>  baz.o<newline>CC=gcc"
    NSString *text = [NSString stringWithFormat:@"OBJS=foo.o %C\n  bar.o %C\n  baz.o\nCC=gcc", (unichar)'\\', (unichar)'\\'];

    // Replace whitespace-backslash-newline-whitespace to join continuation lines
    NSString *regex = @"\\s*\\\\\\n\\s*";
    NSString *joined = [text stringByReplacingOccurrencesOfRegex:regex withTemplate:@" "];
    XCTAssertTrue([joined isMatchedByRegex:@"OBJS=foo\\.o bar\\.o baz\\.o"]);
    XCTAssertTrue([joined isMatchedByRegex:@"CC=gcc"]);
    XCTAssertFalse([joined isMatchedByRegex:@"\\\\"]);
}

#pragma mark - Paragraph Matching

- (void)testParagraphMatching
{
    // MRE3 p.208: Paragraphs separated by blank lines
    NSString *text = @"First paragraph\nstill first.\n\nSecond paragraph\nstill second.\n\nThird.";
    NSArray<NSString *> *paragraphs = [text substringsSeparatedByRegex:@"\\n\\n"];
    XCTAssertEqual(paragraphs.count, 3);
    XCTAssertTrue([paragraphs[0] isMatchedByRegex:@"First paragraph"]);
    XCTAssertTrue([paragraphs[0] isMatchedByRegex:@"still first"]);
    XCTAssertTrue([paragraphs[1] isMatchedByRegex:@"Second paragraph"]);
    XCTAssertEqualObjects(paragraphs[2], @"Third.");
}

#pragma mark - Hostname Extraction

- (void)testHostnameExtractionFromText
{
    // MRE3 p.209: Extracting hostnames from text
    NSString *regex = @"\\b(?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\\.)+[a-z]{2,}\\b";
    NSString *text = @"Visit www.example.com or mail server mail.example.org for info. Also see docs.sub.domain.co.uk.";

    NSArray<NSString *> *hostnames = [text substringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssertEqual(hostnames.count, 3);
    XCTAssertEqualObjects(hostnames[0], @"www.example.com");
    XCTAssertEqualObjects(hostnames[1], @"mail.example.org");
    XCTAssertEqualObjects(hostnames[2], @"docs.sub.domain.co.uk");

    // Should not match bare words or IPs
    XCTAssertFalse([@"localhost" isMatchedByRegex:regex]);
}

@end
