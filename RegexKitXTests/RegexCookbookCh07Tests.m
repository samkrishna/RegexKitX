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
{
    XCTFail(@"Not filled out yet");
}

#pragma mark - 7.8: Strings
{
    XCTFail(@"Not filled out yet");
}

#pragma mark - 7.9: Strings with Escapes
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection710
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection711
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection712
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection713
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection714
{
    XCTFail(@"Not filled out yet");
}

@end
