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


- (void)testRegexFromSection72
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection73
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection74
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection75
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection76
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection77
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection78
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection79
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
