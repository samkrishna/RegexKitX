//
//  RegexCookbookCh05Tests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 10/14/19.
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
    NSString *regex = @""
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
    XCTAssertTrue([testTrue1 isMatchedByRegex:regex options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertTrue([testTrue2 isMatchedByRegex:regex options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertFalse([testFalse1 isMatchedByRegex:regex options:(RKXIgnoreWhitespace | RKXCaseless)]);
    XCTAssertFalse([testFalse2 isMatchedByRegex:regex options:(RKXIgnoreWhitespace | RKXCaseless)]);
}

- (void)testRegexFromSection58
{
    // Finds repeated words
    NSString *regex = @"\\b([A-Z]+)\\s+\\1\\b";
    NSString *successCase = @"The the april rains fall mainly on the plain.";
    NSString *failureCase = @"This thistle is no good for a whistle.";
    XCTAssertTrue([successCase isMatchedByRegex:regex options:RKXCaseless]);
    XCTAssertFalse([failureCase isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexFromSection59
{
    NSString *logLines = @""
    "2019-10-23 23:10:27.252 TickStreamer INFO SFXStreamer.m:107 Hello, World!\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:30.209 TickStreamer VERBOSE SFXStreamer.m:1793 -[SFXStreamer getDayOf15MinBarsWithEndDate:forCurrencyPair:]_block_invoke Get 15m AUDJPY bars for day ending 2019-10-23 14:00:01 -0700";
    NSString *regex = @"^(.*)(?:(?:\\r?\\n|\\r|\\n)\\1)+$";
    NSString *output = [logLines stringByReplacingOccurrencesOfRegex:regex withTemplate:@"$1" options:RKXMultiline];
    XCTAssertFalse([output isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexFromSection510
{
    NSString *regex = @"^.*\\bverbose\\b.*$";
    NSString *logLines = @""
    "2019-10-23 23:10:27.252 TickStreamer INFO SFXStreamer.m:107 Hello, World!\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:30.209 TickStreamer VERBOSE SFXStreamer.m:1793 -[SFXStreamer getDayOf15MinBarsWithEndDate:forCurrencyPair:]_block_invoke Get 15m AUDJPY bars for day ending 2019-10-23 14:00:01 -0700";
    NSArray *matches = [logLines rangesOfRegex:regex options:(RKXCaseless | RKXMultiline)];
    XCTAssertTrue(matches.count == 3);
}

- (void)testRegexFromSection511
{
    NSString *regex = @"^(?:(?!\\bverbose\\b).)*$";
    NSString *logLines = @""
    "2019-10-23 23:10:27.252 TickStreamer INFO SFXStreamer.m:107 Hello, World!\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:28.032 TickStreamer VERBOSE SFXStreamer.m:210 -[SFXStreamer registerForDistributedNotifications]\n"
    "2019-10-23 23:10:30.209 TickStreamer VERBOSE SFXStreamer.m:1793 -[SFXStreamer getDayOf15MinBarsWithEndDate:forCurrencyPair:]_block_invoke Get 15m AUDJPY bars for day ending 2019-10-23 14:00:01 -0700";
    NSArray *matches = [logLines rangesOfRegex:regex options:(RKXCaseless | RKXMultiline)];
    XCTAssertTrue(matches.count == 1);
}

- (void)testRegexFromSection512
{
    NSString *line1 = @"     Simply replace matches found using one of the \"leading whitespace\" regexes and one    ";
    NSString *line2 = @"   of the \"trailing whitespace\" regexes with the empty string. Follow the code in    ";
    NSString *output1 = [line1 stringByReplacingOccurrencesOfRegex:@"^\\s+" withTemplate:@""];
    NSString *output2 = [line2 stringByReplacingOccurrencesOfRegex:@"^\\s+" withTemplate:@""];
    XCTAssertTrue([output1 isMatchedByRegex:@"^Simply"]);
    XCTAssertTrue([output2 isMatchedByRegex:@"^of the"]);

    output1 = [output1 stringByReplacingOccurrencesOfRegex:@"\\s+$" withTemplate:@""];
    output2 = [output2 stringByReplacingOccurrencesOfRegex:@"\\s+$" withTemplate:@""];
    XCTAssertTrue([output1 isMatchedByRegex:@"and one$"]);
    XCTAssertTrue([output2 isMatchedByRegex:@"code in$"]);
}

- (void)testRegexFromSection513
{
    NSString *test = @"Lorem    ipsum dolor sit amet,   consectetur  adipiscing elit. Donec  ac  nisi  in    elit\n"
    "hendrerit dapibus et sed lectus. Vivamus tempor diam vestibulum, suscipit   before  aliquam,   varius urna.\n";
    NSString *output = [test stringByReplacingOccurrencesOfRegex:@"\\s+" withTemplate:@" "];
    NSString *control = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ac nisi in elit "
    "hendrerit dapibus et sed lectus. Vivamus tempor diam vestibulum, suscipit before aliquam, varius urna. ";
    XCTAssertTrue([output isEqualToString:control]);
}

- (void)testRegexFromSection514
{
    NSString *regex = @"[[\\]{}()*+?.\\\\|^$\\-,&#\\s]]";
    NSString *testCase = @"<Hello World.>";
    NSString *escapedString = [testCase stringByReplacingOccurrencesOfRegex:regex withTemplate:@"\\\\$0"];
    NSString *control = @"<Hello\\ World\\.>";
    XCTAssertTrue([escapedString isEqualToString:control]);
}

@end
