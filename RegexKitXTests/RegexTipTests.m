//
//  RegexTipTests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 1/12/19.
 Copyright © 2019 Sam Krishna. All rights reserved.

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
    XCTAssertFalse(isPrime(114));
}

@end
