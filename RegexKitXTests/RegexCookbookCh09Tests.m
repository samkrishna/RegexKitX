//
//  RegexCookbookCh09Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh09Tests : XCTestCase

@end

@implementation RegexCookbookCh09Tests

- (void)testQuickRegexForAttributeMatchingFrom91
{
    NSString *quickRegex = @"<[^>]*>";
    NSString *sample = @"<title>Boring</title>";
    NSString *attribute = [sample stringMatchedByRegex:quickRegex];
    XCTAssertTrue([attribute isEqualToString:@"<title>"]);

    NSString *betterRegex = @"(?x)"
                             "<"
                             "(?: [^>\"'] # Non-quoted character\n"
                             "| \"[^\"]*\" # Double-quoted attribute value\n"
                             "| '[^']*' # Single-quoted attribute value\n"
                             ")*"
                             ">";
    NSString *betterSample = @"<title<<whoa>>>Coolness</title>";
    NSString *betterAttribute = [betterSample stringMatchedByRegex:betterRegex];
    XCTAssertTrue([betterAttribute isEqualToString:@"<title<<whoa>"]);
}

- (void)testRegexFromSection92
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection93
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection94
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection95
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection96
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection97
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection98
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection99
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection910
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection911
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection912
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection913
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection914
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection915
{
    XCTFail(@"Not filled out yet");
}

@end
