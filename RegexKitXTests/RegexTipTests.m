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

@end
