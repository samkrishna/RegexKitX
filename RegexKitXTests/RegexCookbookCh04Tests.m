//
//  RegexCookbookCh04Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 12/25/18.
//  Copyright © 2018 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh04Tests : XCTestCase

@end

@implementation RegexCookbookCh04Tests

- (void)testRegexFromSection41
{
    NSString *testEmail = @"hello.from@example.com";
    XCTAssertTrue([testEmail isMatchedByRegex:@"^\\S+@\\S+$"]);
    XCTAssertTrue([testEmail isMatchedByRegex:@"^[A-Z0-9+_.-]+@[A-Z0-9.-]+$" options:RKXCaseless]);
    XCTAssertTrue([testEmail isMatchedByRegex:@"^[A-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[A-Z0-9.-]+$" options:RKXCaseless]);

    NSString *noLeadingTrailingOrConsecutiveDots = @"^[A-Z0-9_!#$%&'*+/=?`{|}~^-]+(?:\\.[A-Z0-9_!#$%&'*+/=?`{|}~^-]+)*@[A-Z0-9-]+(?:\\.[A-Z0-9-]+)*$";
    XCTAssertTrue([testEmail isMatchedByRegex:noLeadingTrailingOrConsecutiveDots options:RKXCaseless]);

    NSString *tldHas2to6LettersRegex = @"^[\\w!#$%&'*+/=?`{|}~^-]+(?:\\.[\\w!#$%&'*+/=?`{|}~^-]+)*@(?:[A-Z0-9-]+\\.)+[A-Z]{2,6}$";
    XCTAssertTrue([testEmail isMatchedByRegex:tldHas2to6LettersRegex options:RKXCaseless]);
}

@end
