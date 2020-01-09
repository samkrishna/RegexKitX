//
//  RegexCookbookCh06Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh06Tests : XCTestCase

@end

@implementation RegexCookbookCh06Tests

- (void)testRegexFromSection61ForAnyPositiveIntegerInLargerBodyOfText
{
    NSString *numberInLargerBodyRegex = @"\\b[0-9]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"077";

    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:numberInLargerBodyRegex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:numberInLargerBodyRegex]);
}

- (void)testRegexFromSection61ForJustAPositiveIntegerDecimalNumber
{
    // Just a number
    NSString *regex = @"^[0-9]+$";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"077";

    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection61AltStandingAloneInALargerBodyOfText
{
    // Alternative standing alone in larger body of text
    NSString *regex = @"(?<=^|\\s)[0-9]+(?=$|\\s)";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithBogusNumber = @"Lorem ipsum dolor sit amet, 077consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"077";

    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithBogusNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection61StandingAloneWithLeadingWhitespace
{
    // Standing alone, leading whitespace to be included in match
    NSString *regex = @"(^|\\s)([0-9]+)(?=$|\\s)";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithBogusNumber = @"Lorem ipsum dolor sit amet, 077consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"077";

    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithBogusNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection61OptionalPlusMinusSign
{
    // Optional leading plus or minus sign
    NSString *regex = @"[+-]?\\b[0-9]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithPositiveSignedNumber = @"Lorem ipsum dolor sit amet, +077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNegativeSignedNumber = @"Lorem ipsum dolor sit amet, -077 consectetur adipiscing elit. Nulla felis.";

    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWithPositiveSignedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWithNegativeSignedNumber isMatchedByRegex:regex]);
}

- (void)testRegexFromSection61ExclusivelyNumberWithOptionalPlusMinusSign
{
    // Exclusively number, with an optional leading plus or minussign?
    NSString *regex = @"^[+-]?[0-9]+$";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithPositiveSignedNumber = @"Lorem ipsum dolor sit amet, +077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNegativeSignedNumber = @"Lorem ipsum dolor sit amet, -077 consectetur adipiscing elit. Nulla felis.";

    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithPositiveSignedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNegativeSignedNumber isMatchedByRegex:regex]);

    XCTAssertTrue([@"077" isMatchedByRegex:regex]);
    XCTAssertTrue([@"+077" isMatchedByRegex:regex]);
    XCTAssertTrue([@"-077" isMatchedByRegex:regex]);
}

- (void)testRegexFromSection61OptionalAllowingWhitespace
{
    // Optional sign, allowing whitespace between the number and the sign,
    // but no leading whitespaces without the sign
    NSString *regex = @"([+-] *)?\\b[0-9]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithPositiveSignedNumber = @"Lorem ipsum dolor sit amet, +077 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNegativeSignedNumber = @"Lorem ipsum dolor sit amet, -077 consectetur adipiscing elit. Nulla felis.";

    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWithPositiveSignedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWithNegativeSignedNumber isMatchedByRegex:regex]);

    XCTAssertTrue([@"077" isMatchedByRegex:regex]);
    XCTAssertTrue([@"+ 077" isMatchedByRegex:regex]);
    XCTAssertTrue([@"- 077" isMatchedByRegex:regex]);
}

- (void)testRegexFromSection68
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection69
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection610
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection611
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection612
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection613
{
    XCTFail(@"Not filled out yet");
}

@end
