//
//  RegexTipTests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 1/12/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexTipTests : XCTestCase
@end

@implementation RegexTipTests

- (void)test20190111Tip
{
    // https://twitter.com/RegexTip/status/1083755798197686273
    NSArray *testStrings = @[ @"abc", @"aBc", @"abC", @"aBC",
                              @"Abc", @"AbC", @"ABC", @"ABc",
                              @"abc", @"Abc", @"abC", @"AbC" ];

    for (NSString *test in testStrings) {
        XCTAssertTrue([test isMatchedByRegex:@"(?i)abc"], @"%@ failed to match regex", test);
    }
}

- (void)test20190812Tip
{
    // A regex that tests numbers for prime numbers:
    // https://www.noulakaz.net/2007/03/18/a-regular-expression-to-check-for-prime-numbers/
    BOOL(^isPrime)(NSUInteger) = ^BOOL(NSUInteger testNumber) {
        NSString *candidate = [@"1" stringByPaddingToLength:testNumber withString:@"1" startingAtIndex:0];
        NSString *primeTestRegex = @"^1?$|^(11+?)\\1+$";
        return ![candidate isMatchedByRegex:primeTestRegex];
    };

    XCTAssertTrue(isPrime(2));
    XCTAssertTrue(isPrime(7));
    XCTAssertFalse(isPrime(8));
    XCTAssertFalse(isPrime(10));
    XCTAssertFalse(isPrime(12));
    XCTAssertTrue(isPrime(13));
    XCTAssertFalse(isPrime(99));
    XCTAssertFalse(isPrime(100));
    XCTAssertTrue(isPrime(101));
    XCTAssertFalse(isPrime(111));
}

@end
