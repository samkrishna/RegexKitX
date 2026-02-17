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
@import AppKit;
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

#pragma mark - Regex Cache Management

- (void)testRegexCacheCount
{
    [NSString clearRegexCache];
    NSUInteger initialCount = [NSString regexCacheCount];
    XCTAssertEqual(initialCount, 0UL);

    // Trigger caching by matching
    [@"test" isMatchedByRegex:@"test"];
    NSUInteger afterOneCount = [NSString regexCacheCount];
    XCTAssertEqual(afterOneCount, 1UL);

    [@"test" isMatchedByRegex:@"\\w+"];
    NSUInteger afterTwoCount = [NSString regexCacheCount];
    XCTAssertEqual(afterTwoCount, 2UL);
}

- (void)testClearRegexCache
{
    // Ensure cache has entries
    [@"test" isMatchedByRegex:@"cache_test_pattern_1"];
    [@"test" isMatchedByRegex:@"cache_test_pattern_2"];
    XCTAssertGreaterThan([NSString regexCacheCount], 0UL);

    [NSString clearRegexCache];
    XCTAssertEqual([NSString regexCacheCount], 0UL);
}

- (void)testCacheSamePatternNotDuplicated
{
    [NSString clearRegexCache];
    [@"hello" isMatchedByRegex:@"hello"];
    [@"world" isMatchedByRegex:@"hello"];
    XCTAssertEqual([NSString regexCacheCount], 1UL);
}

#pragma mark - regexValidationError

- (void)testRegexValidationErrorValidPattern
{
    NSError *error = [@"\\d+" regexValidationError];
    XCTAssertNil(error);
}

- (void)testRegexValidationErrorInvalidPattern
{
    NSError *error = [@"[invalid" regexValidationError];
    XCTAssertNotNil(error);
}

- (void)testRegexValidationErrorInvalidPatternHasDescription
{
    NSError *error = [@"(?<" regexValidationError];
    XCTAssertNotNil(error);
    XCTAssertNotNil(error.localizedDescription);
    XCTAssertGreaterThan(error.localizedDescription.length, 0UL);
}

- (void)testRegexValidationErrorWithOptions
{
    NSError *error = [@"hello world" regexValidationErrorWithOptions:RKXNoOptions];
    XCTAssertNil(error);

    error = [@"hello   world" regexValidationErrorWithOptions:RKXIgnoreWhitespace];
    XCTAssertNil(error);
}

- (void)testRegexValidationErrorUnbalancedParenthesis
{
    NSError *error = [@"(unbalanced" regexValidationError];
    XCTAssertNotNil(error);
}

- (void)testRegexValidationErrorComplexValidPattern
{
    NSError *error = [@"(?:(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2}))" regexValidationError];
    XCTAssertNil(error);
}

#pragma mark - arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:

- (void)testArrayOfDictionariesWithNamedCaptureKeysBasic
{
    NSString *string = @"John:30 Jane:25 Bob:40";
    NSString *pattern = @"(?<name>\\w+):(?<age>\\d+)";
    NSArray<NSDictionary<NSString *, NSString *> *> *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:pattern];
    XCTAssertEqual(results.count, 3UL);
    XCTAssertEqualObjects(results[0][@"name"], @"John");
    XCTAssertEqualObjects(results[0][@"age"], @"30");
    XCTAssertEqualObjects(results[1][@"name"], @"Jane");
    XCTAssertEqualObjects(results[1][@"age"], @"25");
    XCTAssertEqualObjects(results[2][@"name"], @"Bob");
    XCTAssertEqualObjects(results[2][@"age"], @"40");
}

- (void)testArrayOfDictionariesWithNamedCaptureKeysNoMatch
{
    NSString *string = @"no matches here";
    NSString *pattern = @"(?<digit>\\d+)";
    NSArray *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:pattern];
    XCTAssertNotNil(results);
    XCTAssertEqual(results.count, 0UL);
}

- (void)testArrayOfDictionariesWithNamedCaptureKeysNoNamedGroups
{
    NSString *string = @"abc 123";
    NSString *pattern = @"\\d+"; // No named capture groups
    NSArray *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:pattern];
    XCTAssertNotNil(results);
    XCTAssertEqual(results.count, 0UL);
}

- (void)testArrayOfDictionariesWithNamedCaptureKeysWithRange
{
    NSString *string = @"a:1 b:2 c:3";
    NSString *pattern = @"(?<key>\\w):(?<val>\\d)";
    NSArray *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:pattern range:NSMakeRange(0, 7)]; // "a:1 b:2"
    XCTAssertEqual(results.count, 2UL);
}

- (void)testArrayOfDictionariesWithNamedCaptureKeysWithOptions
{
    NSString *string = @"Name:ALICE Name:BOB";
    NSString *pattern = @"name:(?<person>\\w+)";
    NSArray *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:pattern options:RKXCaseless];
    XCTAssertEqual(results.count, 2UL);
    XCTAssertEqualObjects(results[0][@"person"], @"ALICE");
}

- (void)testArrayOfDictionariesWithNamedCaptureKeysInvalidRegex
{
    NSString *string = @"test";
    NSError *error = nil;
    NSArray *results = [string arrayOfDictionariesWithNamedCaptureKeysMatchedByRegex:@"(?<broken" range:string.stringRange options:RKXNoOptions error:&error];
    XCTAssertNil(results);
    XCTAssertNotNil(error);
}

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlockWithNamedCaptures:

- (void)testReplacingWithNamedCaptureBlockBasic
{
    NSString *string = @"John:30 Jane:25";
    NSString *pattern = @"(?<name>\\w+):(?<age>\\d+)";
    NSString *result = [string stringByReplacingOccurrencesOfRegex:pattern usingBlockWithNamedCaptures:^NSString *(NSDictionary<NSString *,NSString *> *namedCaptures, BOOL *stop) {
        return [NSString stringWithFormat:@"%@ (age %@)", namedCaptures[@"name"], namedCaptures[@"age"]];
    }];
    XCTAssertEqualObjects(result, @"John (age 30) Jane (age 25)");
}

- (void)testReplacingWithNamedCaptureBlockNoMatch
{
    NSString *string = @"Hello World";
    NSString *result = [string stringByReplacingOccurrencesOfRegex:@"(?<digit>\\d+)" usingBlockWithNamedCaptures:^NSString *(NSDictionary<NSString *,NSString *> *namedCaptures, BOOL *stop) {
        return @"REPLACED";
    }];
    XCTAssertEqualObjects(result, @"Hello World");
}

- (void)testReplacingWithNamedCaptureBlockStopFlag
{
    NSString *string = @"a:1 b:2 c:3";
    NSString *pattern = @"(?<key>\\w):(?<val>\\d)";
    __block NSUInteger callCount = 0;
    NSString *result = [string stringByReplacingOccurrencesOfRegex:pattern usingBlockWithNamedCaptures:^NSString *(NSDictionary<NSString *,NSString *> *namedCaptures, BOOL *stop) {
        callCount++;
        *stop = YES;
        return [NSString stringWithFormat:@"%@=%@", namedCaptures[@"key"], namedCaptures[@"val"]];
    }];
    // Block uses reverse iteration, so stop after first (last match becomes first processed)
    XCTAssertEqual(callCount, 1UL);
    // The last match (c:3) gets replaced since we iterate in reverse
    XCTAssertTrue([result containsString:@"c=3"]);
}

- (void)testReplacingWithNamedCaptureBlockWithOptions
{
    NSString *string = @"KEY:value";
    NSString *pattern = @"(?<k>key):(?<v>\\w+)";
    NSString *result = [string stringByReplacingOccurrencesOfRegex:pattern options:RKXCaseless usingBlockWithNamedCaptures:^NSString *(NSDictionary<NSString *,NSString *> *namedCaptures, BOOL *stop) {
        return [NSString stringWithFormat:@"%@->%@", namedCaptures[@"k"], namedCaptures[@"v"]];
    }];
    XCTAssertEqualObjects(result, @"KEY->value");
}

#pragma mark - substringsSeparatedByRegex:limit:

- (void)testSplitWithLimitZeroUnlimited
{
    NSString *string = @"a,b,c,d,e";
    NSArray *result = [string substringsSeparatedByRegex:@"," limit:0];
    XCTAssertEqual(result.count, 5UL);
    XCTAssertEqualObjects(result[0], @"a");
    XCTAssertEqualObjects(result[4], @"e");
}

- (void)testSplitWithLimitOne
{
    NSString *string = @"a,b,c";
    NSArray *result = [string substringsSeparatedByRegex:@"," limit:1];
    XCTAssertEqual(result.count, 1UL);
    XCTAssertEqualObjects(result[0], @"a,b,c");
}

- (void)testSplitWithLimitTwo
{
    NSString *string = @"a,b,c,d";
    NSArray *result = [string substringsSeparatedByRegex:@"," limit:2];
    XCTAssertEqual(result.count, 2UL);
    XCTAssertEqualObjects(result[0], @"a");
    XCTAssertEqualObjects(result[1], @"b,c,d");
}

- (void)testSplitWithLimitThree
{
    NSString *string = @"one::two::three::four";
    NSArray *result = [string substringsSeparatedByRegex:@"::" limit:3];
    XCTAssertEqual(result.count, 3UL);
    XCTAssertEqualObjects(result[0], @"one");
    XCTAssertEqualObjects(result[1], @"two");
    XCTAssertEqualObjects(result[2], @"three::four");
}

- (void)testSplitWithLimitGreaterThanMatches
{
    NSString *string = @"a-b-c";
    NSArray *result = [string substringsSeparatedByRegex:@"-" limit:10];
    XCTAssertEqual(result.count, 3UL);
}

- (void)testSplitWithLimitNoMatch
{
    NSString *string = @"no delimiters here";
    NSArray *result = [string substringsSeparatedByRegex:@"," limit:3];
    XCTAssertEqual(result.count, 1UL);
    XCTAssertEqualObjects(result[0], @"no delimiters here");
}

- (void)testSplitWithLimitAndRange
{
    NSString *string = @"a,b,c,d,e";
    NSArray *result = [string substringsSeparatedByRegex:@"," range:NSMakeRange(0, 5) limit:2]; // "a,b,c"
    XCTAssertEqual(result.count, 2UL);
    XCTAssertEqualObjects(result[0], @"a");
    XCTAssertEqualObjects(result[1], @"b,c");
}

- (void)testSplitWithLimitAndOptions
{
    NSString *string = @"aSEPbSEPcSEPd";
    NSArray *result = [string substringsSeparatedByRegex:@"sep" options:RKXCaseless limit:3];
    XCTAssertEqual(result.count, 3UL);
    XCTAssertEqualObjects(result[0], @"a");
    XCTAssertEqualObjects(result[1], @"b");
    XCTAssertEqualObjects(result[2], @"cSEPd");
}

- (void)testSplitWithLimitRegexDelimiter
{
    NSString *string = @"word1   word2\tword3\nword4";
    NSArray *result = [string substringsSeparatedByRegex:@"\\s+" limit:3];
    XCTAssertEqual(result.count, 3UL);
    XCTAssertEqualObjects(result[0], @"word1");
    XCTAssertEqualObjects(result[1], @"word2");
    XCTAssertEqualObjects(result[2], @"word3\nword4");
}

#pragma mark - NSAttributedString Support

- (void)testAttributedStringReplacement
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"Hello 123 World 456"];
    NSAttributedString *result = [attrStr attributedStringByReplacingOccurrencesOfRegex:@"\\d+" withTemplate:@"NUM"];
    XCTAssertEqualObjects(result.string, @"Hello NUM World NUM");
}

- (void)testAttributedStringReplacementNoMatch
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"Hello World"];
    NSAttributedString *result = [attrStr attributedStringByReplacingOccurrencesOfRegex:@"\\d+" withTemplate:@"NUM"];
    XCTAssertEqualObjects(result.string, @"Hello World");
}

- (void)testAttributedStringReplacementWithOptions
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"Hello WORLD hello"];
    NSAttributedString *result = [attrStr attributedStringByReplacingOccurrencesOfRegex:@"hello" withTemplate:@"HI" options:RKXCaseless];
    XCTAssertEqualObjects(result.string, @"HI WORLD HI");
}

- (void)testAttributedStringReplacementWithRange
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"aaa bbb aaa"];
    NSAttributedString *result = [attrStr attributedStringByReplacingOccurrencesOfRegex:@"aaa" withTemplate:@"X" range:NSMakeRange(0, 3) options:RKXNoOptions error:NULL];
    XCTAssertEqualObjects(result.string, @"X bbb aaa");
}

- (void)testAttributedStringEnumerateMatches
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"one 1 two 2 three 3"];
    __block NSUInteger matchCount = 0;
    [attrStr enumerateMatchesForRegex:@"\\d+" usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        matchCount++;
    }];
    XCTAssertEqual(matchCount, 3UL);
}

- (void)testMutableAttributedStringAddAttributesForMatches
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"Hello 123 World 456"];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName: [NSColor redColor] };
    [attrStr addAttributes:attrs forMatchesOfRegex:@"\\d+"];

    // Check that attributes were applied to "123" (range 6-9)
    NSDictionary *attrsAt6 = [attrStr attributesAtIndex:6 effectiveRange:NULL];
    XCTAssertNotNil(attrsAt6[NSForegroundColorAttributeName]);

    // Check that attributes were NOT applied to "Hello" (range 0)
    NSDictionary *attrsAt0 = [attrStr attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertNil(attrsAt0[NSForegroundColorAttributeName]);
}

- (void)testMutableAttributedStringAddAttributesForMatchesWithOptions
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"hello HELLO"];
    NSDictionary *attrs = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    [attrStr addAttributes:attrs forMatchesOfRegex:@"hello" range:attrStr.string.stringRange options:RKXCaseless error:NULL];

    NSDictionary *attrsAt0 = [attrStr attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertNotNil(attrsAt0[NSUnderlineStyleAttributeName]);

    NSDictionary *attrsAt6 = [attrStr attributesAtIndex:6 effectiveRange:NULL];
    XCTAssertNotNil(attrsAt6[NSUnderlineStyleAttributeName]);
}

- (void)testAttributedStringReplacementPreservesAttributes
{
    NSDictionary *boldAttrs = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:12] };
    NSMutableAttributedString *mutableAttr = [[NSMutableAttributedString alloc] initWithString:@"Hello 123 World"];
    [mutableAttr addAttributes:boldAttrs range:NSMakeRange(0, 5)]; // Bold "Hello"

    NSAttributedString *result = [mutableAttr attributedStringByReplacingOccurrencesOfRegex:@"\\d+" withTemplate:@"NUM"];
    XCTAssertEqualObjects(result.string, @"Hello NUM World");

    // "Hello" should still have bold attributes
    NSDictionary *resultAttrs = [result attributesAtIndex:0 effectiveRange:NULL];
    XCTAssertNotNil(resultAttrs[NSFontAttributeName]);
}

#pragma mark - Thread Safety

- (void)testConcurrentRegexOperations
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSUInteger successCount = 0;
    NSUInteger iterations = 100;

    for (NSUInteger i = 0; i < iterations; i++) {
        dispatch_group_async(group, queue, ^{
            NSString *string = [NSString stringWithFormat:@"Thread test %lu with number 42", (unsigned long)i];
            BOOL matched = [string isMatchedByRegex:@"\\d+"];
            if (matched) {
                @synchronized (self) {
                    successCount++;
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertEqual(successCount, iterations);
}

- (void)testConcurrentDifferentPatterns
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSArray *patterns = @[@"\\d+", @"[a-z]+", @"\\w+", @"\\s+", @"[A-Z]+"];
    NSString *testString = @"Hello World 123 FOO bar";
    __block NSUInteger successCount = 0;

    for (NSString *pattern in patterns) {
        dispatch_group_async(group, queue, ^{
            NSUInteger count = [testString countOfRegex:pattern];
            if (count > 0) {
                @synchronized (self) {
                    successCount++;
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertEqual(successCount, 5UL);
}

@end
