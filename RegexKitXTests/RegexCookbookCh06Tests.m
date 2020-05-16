//
//  RegexCookbookCh06Tests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 10/14/19.
 Copyright © 2019 Sam Krishna. All rights reserved.

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

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh06Tests : XCTestCase

@end

@implementation RegexCookbookCh06Tests

#pragma mark - 6.1: Decimal Number Tests

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

#pragma mark - 6.2: Hexadecimal Number Tests

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


#pragma mark - 6.3: Binary Number Tests

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


#pragma mark - 6.4: Octal Number Tests

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

#pragma mark - 6.5: Decimal Number Tests

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

#pragma mark - 6.6: Strip Leading Zeros

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

#pragma mark - 6.7: Numbers Within a Certain Range

- (void)testRegexForHourOrMonth
{
    // 1 to 12 (hour or month):
    // ^(1[0-2]|[1-9])$
    NSString *regex = @"^(1[0-2]|[1-9])$";

    for (NSInteger i = -5; i < 20; i++) {
        if (i < 1 || i > 12) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexFor24Hour
{
    // 1 to 24 (hour):
    // ^(2[0-4]|1[0-9]|[1-9])$

    NSString *regex = @"^(2[0-4]|1[0-9]|[1-9])$";

    for (NSInteger i = -20; i < 40; i++) {
        if (i < 1 || i > 24) {
            XCTAssertFalse([[@(i) description] isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([[@(i) description] isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}


- (void)testRegexForDayOfMonth
{
    // 1 to 31 (day of the month):
    // ^(3[01]|[12][0-9]|[1-9])$

    NSString *regex = @"^(3[01]|[12][0-9]|[1-9])$";

    for (NSInteger i = -129; i < 300; i++) {
        if (i < 1 || i > 31) {
            XCTAssertFalse([[@(i) description] isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([[@(i) description] isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForWeekOFYear
{
    // 1 to 53 (week of the year):
    // ^(5[0-3]|[1-4][0-9]|[1-9])$
    NSString *regex = @"^(5[0-3]|[1-4][0-9]|[1-9])$";

    for (NSInteger i = -25; i < 60; i++) {
        if (i < 1 || i > 53) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForMinuteOrSecond
{
    // 0 to 59 (minute or second):
    // ^[1-5]?[0-9]$
    NSString *regex = @"^[1-5]?[0-9]$";

    for (NSInteger i = -25; i < 200; i++) {
        if (i < 0 || i > 59) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexFor0to100Percentage
{
    // 0 to 100 (percentage):
    // ^(100|[1-9]?[0-9])$

    NSString *regex = @"^(100|[1-9]?[0-9])$";

    for (NSInteger i = -25; i < 300; i++) {
        if (i < 0 || i > 100) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexFor1to100Range
{
    // 1 to 100:
    // ^(100|[1-9][0-9]?)$
    NSString *regex = @"^(100|[1-9][0-9]?)$";

    for (NSInteger i = -25; i < 300; i++) {
        if (i < 1 || i > 100) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForPrintableASCIICodes
{
    // 32 to 126 (printable ASCII codes):
    // ^(12[0-6]|1[01][0-9]|[4-9][0-9]|3[2-9])$
    NSString *regex = @"^(12[0-6]|1[01][0-9]|[4-9][0-9]|3[2-9])$";

    for (NSInteger i = -25; i < 300; i++) {
        if (i < 32 || i > 126) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForNonnegativeSignedBytes
{
    // 0 to 127 (nonnegative signed byte):
    // ^(12[0-7]|1[01][0-9]|[1-9]?[0-9])$
    NSString *regex = @"^(12[0-7]|1[01][0-9]|[1-9]?[0-9])$";

    for (NSInteger i = -25; i < 300; i++) {
        if (i < 0 || i > 127) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
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

- (void)testRegexFor20thAnd21stCenturies
{
    // 1900 to 2099 (year):
    // ^(19|20)[0-9]{2}$
    NSString *regex = @"^(19|20)[0-9]{2}$";

    for (NSInteger i = 1850; i < 2205; i++) {
        if (i < 1900 || i > 2099) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForNonnegativeSignedWord
{
    // 0 to 32767 (nonnegative signed word):
    // ^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|[12][0-9]{4}|[1-9][0-9]{1,3}|[0-9])$
    NSString *regex = @"^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|"
    "[12][0-9]{4}|[1-9][0-9]{1,3}|[0-9])$";

    for (NSInteger i = -50; i < 35000; i++) {
        if (i < 0 || i > 32767) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForSignedWord
{
    // –32768 to 32767 (signed word):
    // ^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|[12][0-9]{4}|↵
    // [1-9][0-9]{1,3}|[0-9]|-(3276[0-8]|327[0-5][0-9]|32[0-6][0-9]{2}|↵
    // 3[01][0-9]{3}|[12][0-9]{4}|[1-9][0-9]{1,3}|[0-9]))$
    NSString *regex = @"^(3276[0-7]|327[0-5][0-9]|32[0-6][0-9]{2}|3[01][0-9]{3}|[12][0-9]{4}|"
    "[1-9][0-9]{1,3}|[0-9]|-(3276[0-8]|327[0-5][0-9]|32[0-6][0-9]{2}|"
    "3[01][0-9]{3}|[12][0-9]{4}|[1-9][0-9]{1,3}|[0-9]))$";

    for (NSInteger i = -40000; i < 40000; i++) {
        if (i < -32768 || i > 32767) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForUnsignedWord
{
    // 0 to 65535 (unsigned word):
    // ^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|↵
    // [1-9][0-9]{1,3}|[0-9])$
    NSString *regex = @"^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9]{2}|6[0-4][0-9]{3}|[1-5][0-9]{4}|"
    "[1-9][0-9]{1,3}|[0-9])$";

    for (NSInteger i = -1000; i < 70000; i++) {
        if (i < 0 || i > 65535) {
            XCTAssertFalse([@(i).description isMatchedByRegex:regex], @"%ld IS matching somehow", i);
        }
        else {
            XCTAssertTrue([@(i).description isMatchedByRegex:regex], @"%ld IS NOT matching somehow", i);
        }
    }
}

#pragma mark - 6.8: Hexadecimal Numbers Within a Certain Range

- (void)testHexRangesFromSection68
{
    // 0 to FF (0 to 255: 8-bit number):
    // ^[1-9a-f]?[0-9a-f]$
    //
    // 1 to 16E (1 to 366: day of the year):
    // ^(16[0-9a-e]|1[0-5][0-9a-f]|[1-9a-f][0-9a-f]?)$
    //
    // 76C to 833 (1900 to 2099: year):
    // ^(83[0-3]|8[0-2][0-9a-f]|7[7-9a-f][0-9a-f]|76[c-f])$
    //
    // 0 to 7FFF: (0 to 32767: 15-bit number):
    // ^([1-7][0-9a-f]{3}|[1-9a-f][0-9a-f]{1,2}|[0-9a-f])$
    //
    // 0 to FFFF: (0 to 65535: 16-bit number):
    // ^([1-9a-f][0-9a-f]{1,3}|[0-9a-f])$

    XCTAssertTrue(NO, @"Not implemented yet");
}

- (void)testHexIteration
{
    // 1 to C (1 to 12: hour or month):
    // ^[1-9a-c]$

    // Use this link to elucidate hex printing with the 'z' or 't' 
    // https://useyourloaf.com/blog/format-string-issue-using-nsinteger/
    NSString *regex = @"^[1-9a-c]$";

    for (NSInteger i = -10; i < 0xf; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x1  || i > 0xc) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHex24Hour
{
    // 1 to 18 (1 to 24: hour):
    // ^(1[0-8]|[1-9a-f])$
    NSString *regex = @"^(1[0-8]|[1-9a-f])$";

    for (NSInteger i = -20; i < 40; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x1 || i > 0x18) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHexDayOfMonth
{
    // 1 to 1F (1 to 31: day of the month):
    // ^(1[0-9a-f]|[1-9a-f])$
    NSString *regex = @"^(1[0-9a-f]|[1-9a-f])$";

    for (NSInteger i = -129; i < 300; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x1 || i > 0x1f) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHexWeekOFYear
{
    // 1 to 35 (1 to 53: week of the year):
    // ^(3[0-5]|[12][0-9a-f]|[1-9a-f])$
    NSString *regex = @"^(3[0-5]|[12][0-9a-f]|[1-9a-f])$";

    for (NSInteger i = -25; i < 60; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x1 || i > 0x35) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHexMinuteOrSecond
{
    // 0 to 3B (0 to 59: minute or second):
    // ^(3[0-9a-b]|[12]?[0-9a-f])$
    NSString *regex = @"^(3[0-9a-b]|[12]?[0-9a-f])$";

    for (NSInteger i = -25; i < 200; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x0 || i > 0x3b) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHex0to100Percentage
{
    // 0 to 64 (0 to 100: percentage):
    // ^(6[0-4]|[1-5]?[0-9a-f])$
    NSString *regex = @"^(6[0-4]|[1-5]?[0-9a-f])$";

    for (NSInteger i = -25; i < 300; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x0 || i > 0x64) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHex1to100Range
{
    // 1 to 64 (1 to 100):
    // ^(6[0-4]|[1-5][0-9a-f]|[1-9a-f])$
    NSString *regex = @"^(6[0-4]|[1-5][0-9a-f]|[1-9a-f])$";

    for (NSInteger i = -25; i < 300; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x1 || i > 0x64) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHexPrintableASCIICodes
{
    // 20 to 7E (32 to 126: printable ASCII codes):
    // ^(7[0-9a-e]|[2-6][0-9a-f])$
    NSString *regex = @"^(7[0-9a-e]|[2-6][0-9a-f])$";

    for (NSInteger i = -25; i < 300; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x20 || i > 0x7e) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}

- (void)testRegexForHex7BitNumber
{
    // 0 to 7F (0 to 127: 7-bit number):
    // ^[1-7]?[0-9a-f]$
    NSString *regex = @"^[1-7]?[0-9a-f]$";

    for (NSInteger i = -25; i < 300; i++) {
        NSString *testString = [NSString stringWithFormat:@"%zx", i];

        if (i < 0x0 || i > 0x7f) {
            XCTAssertFalse([testString isMatchedByRegex:regex], @"%zx IS matching somehow", i);
        }
        else {
            XCTAssertTrue([testString isMatchedByRegex:regex], @"%zx IS NOT matching somehow", i);
        }
    }
}
#pragma mark - 6.9: Integer Numbers with Separators

#pragma mark - 6.10: Floating Point Numbers

#pragma mark - 6.11: Numbers with Thousand Separators

#pragma mark - 6.12: Add Thousand Separators to Numbers

#pragma mark - 6.13: Roman Numerals


@end
