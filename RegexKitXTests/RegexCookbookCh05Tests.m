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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
