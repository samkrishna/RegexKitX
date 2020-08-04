//
//  RegexCookbookCh08Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh08Tests : XCTestCase

@end

@implementation RegexCookbookCh08Tests

- (void)testAllowsAlmostAnyURLRegex
{
    NSString *allowAlmostAnyURLRegex = @"^(https?|ftp|file):\\/\\/.+$";
    NSString *httpSample = @"http://example.com";
    NSString *ftpSample = @"http://example.com";
    NSString *fileSample = @"http://example.com";
    XCTAssertTrue([httpSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
    XCTAssertTrue([ftpSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
    XCTAssertTrue([fileSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
}

- (void)testRegexFromSection82
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection83
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection84
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection85
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection86
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection87
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection88
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection89
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection810
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection811
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection812
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection813
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection814
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection815
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection816
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection817
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection818
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection819
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection820
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection821
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection822
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection823
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection824
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection825
{
    XCTFail(@"Not filled out yet");
}

@end
