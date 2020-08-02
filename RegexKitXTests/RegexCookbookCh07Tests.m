//
//  RegexCookbookCh07Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh07Tests : XCTestCase

@end

@implementation RegexCookbookCh07Tests

#pragma mark - 7.1: Keywords

- (void)testNaiveRegexForKeywords
{
    // Keywords
    // \b(?:end|in|inline|inherited|item|object)\b
    NSString *regex = @"(?i)\\b(?:end|in|inline|inherited|item|object)\\b";

    NSString *shortLipsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithKeyword = @"Lorem ipsum dolor sit amet, in consectetur inline adipiscing elit. Nulla felis. end";

    XCTAssertFalse([shortLipsum isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWithKeyword isMatchedByRegex:regex]);
}

- (void)testBetterRegexForKeywords
{
    // Keywords
    // \b(end|in|inline|inherited|item|object)\b|'[^'\r\n]*(?:''[^'\r\n]*)*'
    NSString *regex = @"(?i)\\b(end|in|inline|inherited|item|object)\\b|'[^'\\r\\n]*(?:''[^'\\r\\n]*)*'";

    NSString *shortLipsumWithKeywordInQuote = @"Lorem ipsum dolor sit amet, \'in\' consectetur adipiscing elit. Nulla felis.";
    NSString *outcome = [shortLipsumWithKeywordInQuote stringMatchedByRegex:regex];
    XCTAssertTrue([outcome isEqualToString:@"\'in\'"]);
}

#pragma mark - 7.2: Identifiers

- (void)testRegexForIdentifiers
{
    // \b[a-z_][0-9a-z_]{0,31}\b
    NSString *regex = @"(?i)\\b[a-z_][0-9a-z_]{0,31}\\b";

    NSString *lipsumIdentifier = @"_Lorem ipsum dolor sit amet, in consectetur adipiscing elit. Nulla felis.";
    NSString *falseLipsumIdentifier = @"_Loremipsumdolorsitametinconsecteturadipiscingelit";
    XCTAssertTrue([lipsumIdentifier isMatchedByRegex:regex]);
    XCTAssertFalse([falseLipsumIdentifier isMatchedByRegex:regex]);
}

#pragma mark - 7.3: Numeric constants

- (void)testRegexForNumericConstants
{
    // Numeric Constants
    NSString *regex = @"(?xi)"
    "\\b(?:(?<dec>[1-9][0-9]*)"
    "| (?<oct>0[0-7]*)"
    "| 0x(?<hex>[0-9A-F]+)"
    "| 0b(?<bin>[01]+)"
    ")(?<L>L)?\\b";

    XCTAssertTrue([@"1101" isMatchedByRegex:regex]);
    XCTAssertTrue([@"1101L" isMatchedByRegex:regex]);
    XCTAssertFalse([@"1101M" isMatchedByRegex:regex]);
    XCTAssertTrue([@"0b1101" isMatchedByRegex:regex]);
    XCTAssertTrue([@"01234" isMatchedByRegex:regex]);
    XCTAssertTrue([@"0x1101" isMatchedByRegex:regex]);
}

#pragma mark - 7.4: Operators

- (void)testOperatorsRegex
{
    // Operators
    NSString *regex = @"[-+*/=<>%&^|!~?]";

    XCTAssertTrue([@"2 + 2 = 4" isMatchedByRegex:regex]);
    XCTAssertTrue([@"2 < 3" isMatchedByRegex:regex]);
}

#pragma mark - 7.5: Single-Line Comments

- (void)testRegexForSingleLineComments
{
    // Single-line comments
    NSString *regex = @"//.*";
    XCTAssertTrue([@"// this comment is useless" isMatchedByRegex:regex]);
}

#pragma mark - 7.6: Multiline Comments

- (void)testRegexMultilineComments
{
    // Multiline Comments
    NSString *regex = @"/\\*.*?\\*/";
    NSString *commentLine = @"/*\n"
    "This is a test.\n"
    "This is only a test.\n"
    "Of the emergencybroadcast system.*/";

    XCTAssertTrue([commentLine isMatchedByRegex:regex options:RKXDotAll]);
}

#pragma mark - 7.7: All Comments

- (void)testRegexForAllLines
{
    NSString *regex = @"(?-s://.*)|(?s:/\\*.*?\\*/)";
    NSString *commentLine = @"/*\n"
    "This is a test.\n"
    "This is only a test.\n"
    "Of the emergencybroadcast system.*/";
    NSString *singleLineComment = @"// this comment is useless";
    XCTAssertTrue([commentLine isMatchedByRegex:regex options:RKXDotAll]);
    XCTAssertTrue([singleLineComment isMatchedByRegex:regex]);
}

#pragma mark - 7.8: Strings

- (void)testRegexForStrings
{
    NSString *regex = @"\"[^\"\\r\\n]*(?:\"\"[^\"\\r\\n]*)*\"";
    NSString *sample = @"\"this is a test\" but is it reall?";
    XCTAssertTrue([sample isMatchedByRegex:regex]);
}

#pragma mark - 7.9: Strings with Escapes

- (void)testRegexForStringsWithEscapes
{
    NSString *regex = @"\"[^\"\\\r\n]*(?:.[^\"\\\r\n]*)\"";
    NSString *sample = @"\"No country\" \"for old men\"";
    XCTAssertTrue([sample isMatchedByRegex:regex]);
}

- (void)testRegexLiterals
{
    NSString *metaRegex = @"(?<=[=:(,](?:\\s{0,10}+!)?\\s{0,10})/[^/\\\r\n]*(?:\\.[^/\\\r\n]*)*/";
    NSString *regex = @"(?-s://.*)|(?s:/\\*.*?\\*/)";
    XCTAssertTrue([regex isMatchedByRegex:metaRegex]);
}

- (void)testHereDocumentRegex
{
    NSString *regex = @"<<([\"']?)([A-Za-z]+)\\b\\1.*?^\\2\\b";
    NSString *heredocFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"heredoc" ofType:@"txt"];
    NSString *heredocSample = [NSString stringWithContentsOfFile:heredocFilePath encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertTrue([heredocSample isMatchedByRegex:regex options:(RKXDotAll | RKXMultiline)]);
}

- (void)testRegexForCommonLogFormat
{
    NSString *regex = @"^(?<client>\\S+) \\S+ (?<userid>\\S+) \\[(?<datetime>[^\\]]+)\\] "
                        "\"(?<method>[A-Z]+) (?<request>[^ \"]+)? HTTP/[0-9.]+\" "
                        "(?<status>[0-9]{3}) (?<size>[0-9]+|-)";
    NSString *sample = @"127.0.0.1 - jg [27/Apr/2012:11:27:36 +0700] \"GET /regexcookbook.html HTTP/1.1\" 200 2326\"\n"
    "127.0.0.1 - sk [27/Apr/2012:11:27:36 +0700] \"GET /regexcookbook.html HTTP/1.1\" 200 2326\"";

    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXMultiline]);

    NSDictionary *dict = [sample dictionaryWithNamedCaptureKeysMatchedByRegex:regex options:RKXMultiline];
    XCTAssertNotNil(dict[@"client"]);
    XCTAssertNotNil(dict[@"userid"]);
    XCTAssertNotNil(dict[@"datetime"]);
    XCTAssertNotNil(dict[@"method"]);
    XCTAssertNotNil(dict[@"request"]);
    XCTAssertNotNil(dict[@"status"]);
    XCTAssertNotNil(dict[@"size"]);
}

- (void)testRegexForCombinedLogFormat
{
    NSString *regex = @"^(?<client>\\S+) \\S+ (?<userid>\\S+) \\[(?<datetime>[^\\]]+)\\] "
                        "\"(?<method>[A-Z]+) (?<request>[^ \"]+)? HTTP\\/[0-9.]+\" "
                        "(?<status>[0-9]{3}) (?<size>[0-9]+|-) \"(?<referrer>[^\"]*)\" "
                        "\"(?<useragent>[^\"]*)\"";
    NSString *sample = @"127.0.0.1 - jg [27/Apr/2012:11:27:36 +0700] \"GET /regexcookbook.html HTTP/1.1\" 200 2326 "
                        "\"http://www.regexcookbook.com/\" \"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)\"";

    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXMultiline]);

    NSDictionary *dict = [sample dictionaryWithNamedCaptureKeysMatchedByRegex:regex options:RKXMultiline];
    XCTAssertNotNil(dict[@"client"]);
    XCTAssertNotNil(dict[@"userid"]);
    XCTAssertNotNil(dict[@"datetime"]);
    XCTAssertNotNil(dict[@"method"]);
    XCTAssertNotNil(dict[@"request"]);
    XCTAssertNotNil(dict[@"status"]);
    XCTAssertNotNil(dict[@"size"]);
    XCTAssertNotNil(dict[@"referrer"]);
    XCTAssertNotNil(dict[@"useragent"]);
}

- (void)testRegexForBrokenLinks
{
    // NOTE: This is slightly modified to make it a bit more usable out-of-the-box
    // The prior regex versions used "www.yoursite.com" as a part of the "referrer" named capture group
    NSString *regex = @"^(?<client>\\S+) \\S+ (?<userid>\\S+) \\[(?<datetime>[^\\]]+)\\] "
                        "\"(?<method>[A-Z]+) (?<request>[^ \"]+)? HTTP\\/[0-9.]+ "
                        "(?<status>404) (?<size>[0-9]+|-) \"(?<referrer>http://(\\w+\\.?)+\\.com[^\"]*)\"";
    NSString *sample = @"127.0.0.1 - sk [27/Apr/2012:11:27:36 +0700] \"GET /regexcookbook.html HTTP/1.1 404 2326 "
                        "\"http://somebad.reference.from.badregexcookbook.com\"";

    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXMultiline]);

    NSDictionary *dict = [sample dictionaryWithNamedCaptureKeysMatchedByRegex:regex options:RKXMultiline];
    XCTAssertNotNil(dict[@"client"]);
    XCTAssertNotNil(dict[@"userid"]);
    XCTAssertNotNil(dict[@"datetime"]);
    XCTAssertNotNil(dict[@"method"]);
    XCTAssertNotNil(dict[@"request"]);
    XCTAssertNotNil(dict[@"status"]);
    XCTAssertNotNil(dict[@"size"]);
    XCTAssertNotNil(dict[@"referrer"]);
}

@end
