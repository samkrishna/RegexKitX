//
//  RegexCookbookCh03Tests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 12/8/18.
 Copyright © 2018 Sam Krishna. All rights reserved.

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

@interface RegexCookbookCh03Tests : XCTestCase
@end

@implementation RegexCookbookCh03Tests

- (void)testRegexFromSection31
{
    NSString *regex = @"[$\"\'\\n\\d/\\\\]";
    XCTAssertTrue([regex isRegexValid]);
}

- (void)testRegexFromSection34
{
    NSString *dollarAmount = @"five Hundred dollars";
    BOOL result = [dollarAmount isMatchedByRegex:@"\\w+\\s?" options:(RKXCaseless | RKXIgnoreWhitespace | RKXIgnoreMetacharacters | RKXIgnoreWhitespace | RKXDotAll | RKXMultiline | RKXUseUnixLineSeparators | RKXUnicodeWordBoundaries)];
    XCTAssertFalse(result);
}

- (void)testRegexFromSection35
{
    BOOL result = [@"The regex pattern" isMatchedByRegex:@"regex pattern"];
    XCTAssertTrue(result);
}

- (void)testRegexFromSection36
{
    BOOL result = [@"The regex pattern" isMatchedByRegex:@"^regex pattern$"];
    XCTAssertFalse(result);
}

- (void)testRegexFromSection37
{
    NSString *testString = @"Do you like 13 or 42?";
    NSString *substring = [testString stringMatchedByRegex:@"\\d+"];
    XCTAssertTrue([substring isEqualToString:@"13"]);
}

- (void)testRegexFromSection38
{
    NSString *testString = @"Do you like 13 or 42?";
    NSRange matchRange = [testString rangeOfRegex:@"\\d+"];
    XCTAssertTrue(matchRange.location == 12);
    XCTAssertTrue(matchRange.length == 2);
}

- (void)testRegexFromSection39
{
    NSString *testString = @"Please visit http://www.regexcookbook.com for more information.";
    NSArray<NSString *> *substrings = [testString captureSubstringsMatchedByRegex:@"http://([a-z0-9.]+)"];
    XCTAssertTrue([substrings[1] isEqualToString:@"www.regexcookbook.com"]);
}

- (void)testRegexFromSection310
{
    NSString *testString = @"The lucky numbers are 7, 13, 16, 42, 65, and 99";
    NSArray<NSString *> *substrings = [testString substringsMatchedByRegex:@"\\d+"];
    XCTAssertTrue(substrings.count == 6);
}

- (void)testRegexFromSection311
{
    NSString *testString = @"The lucky numbers are 7, 13, 16, 42, 65, and 99";
    NSArray<NSString *> *substrings = [testString substringsMatchedByRegex:@"\\d+"];
    [substrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCTAssertTrue([obj isMatchedByRegex:@"\\d+"]);
    }];
}

- (void)testRegexFromSection312
{
    NSString *testString = @"The lucky numbers are 7, 13, 16, 42, 65, and 99";
    NSMutableArray *multiplesOf13 = [NSMutableArray array];
    [testString enumerateStringsMatchedByRegex:@"\\d+" usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        if (capturedStrings.firstObject.integerValue % 13 == 0) {
            [multiplesOf13 addObject:capturedStrings.firstObject];
        }
    }];

    XCTAssertTrue(multiplesOf13.count == 2);
}

- (void)testRegexFromSection313
{
    NSString *testString = @"1 <b>2</b> 3 4 <b>5 6 7</b>";
    NSMutableArray<NSString *> *results = [NSMutableArray array];

    [testString enumerateStringsMatchedByRegex:@"<b>(.*?)</b>" usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSArray *substrings = [capturedStrings[0] substringsMatchedByRegex:@"\\d+"];
        [results addObjectsFromArray:substrings];
    }];

    XCTAssertTrue(results.count == 4);
    XCTAssertTrue(results[0].integerValue == 2);
    XCTAssertTrue(results[1].integerValue == 5);
    XCTAssertTrue(results[2].integerValue == 6);
    XCTAssertTrue(results[3].integerValue == 7);
}

- (void)testRegexFromSection314
{
    // From lipsum.com (with added jankiness)
    NSString *testString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ac nisi in elit hendrerit dapibus et sed lectus. Vivamus tempor diam vestibulum, suscipit before aliquam, varius urna. Morbi viverra before massa, nec gravida purus egestas nec. Suspendisse efficitur lobortis sapien, eget imperdiet mi aliquam ac. Cras scelerisque odio et ante ultrices, ac blandit nibh imperdiet. Nulla efficitur, nisl non bibendum scelerisque, est mi before mi, sit amet rhoncus sapien libero consectetur purus. Maecenas et massa sed nibh ultrices maximus. Cras imperdiet odio vel sapien before dignissim. Mauris id condimentum sapien. Sed mollis sem tempus, gravida ex sit amet, eleifend purus. Suspendisse accumsan magna risus, vel sodales ligula porttitor vitae. Quisque vitae odio erat. Aliquam sagittis libero fringilla, faucibus orci nec, volutpat odio. Mauris est nisl, elementum vel neque id, pellentesque congue dolor. Nullam pretium magna before, in sollicitudin ex faucibus before.";
    NSString *output = [testString stringByReplacingOccurrencesOfRegex:@"before" withTemplate:@"after"];
    XCTAssertTrue([output isMatchedByRegex:@"after"]);
    NSArray *captures = [output substringsMatchedByRegex:@"after"];
    XCTAssertTrue(captures.count == 6);
}

- (void)testRegexFromSection315
{
    NSString *testString = @"bird=aviary human=mammals dinosaurs=extinct";
    NSString *output = [testString stringByReplacingOccurrencesOfRegex:@"(\\w+)=(\\w+)" withTemplate:@"$2=$1"];
    XCTAssertTrue([output isMatchedByRegex:@"aviary=bird"]);
    XCTAssertTrue([output isMatchedByRegex:@"mammals=human"]);
    XCTAssertTrue([output isMatchedByRegex:@"extinct=dinosaurs"]);
}

- (void)testRegexFromSection316
{
    NSString *testString = @"There are 2 to the 3 combinations of ways this can work out";
    NSString *output = [testString stringByReplacingOccurrencesOfRegex:@"\\d+" usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSInteger newValue = capturedStrings.firstObject.integerValue * 2;
        return [@(newValue) description];
    }];

    XCTAssertTrue([output isMatchedByRegex:@"4"]);
    XCTAssertTrue([output isMatchedByRegex:@"6"]);
}

- (void)testRegexFromSection317
{
    NSString *testString = @"<b>first before</b> before <b>before before</b>";
    NSString *output = [testString stringByReplacingOccurrencesOfRegex:@"<b>.*?</b>" usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        return [capturedStrings.firstObject stringByReplacingOccurrencesOfRegex:@"before" withTemplate:@"after"];
    }];

    XCTAssertTrue([output isMatchedByRegex:@"first after"]);
    XCTAssertTrue([output isMatchedByRegex:@"before"]);
    XCTAssertTrue([output isMatchedByRegex:@"<b>after after</b>"]);
}

- (void)testRegexFromSection318
{
    // NOTE: Ignored most of the guidance in this section b/c the original regex operation
    // can be flattened from two steps to one
    NSString *test = @"<span class=\"middle\">“text”</span>";
    NSString *output = [test stringByReplacingOccurrencesOfRegex:@"“(\\w+)”" withTemplate:@"\"$1\""];
    XCTAssertTrue([output isMatchedByRegex:@"\"text\""]);
}

- (void)testRegexFromSection319
{
    NSString *test = @"I like <b>bold</b> and <i>italic</i> fonts";
    NSArray *substrings = [test substringsSeparatedByRegex:@"<[^<>]*>"];
    XCTAssertTrue(substrings.count == 5);
}

- (void)testRegexFromSection320
{
    NSString *test = @"I like <b>bold</b> and <i>italic</i> fonts";
    NSMutableArray *results = [NSMutableArray array];

    // Don't need the explicit capture group of the original regex: @"(<[^<>]*>)"
    // b/c you get it for free
    [test enumerateStringsSeparatedByRegex:@"<[^<>]*>" usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        [results addObjectsFromArray:capturedStrings];
    }];

    // Answer: I●like●, <b>, bold, </b>, ●and●, <i>, italic, </i>, ●fonts
    XCTAssertTrue(results.count == 9);
}

- (void)testRegexFromSection321
{
    NSString *test = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ac nisi in elit\n"
    "hendrerit dapibus et sed lectus. Vivamus tempor diam vestibulum, suscipit before aliquam, varius urna.\n"
    "Morbi viverra before massa, nec gravida purus egestas nec. Suspendisse efficitur lobortis sapien, eget\n"
    "imperdiet mi aliquam ac. Cras scelerisque odio et ante ultrices, ac blandit nibh imperdiet.\n"
    "Nulla efficitur, nisl non bibendum scelerisque, est mi before mi, sit amet rhoncus sapien libero\n"
    "consectetur purus. Maecenas et massa sed nibh ultrices maximus. Cras imperdiet odio vel sapien before\n"
    "dignissim. Mauris id condimentum sapien. Sed mollis sem tempus, gravida ex sit amet, eleifend purus.\n"
    "Suspendisse accumsan magna risus, vel sodales ligula porttitor vitae. Quisque vitae odio erat. Aliquam\n"
    "sagittis libero fringilla, faucibus orci nec, volutpat odio. Mauris est nisl, elementum vel neque id,\n"
    "pellentesque congue dolor. Nullam pretium magna before, in sollicitudin ex faucibus before.";
    __block NSUInteger matchCount = 0;

    [test enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        if ([line isMatchedByRegex:@"before"]) {
            matchCount++;
        }
    }];

    XCTAssertTrue(matchCount == 5);
}

- (void)testRegexFromSection322
{
    NSString *regex = @"\\b(?<keyword>table|row|cell)\\b"
                       "| %(?<string>[^%]*(?:%%[^%]*)*)%"
                       "| (?<error>\\S+)";

    NSString *sample = @"table %First table%\n"
                        "row cell %A1% cell %B1% cell%C1%cell%D1%\n"
                        "ROW row CELL %The previous row was blank%\n"
                        "cell %B3%\n"
                        "row\n"
                        "cell %A4% %second line%\n"
                        "cEll %B4%\n"
                        "%second line%\n"
                        "cell %C4\n"
                        "second line%\n"
                        "row cell %%%string%%%\n"
                        "cell %%\n"
                        "cell %%%%\n"
                        "cell %%%%%%\n";

    NSParameterAssert([regex isRegexValid]);
    RKXRegexOptions options = (RKXCaseless | RKXIgnoreWhitespace);
    __block NSMutableArray *table;

    // OK -- this is a little janky b/c of the strange formatting of the source input.
    // The fact that "A4\nsecond line" and similar with B4 and C4 is just plain weird.
    // I thought it would be more useful to have basic tokenization working w/o getting into
    // the weeds of writing custom classes for "RECTable", "RECRow" and "RECCell".
    //
    // I do think however, that learning how to tokenize effectively will be a critical skill to learn.
    // I just wasn't willing to put in the cycles to have this code match the functional output of the
    // Cookbook intention.
    [sample enumerateStringsMatchedByRegex:regex options:options usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSLog(@"captured string = %@", capturedStrings.firstObject);
        NSString *keyword = [capturedStrings.firstObject stringMatchedByRegex:regex capture:NSNotFound namedCapture:@"keyword" options:options];

        if ([keyword isMatchedByRegex:@"table" options:options]) {
            table = [NSMutableArray array];
        }
        else if ([keyword isMatchedByRegex:@"row" options:options]) {
            [table addObject:[NSMutableArray array]];
        }
        else if ([keyword isMatchedByRegex:@"cell" options:options]) {
            return;
        }
        else {
            NSString *cellString = [capturedStrings.firstObject stringMatchedByRegex:regex capture:NSNotFound namedCapture:@"string" options:options];

            if (cellString) {
                [table.lastObject addObject:cellString];
            }
        }
    }];

    NSLog(@"table = %@", table);
}

@end
