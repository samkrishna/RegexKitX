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
/*
    // Positive integer decimal numbers
    NSArray *regexes = @[ // Standing alone in a larger body of text
                          @"\\b[0-9]+\\b",
                          // Just a number
                          @"^[0-9]+$",
                          // Standing alone in larger body of text
                          @"(?<=^|\\s)[0-9]+(?=$|\\s)",
                          // Standing alone, leading whitespace to be included in match
                          @"(^|\\s)([0-9]+)(?=$|\\s)",
                          // Optional leading plus or minus sign
                          @"[+-]?\\b[0-9]+\\b",
                          // Exclusively number, with an optional leading plus or minussign?
                          @"^[+-]?[0-9]+$",
                          // Optional sign, allowing whitespace between the number and the sign,
                          // but no leading whitespaces without the sign
                          @"([+-] *)?\\b[0-9]+\\b" ];
*/

    // Impressive Regex: \[(\w+)(?<!\[NSDate date\]) usPacificTimestamp\]

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

- (void)testRegexFromSection63
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection64
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection65
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection66
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection67
{
    XCTFail(@"Not filled out yet");
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
