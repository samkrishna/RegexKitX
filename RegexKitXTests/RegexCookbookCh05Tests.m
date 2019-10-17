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
    NSString *colorRegex = @"\\bcolou?r\\b";
    NSString *colorTest = @"What is the colour of money?";
    XCTAssertTrue([colorTest isMatchedByRegex:colorRegex options:RKXCaseless]);

    NSString *brcatRegex = @"\\b[brc]at\\b";
    NSString *brcatTest = @"Is it a bat, cat, or rat?";
    NSArray<NSString *> *brcatMatches = [brcatTest substringsMatchedByRegex:brcatRegex options:RKXCaseless];
    XCTAssertTrue(brcatMatches.count == 3);

    NSString *phobiaRegex = @"\\b\\w*phobia\\b";
    NSString *phobiaTest = @"What's the difference between agoraphobia and acrophobia?";
    NSArray<NSString *> *phobiaMatches = [phobiaTest substringsMatchedByRegex:phobiaRegex options:RKXCaseless];
    XCTAssertTrue(phobiaMatches.count == 2);

    NSString *stevenRegex = @"\\bSte(?:ven?|phen)\\b";
    NSString *stevenTest = @"Is it spelled Steve, Steven, or Stephen?";
    NSArray<NSString *> *stevenMatches = [stevenTest substringsMatchedByRegex:stevenRegex options:RKXCaseless];
    XCTAssertTrue(stevenMatches.count == 3);

}

- (void)testRegexFromSection54
{
    // Negative lookbehind
    NSString *notCatRegex = @"\\b(?!cat\\b)\\w+";
    NSString *test = @"Catwoman, vindicate, cat";
    NSArray *matches = [test substringsMatchedByRegex:notCatRegex options:RKXCaseless];
    XCTAssertTrue(matches.count == 2);
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
