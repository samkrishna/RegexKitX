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

- (void)testRegexFromSection62Hexadecimals
{
    // NOTE: All case-insensitive
    // Find any hex number in a larger body of text
    // \b[0-9A-F]+\b
    // Check whether a text string holds just a hexadecimal number:
    // \A[0-9A-F]+\Z
    // Find a hexadecimal number with a 0x prefix:
    // \b0x[0-9A-F]+\b
    // Find a hexadecimal number with an &H prefix:
    // &H[0-9A-F]+\b
    // Find a hexadecimal number with an H suffix:
    // \b[0-9A-F]+H\b
    // Find a hexadecimal byte value or 8-bit number:
    // \b[0-9A-F]{2}\b
    // Find a hexadecimal word value or 16-bit number:
    // \b[0-9A-F]{4}\b
    // Find a hexadecimal double word value or 32-bit number:
    // \b[0-9A-F]{8}\b
    // Find a hexadecimal quad word value or 64-bit number:
    // \b[0-9A-F]{16}\b
    // Find a string of hexadecimal bytes (i.e., an even number of hexadecimal digits):
    // \b(?:[0-9A-F]{2})+\b
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection63BinaryNumbers
{
    // NOTE: All case-insensitive
    // Find a binary number in a larger body of text:
    // \b[01]+\b
    // Check whether a text string holds just a binary number
    // ^[01]+$
    // Find a binary number with a 0b prefix:
    // \b0b[01]+\b
    // Find a binary number with a B suffix:
    // \b[01]+B\b
    // Find a binary byte value or 8-bit number:
    // \b[01]{8}\b
    // Find a binary word value or 16-bit number:
    // \b[01]{16}\b
    // Find a string of bytes (i.e., a multiple of eight bits):
    // \b(?:[01]{8})+\b
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection64OctalNumbers
{
    // All case-insensitive
    // Find an octal number in a larger body of text:
    // \b0[0-7]*\b
    // Check whether a text string holds just an octal number:
    // ^0[0-7]*$
    // Find an octal number with a 0o prefix:
    // \b0o[0-7]+\b
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection65DecimalNumbers
{
    // Find any positive integer decimal number without a leading zero in a larger body of text:
    // \b(0|[1-9][0-9]*)\b
    // Check whether a text string holds just a positive integer decimal number without a leading zero:
    // ^(0|[1-9][0-9]*)$
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
