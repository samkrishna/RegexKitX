//
//  RegexCookbookCh05Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh05Tests : XCTestCase

@end

@implementation RegexCookbookCh05Tests


- (void)testRegexFromSection51
{
    NSString *testString = @"Get me a cat and a dog!";
    XCTAssert([testString isMatchedByRegex:@"\\bcat\\b" options:RKXCaseless]);
}

- (void)testRegexFromSection52
{
    NSString *subject = @"One times two plus one equals three.";
    NSString *regex = @"\\b(?:one|two|three)\\b";
    XCTAssertTrue([subject isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexFromSection53
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection54
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection55
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection56
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection57
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection58
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection59
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection510
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection511
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection512
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection513
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection514
{
    XCTFail(@"Not filled out yet");
}

@end
