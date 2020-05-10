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

#pragma mark - Exercise 6.2: Hexadecimal Number Tests

- (void)testRegexWithAnyHexNumber
{
    // Find any hex number in a larger body of text
    // \b[0-9A-F]+\b
    NSString *regex = @"\\b[0-9A-Fa-f]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, BADF00D consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"BADF00D";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testRegexWithJustAHexNumber
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

- (void)testRegexWithHexNumberWith0xPrefix
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

- (void)testRegexWithHexNumberWithAmpersandHPrefix
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


- (void)testRegexWithHexNumberWithAnHSuffix
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

- (void)testRegexWithHexByteOr8BitNumber
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

- (void)testRegexWithHexWordValueOr16BitNumber
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

- (void)testRegexWithHexDoubleWordValueOr32BitNumber
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

- (void)testRegexWithHexQuadWordValueOr64BitNumber
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

- (void)testRegexWithStringOfHexadecimalBytes
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


#pragma mark - Exercise 6.3: Binary Number Tests

- (void)testBinaryRegexInLargerBodyOfText
{
    NSString *regex = @"\\b[01]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 0b11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"11001001";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexForJustABinaryNumber
{
    // Check whether a text string holds just a binary number
    // ^[01]+$
    NSString *regex = @"^[01]+$";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 0b11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"11001001";
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexWithPrefix
{
    // Find a binary number with a 0b prefix:
    // \b0b[01]+\b

    NSString *regex = @"\\b0b[01]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithPrefixedNumber = @"Lorem ipsum dolor sit amet, 0b11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0b11001001";
    XCTAssertTrue([shortLipsumWithPrefixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexWithSuffix
{
    // Find a binary number with a B suffix:
    // \b[01]+B\b

    NSString *regex = @"\\b[01]+B\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithSuffixedNumber = @"Lorem ipsum dolor sit amet, 11001001B consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"11001001B";
    XCTAssertTrue([shortLipsumWithSuffixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexWith8BitNumber
{
    // Find a binary byte value or 8-bit number:
    // \b[01]{8}\b

    NSString *regex = @"\\b[01]{8}\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 11001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithSuffixedNumber = @"Lorem ipsum dolor sit amet, 11001001B consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"11001001B";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithSuffixedNumber isMatchedByRegex:regex]);
    XCTAssertFalse([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexWith16BitNumber
{
    // Find a binary word value or 16-bit number:
    // \b[01]{16}\b

    NSString *regex = @"\\b[01]{16}\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1100100111001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithSuffixedNumber = @"Lorem ipsum dolor sit amet, 1100100111001001B consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"1100100111001001";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithSuffixedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}

- (void)testBinaryRegexWithMultipleBytes
{
    // Find a string of bytes (i.e., a multiple of eight bits):
    // \b(?:[01]{8})+\b

    NSString *regex = @"\\b(?:[01]{8})+\\b";
    NSString *shortLipsumWith2ByteNumber = @"Lorem ipsum dolor sit amet, 1100100111001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWith3ByteNumber = @"Lorem ipsum dolor sit amet, 110010011100100111001001 consectetur adipiscing elit. Nulla felis.";
    NSString *shortLipsumWithSuffixedNumber = @"Lorem ipsum dolor sit amet, 1100100111001001B consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"1100100111001001";
    XCTAssertTrue([shortLipsumWith2ByteNumber isMatchedByRegex:regex]);
    XCTAssertTrue([shortLipsumWith3ByteNumber isMatchedByRegex:regex]);
    XCTAssertFalse([shortLipsumWithSuffixedNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
}


#pragma mark - Octal Number Tests

- (void)testOctalRegex
{
    // Find an octal number in a larger body of text:
    // \b0[0-7]*\b

    NSString *regex = @"\\b0[0-7]*\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 01253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"01253";
    NSString *failedNumberOnly = @"01258";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([failedNumberOnly isMatchedByRegex:regex]);
}

- (void)testOctalRegexForOnlyNumber
{
    // Check whether a text string holds just an octal number:
    // ^0[0-7]*$

    NSString *regex = @"^0[0-7]*$";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 01253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"01253";
    NSString *failedNumberOnly = @"01258";
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([failedNumberOnly isMatchedByRegex:regex]);
}

- (void)testOctalRegexWith0oPrefix
{
    // Find an octal number with a 0o prefix:
    // \b0o[0-7]+\b

    NSString *regex = @"\\b0o[0-7]+\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 0o01253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0o01253";
    NSString *failedNumberOnly = @"01258";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([failedNumberOnly isMatchedByRegex:regex]);
}

#pragma mark - Decimal Number Tests

- (void)testRegexFindingAnyPositiveDecimalIntegerNumberWithoutALeadingZero
{
    // Find any positive integer decimal number without a leading zero in a larger body of text:
    // \b(0|[1-9][0-9]*)\b

    NSString *regex = @"\\b(0|[1-9][0-9]*)\\b";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0";
    NSString *failedNumberOnly = @"01258";
    XCTAssertTrue([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([failedNumberOnly isMatchedByRegex:regex]);
}

- (void)testRegexFindingJustAnyPositiveDecimalIntegerNumberWithoutALeadingZero
{
    // Check whether a text string holds just a positive integer decimal number without a leading zero:
    // ^(0|[1-9][0-9]*)$

    NSString *regex = @"^(0|[1-9][0-9]*)$";
    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 1253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0";
    NSString *failedNumberOnly = @"01258";
    XCTAssertFalse([shortLipsumWithNumber isMatchedByRegex:regex]);
    XCTAssertTrue([numberOnly isMatchedByRegex:regex]);
    XCTAssertFalse([failedNumberOnly isMatchedByRegex:regex]);
}

#pragma mark - Strip Leading Zeros

- (void)testRegexForStrippingLeadingZeros
{
    NSString *regex = @"\\b0*([1-9][0-9]*|0)\\b";
    NSString *postProcessRegex = @"\\b([1-9][0-9]*|0)\\b";

    NSString *shortLipsumWithNumber = @"Lorem ipsum dolor sit amet, 0781253 consectetur adipiscing elit. Nulla felis.";
    NSString *numberOnly = @"0781253";
    NSString *lipsumOutput = [shortLipsumWithNumber stringByReplacingOccurrencesOfRegex:regex withTemplate:@"$1"];
    NSString *processedNumber = [numberOnly stringByReplacingOccurrencesOfRegex:regex withTemplate:@"$1"];
    XCTAssertTrue([lipsumOutput isMatchedByRegex:postProcessRegex]);
    XCTAssertTrue([processedNumber isMatchedByRegex:postProcessRegex]);
}

#pragma mark - Numbers Within a Certain Range

- (void)testRegexFromSection67
{

    // 1900 to 2099 (year):
    // ^(19|20)[0-9]{2}$

    // 0 to 32767 (nonnegative signed word):
    // ^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|[12][0-9]{4}|↵
    // [1-9][0-9]{1,3}|[0-9])$

    // –32768 to 32767 (signed word):
    // ^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|[12][0-9]{4}|↵
    // [1-9][0-9]{1,3}|[0-9]|-(3276[0-8]|327[0-5][0-9]|32[0-6][0-9]{2}|↵
    // 3[01][0-9]{3}|[12][0-9]{4}|[1-9][0-9]{1,3}|[0-9]))$

    // 0 to 65535 (unsigned word):
    // ^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|↵
    // [1-9][0-9]{1,3}|[0-9])$
    XCTFail(@"Not filled out yet");
}

- (void)testRegexForHourOrMonth
{
    // 1 to 12 (hour or month):
    // ^(1[0-2]|[1-9])$
    NSString *regex = @"^(1[0-2]|[1-9])$";

    XCTAssertTrue([@"10" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertFalse([@"-1" isMatchedByRegex:regex]);
}

- (void)testRegexFor24Hour
{
    // 1 to 24 (hour):
    // ^(2[0-4]|1[0-9]|[1-9])$

    NSString *regex = @"^(2[0-4]|1[0-9]|[1-9])$";

    XCTAssertTrue([@"10" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertFalse([@"25" isMatchedByRegex:regex]);
}


- (void)testRegexForDayOfMonth
{
    // 1 to 31 (day of the month):
    // ^(3[01]|[12][0-9]|[1-9])$

    NSString *regex = @"^(3[01]|[12][0-9]|[1-9])$";

    XCTAssertTrue([@"10" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"25" isMatchedByRegex:regex]);
    XCTAssertFalse([@"32" isMatchedByRegex:regex]);
}

- (void)testRegexForWeekOFYear
{
    // 1 to 53 (week of the year):
    // ^(5[0-3]|[1-4][0-9]|[1-9])$
    NSString *regex = @"^(5[0-3]|[1-4][0-9]|[1-9])$";

    XCTAssertTrue([@"10" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"25" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertFalse([@"54" isMatchedByRegex:regex]);
}

- (void)testRegexForMinuteOrSecond
{
    // 0 to 59 (minute or second):
    // ^[1-5]?[0-9]$
    NSString *regex = @"^[1-5]?[0-9]$";

    XCTAssertTrue([@"10" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"25" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertTrue([@"54" isMatchedByRegex:regex]);
    XCTAssertFalse([@"60" isMatchedByRegex:regex]);
}

- (void)testRegexFor0to100Percentage
{
    // 0 to 100 (percentage):
    // ^(100|[1-9]?[0-9])$

    NSString *regex = @"^(100|[1-9]?[0-9])$";

    XCTAssertTrue([@"0" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"21" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertTrue([@"54" isMatchedByRegex:regex]);
    XCTAssertFalse([@"101" isMatchedByRegex:regex]);

}

- (void)testRegexFor1to100Range
{
    // 1 to 100:
    // ^(100|[1-9][0-9]?)$
    NSString *regex = @"^(100|[1-9][0-9]?)$";

    XCTAssertFalse([@"0" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"25" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertTrue([@"54" isMatchedByRegex:regex]);
    XCTAssertFalse([@"101" isMatchedByRegex:regex]);
}

- (void)testRegexForPrintableASCIICodes
{
    // 32 to 126 (printable ASCII codes):
    // ^(12[0-6]|1[01][0-9]|[4-9][0-9]|3[2-9])$
    NSString *regex = @"^(12[0-6]|1[01][0-9]|[4-9][0-9]|3[2-9])$";

    XCTAssertFalse([@"0" isMatchedByRegex:regex]);
    XCTAssertFalse([@"7" isMatchedByRegex:regex]);
    XCTAssertFalse([@"24" isMatchedByRegex:regex]);
    XCTAssertFalse([@"25" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertTrue([@"54" isMatchedByRegex:regex]);
    XCTAssertTrue([@"101" isMatchedByRegex:regex]);
    XCTAssertFalse([@"127" isMatchedByRegex:regex]);
}

- (void)testRegexForNonnegativeSignedBytes
{
    // 0 to 127 (nonnegative signed byte):
    // ^(12[0-7]|1[01][0-9]|[1-9]?[0-9])$
    NSString *regex = @"^(12[0-7]|1[01][0-9]|[1-9]?[0-9])$";

    XCTAssertFalse([@"-1" isMatchedByRegex:regex]);
    XCTAssertTrue([@"7" isMatchedByRegex:regex]);
    XCTAssertTrue([@"24" isMatchedByRegex:regex]);
    XCTAssertTrue([@"25" isMatchedByRegex:regex]);
    XCTAssertTrue([@"52" isMatchedByRegex:regex]);
    XCTAssertTrue([@"54" isMatchedByRegex:regex]);
    XCTAssertTrue([@"101" isMatchedByRegex:regex]);
    XCTAssertTrue([@"127" isMatchedByRegex:regex]);
    XCTAssertFalse([@"128" isMatchedByRegex:regex]);
}

- (void)testRegexForSignedBytes
{
    // –128 to 127 (signed byte):
    // ^(12[0-7]|1[01][0-9]|[1-9]?[0-9]|-(12[0-8]|1[01][0-9]|[1-9]?[0-9]))$
    NSString *regex = @"^(12[0-7]|1[01][0-9]|[1-9]?[0-9]|-(12[0-8]|1[01][0-9]|[1-9]?[0-9]))$";

    for (NSInteger i = -150; i < 200; i++) {
        if (i < -128 || i > 127) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForUnsignedBytes
{
    // 0 to 255 (unsigned byte):
    // ^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$
    NSString *regex = @"^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$";

    for (NSInteger i = -129; i < 300; i++) {
        if (i < 0 || i > 255) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForDaysOfYear
{
    // :1 to 366 (day of the year):
    // ^(36[0-6]|3[0-5][0-9]|[12][0-9]{2}|[1-9][0-9]?)$
    NSString *regex = @"^(36[0-6]|3[0-5][0-9]|[12][0-9]{2}|[1-9][0-9]?)$";

    for (NSInteger i = -5; i < 371; i++) {
        if (i < 1 || i > 366) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}
}

#pragma mark - Hexadecimal Numbers Within a Certain Range

#pragma mark - Integer Numbers with Separators

#pragma mark - Floating Point Numbers

#pragma mark - Numbers with Thousand Separators

#pragma mark - Add Thousand Separators to Numbers

#pragma mark - Roman Numerals


@end
