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
    // Negative lookahead
    NSString *notCatRegex = @"\\b(?!cat\\b)\\w+";
    NSString *test = @"Catwoman, vindicate, cat";
    NSArray *matches = [test substringsMatchedByRegex:notCatRegex options:RKXCaseless];
    XCTAssertTrue(matches.count == 2);
}

- (void)testRegexFromSection55
{
    NSString *regex = @"\\b\\w+\\b(?!\\W+cat\\b)";
    NSString *testFail = @"Catwoman finds a cat.";
    NSString *testSucceed = @"Dogman finds a dog.";
    NSArray *matches = [testSucceed substringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssertTrue(matches.count == 4);
    matches = [testFail substringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssertTrue(matches.count == 3);
}

- (void)testRegexFromSection56
{
    NSString *regex = @"(?<!\\bcat\\W{1,9})\\b\\w+";
    NSString *testCat = @"There is no cat here.";
    NSString *testDog = @"There is no dog here.";
    NSArray *noCatMatches = [testCat substringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssert(noCatMatches.count == 4);
    noCatMatches = [testDog substringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssertTrue(noCatMatches.count == 5);
}

- (void)testRegexFromSection57
{
    NSString *pattern = @""
    "\\b(?:"
    "word1                      # first term\n"
    "\\W+ (?:\\w+\\W+){0,5}?    # up to five words\n"
    "word2                      # second term\n"
    "|                          # or, the same pattern in reverse:\n"
    "word2                      # second term\n"
    "\\W+ (?:\\w+\\W+){0,5}?    # up to five words\n"
    "word1                      # first term\n"
    ")\\b";
    NSString *testTrue1 = @"Is there a word1 withing five words of word2?";
    NSString *testTrue2 = @"Is there a word2 withing five words of word1?";
    NSString *testFalse1 = @"Word1 has too many words and excuses between itself and word2.";
    NSString *testFalse2 = @"Word2 has too many words and excuses between itself and word1.";
    XCTAssertTrue([testTrue1 isMatchedByRegex:pattern options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertTrue([testTrue2 isMatchedByRegex:pattern options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertFalse([testFalse1 isMatchedByRegex:pattern options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertFalse([testFalse2 isMatchedByRegex:pattern options:(RKXIgnoreWhitespace | RKXCaseless)]);
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
