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

#pragma mark - Decimal Number Tests

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

#pragma mark - Hexadecimal Number Tests

- (void)testRegexFromSection62AnyHexNumber
{
    // Find any hex number in a larger body of text
    // \b[0-9A-F]+\b
    NSString *regex = @"\\b[0-9A-Fa-f]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BADF00D";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62JustAHexNumber
{
    // NOTE: All case-insensitive
    // Check whether a text string holds just a hexadecimal number:
    // ^[0-9A-F]+$

    // Find any hex number in a larger body of text
    // \b[0-9A-F]+\b
    NSString *regex = @"^[0-9A-Fa-f]+$";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BADF00D";
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexNumberWith0xPrefix
{
    // NOTE: All case-insensitive
    // Find a hexadecimal number with a 0x prefix:
    // \b0x[0-9A-F]+\b

    NSString *regex = @"\\b0x[0-9A-Fa-f]+\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 0xBADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0xBADF00D";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexNumberWithAmpersandHPrefix
{
    // Find a hexadecimal number with an &H prefix:
    // &H[0-9A-F]+\b

    NSString *regex = @"&H[0-9A-Fa-f]+\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, &HBADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"&HBADF00D";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}


- (void)testRegexFromSection62HexNumberWithAnHSuffix
{
    // Find a hexadecimal number with an H suffix:
    // \b[0-9A-F]+H\b

    NSString *regex = @"\\b[0-9A-Fa-f]+H\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, BADF00DH consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BADF00DH";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexByteOr8BitNumber
{
    // Find a hexadecimal byte value or 8-bit number:
    // \b[0-9A-F]{2}\b

    NSString *regex = @"\\b[0-9A-Fa-f]{2}\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, BA consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BA";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexWordValueOr16BitNumber
{
    // Find a hexadecimal word value or 16-bit number:
    // \b[0-9A-F]{4}\b

    NSString *regex = @"\\b[0-9A-Fa-f]{4}\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, BAfa consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BAfa";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexDoubleWordValueOr32BitNumber
{
    // Find a hexadecimal double word value or 32-bit number:
    // \b[0-9A-Fa-f]{8}\b

    NSString *regex = @"\\b[0-9A-Fa-f]{8}\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 1BADF00d consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithoutNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"1BADF00d";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithoutNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62HexQuadWordValueOr64BitNumber
{
    // Find a hexadecimal quad word value or 64-bit number:
    // \b[0-9A-Fa-f]{16}\b

    NSString *regex = @"\\b[0-9A-Fa-f]{16}\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1BADF00d2BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *anotherLipsumWithoutNumber = @"Lorem ipsum dolor sit amet, 1BADF00d consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"1BADF00d2BADF00D";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([anotherLipsumWithoutNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFromSection62StringOfHexadecimalBytes
{
    // Find a string of hexadecimal bytes (i.e., an even number of hexadecimal digits):
    // \b(?:[0-9A-F]{2})+\b

    NSString *regex = @"\\b(?:[0-9A-Fa-f]{2})+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1BADF00d2BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *anotherLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1BADF00d consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"1BADF00d2BADF00D";
    NSString *oddNumberOfHexadecimalDigits = @"1BADF00d2BADF00";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([anotherLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([oddNumberOfHexadecimalDigits isMatchedByRegex:regex]);
}


#pragma mark - Binary Number Tests

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

- (void)testBinaryRegexInLargerBodyOfText
{
    NSString *regex = @"\\b[01]+\\b";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 0b11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"11001001";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

#pragma mark - Octal Number Tests

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
