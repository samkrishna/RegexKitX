//
//  RegexKitXEnhancementsTests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 2/16/26.
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

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexKitXEnhancementsTests : XCTestCase
@end

@implementation RegexKitXEnhancementsTests

#pragma mark - countOfRegex:

- (void)testCountOfRegexZeroMatches
{
    NSString *string = @"Hello World";
    NSUInteger count = [string countOfRegex:@"\\d+"];
    XCTAssertEqual(count, 0UL);
}

- (void)testCountOfRegexOneMatch
{
    NSString *string = @"Hello 42 World";
    NSUInteger count = [string countOfRegex:@"\\d+"];
    XCTAssertEqual(count, 1UL);
}

- (void)testCountOfRegexManyMatches
{
    NSString *string = @"one 1 two 2 three 3 four 4 five 5";
    NSUInteger count = [string countOfRegex:@"\\d+"];
    XCTAssertEqual(count, 5UL);
}

- (void)testCountOfRegexWithRange
{
    NSString *string = @"aaa bbb aaa bbb aaa";
    NSRange searchRange = NSMakeRange(0, 7); // "aaa bbb"
    NSUInteger count = [string countOfRegex:@"aaa" range:searchRange];
    XCTAssertEqual(count, 1UL);
}

- (void)testCountOfRegexWithOptions
{
    NSString *string = @"Hello HELLO hello";
    NSUInteger count = [string countOfRegex:@"hello" options:RKXCaseless];
    XCTAssertEqual(count, 3UL);
}

- (void)testCountOfRegexFullOverload
{
    NSString *string = @"abc ABC Abc";
    NSUInteger count = [string countOfRegex:@"abc" range:string.stringRange options:RKXCaseless matchOptions:kNilOptions error:NULL];
    XCTAssertEqual(count, 3UL);
}

#pragma mark - firstMatchOfRegex:

- (void)testFirstMatchOfRegexBasic
{
    NSString *string = @"foo 123 bar 456";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"\\d+"];
    XCTAssertNotNil(match);
    XCTAssertEqual(match.range.location, 4UL);
    XCTAssertEqual(match.range.length, 3UL);
}

- (void)testFirstMatchOfRegexNoMatch
{
    NSString *string = @"Hello World";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"\\d+"];
    XCTAssertNil(match);
}

- (void)testFirstMatchOfRegexWithCaptures
{
    NSString *string = @"2026-02-16";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"(\\d{4})-(\\d{2})-(\\d{2})"];
    XCTAssertNotNil(match);
    XCTAssertEqual(match.numberOfRanges, 4UL);
    NSRange yearRange = [match rangeAtIndex:1];
    XCTAssertEqualObjects([string substringWithRange:yearRange], @"2026");
}

- (void)testFirstMatchOfRegexWithNamedCaptures
{
    NSString *string = @"John Smith, age 30";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"(?<name>\\w+ \\w+), age (?<age>\\d+)"];
    XCTAssertNotNil(match);
    if (@available(macOS 10.13, *)) {
        NSRange nameRange = [match rangeWithName:@"name"];
        XCTAssertEqualObjects([string substringWithRange:nameRange], @"John Smith");
        NSRange ageRange = [match rangeWithName:@"age"];
        XCTAssertEqualObjects([string substringWithRange:ageRange], @"30");
    }
}

- (void)testFirstMatchOfRegexWithRange
{
    NSString *string = @"123 456 789";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"\\d+" range:NSMakeRange(4, 7)];
    XCTAssertNotNil(match);
    XCTAssertEqual(match.range.location, 4UL);
}

- (void)testFirstMatchOfRegexWithOptions
{
    NSString *string = @"HELLO world";
    NSTextCheckingResult *match = [string firstMatchOfRegex:@"hello" options:RKXCaseless];
    XCTAssertNotNil(match);
    XCTAssertEqual(match.range.location, 0UL);
}

@end
