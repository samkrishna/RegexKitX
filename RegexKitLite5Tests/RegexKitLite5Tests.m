//
//  RegexKitLite5Tests.m
//  RegexKitLite5Tests
//
//  Created by Sam Krishna on 6/12/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RegexKitLite5.h"

#import <XCTest/XCTest.h>

@interface RegexKitLite5Tests : XCTestCase
@property (nonatomic, readwrite, strong) NSString *candidate;
@property (nonatomic, readwrite, strong) NSMutableArray *unicodeStringsArray;
@end

@implementation RegexKitLite5Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.candidate = @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";
    
    const char *unicodeCStrings[] = {
        /* 0 */ "pi \xE2\x89\x85 3 (apx eq)",
        /* 1 */ "\xC2\xA5""55 (yen)",
        /* 2 */ "\xC3\x86 (ae)",
        /* 3 */ "Copyright \xC2\xA9 2007",
        /* 4 */ "Ring of integers \xE2\x84\xA4 (dbl stk Z)",
        /* 5 */ "At the \xE2\x88\xA9 of two sets.",
        /* 6 */ "A w\xC5\x8D\xC5\x95\xC4\x91 \xF0\x9D\x8C\xB4\xF4\x8F\x8F\xBC w\xC4\xA9\xC8\x9B\xC8\x9F extra \xC8\xBF\xC5\xA3\xE1\xB9\xBB\xE1\xB8\x9F" "f",
        /* 7 */ "Frank Tang\xE2\x80\x99s I\xC3\xB1t\xC3\xABrn\xC3\xA2ti\xC3\xB4n\xC3\xA0liz\xC3\xA6ti\xC3\xB8n Secrets",
        NULL
    };
    const char **cString = unicodeCStrings;
    self.unicodeStringsArray = [NSMutableArray array];
    
    while (*cString != NULL) {
        [self.unicodeStringsArray addObject:[NSString stringWithUTF8String:*cString]];
        cString++;
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - isMatchedByRegex:

- (void)testIsMatchedByRegex
{
    NSString *regex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex], @"Match has failed!");
}

- (void)testIsMatchedByRegexRange
{
    NSString *regex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex inRange:[self.candidate stringRange]], @"Match has failed!");
    XCTAssertFalse([self.candidate isMatchedByRegex:regex inRange:NSMakeRange(0, [self.candidate length] / 2)], @"There\'s no way the whole regex should match on half the length of the candidate string");
}

- (void)testIsMatchedByRegexOptionsRangeError
{
    // NOTE: Not Comprehensive Yet
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex options:RKLCaseless inRange:[self.candidate stringRange] error:nil], @"Case-insensitive match has failed!");
    XCTAssertFalse([self.candidate isMatchedByRegex:regex options:RKLNoOptions inRange:[self.candidate stringRange] error:nil], @"Case-sensitive match has failed!");
}

- (void)testIsMatchedByRegexRegexOptionsMatchingOptionsRangeError
{
    // NOTE: Not Comprehensive Yet
    NSError *error;
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex options:RKLCaseless inRange:[self.candidate stringRange] error:nil], @"Case-insensitive match has failed!");
    XCTAssertFalse([self.candidate isMatchedByRegex:regex options:RKLNoOptions matchingOptions:0 inRange:[self.candidate stringRange] error:&error], @"Case-sensitive match has failed! Error: %@", error);
}

#pragma mark - componentsSeparatedByRegex:

- (void)testComponentsSeparatedByRegex
{
    NSString *regex = @", ";
    NSArray *captures = [self.candidate componentsSeparatedByRegex:regex];
    XCTAssert([captures count] == 12, @"This should have 12 elements!");
    
    for (NSString *substring in captures) {
        BOOL result = [substring isMatchedByRegex:@", "];
        XCTAssertFalse(result, @"There should be no separators in this substring!");
    }
}

#pragma mark - rangeOfRegex:

- (void)testRangeOfRegexOptionsMatchingOptionsInRangeCaptureError
{
    // @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";
    
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSRange entireRange = [self.candidate stringRange];
    NSRange captureRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:0 error:NULL];
    XCTAssert(captureRange.location == 0, @"We have a problem here!");
    XCTAssert(captureRange.length == 19, @"We have a problem here!");
    
    NSRange dateRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:1 error:NULL];
    XCTAssert(dateRange.location == 0, @"We have a problem here!");
    XCTAssert(dateRange.length == 10, @"We have a problem here!");

    NSRange yearRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:2 error:NULL];
    XCTAssert(yearRange.location == 0, @"We have a problem here!");
    XCTAssert(yearRange.length == 4, @"We have a problem here!");

    NSRange monthRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:3 error:NULL];
    XCTAssert(monthRange.location == 5, @"We have a problem here!");
    XCTAssert(monthRange.length == 2, @"We have a problem here!");

    NSRange dayRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:4 error:NULL];
    XCTAssert(dayRange.location == 8, @"We have a problem here!");
    XCTAssert(dayRange.length == 2, @"We have a problem here!");

    NSRange timeRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:5 error:NULL];
    XCTAssert(timeRange.location == 11, @"We have a problem here!");
    XCTAssert(timeRange.length == 8, @"We have a problem here!");

    NSRange hourRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:6 error:NULL];
    XCTAssert(hourRange.location == 11, @"We have a problem here!");
    XCTAssert(hourRange.length == 2, @"We have a problem here!");

    NSRange minuteRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:7 error:NULL];
    XCTAssert(minuteRange.location == 14, @"We have a problem here!");
    XCTAssert(minuteRange.length == 2, @"We have a problem here!");

    NSRange secondRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:8 error:NULL];
    XCTAssert(secondRange.location == 17, @"We have a problem here!");
    XCTAssert(secondRange.length == 2, @"We have a problem here!");
}

- (void)testFailedRangeOfRegex
{
    NSRange failRange = [self.candidate rangeOfRegex:@"blah"];
    XCTAssert(failRange.location == NSNotFound, @"This should not work!");
}

- (void)testStringByMatchingOptionsMatchingOptionsInRangeCaptureError
{
    // @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";
    
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSRange entireRange = [self.candidate stringRange];
    NSString *timestamp = [self.candidate stringByMatching:regex options:RKLNoOptions matchingOptions:0 inRange:entireRange capture:0 error:NULL];
    XCTAssert([timestamp isEqualToString:@"2014-05-06 17:03:17"], @"We have a problem here!");
}

- (void)testStringByReplacingOccurrencesOfRegexWithStringOptionsMatchingOptionsRangeError
{
    NSString *failedPattern = @"2014-05-06 17:03:17.967 EXECUTION_DINO";
    NSString *failureControl = @"2014-05-06 17:03:17.967 EXECUTION_DATA";
    NSRange failureRange = NSMakeRange(0, 38);
    NSString *failureResult = [self.candidate stringByReplacingOccurrencesOfRegex:failedPattern withString:@"BARNEY RUBBLE" options:RKLNoOptions matchingOptions:0 range:failureRange error:NULL];
    XCTAssert([failureResult isEqualToString:failureControl]);

    NSString *successPattern = @"2014-05-06 17:03:17.967 EXECUTION_DATA";
    NSString *successResult = [self.candidate stringByReplacingOccurrencesOfRegex:successPattern withString:@"BARNEY RUBBLE" options:RKLNoOptions matchingOptions:0 range:failureRange error:NULL];
    XCTAssert([successResult isMatchedByRegex:@"BARNEY RUBBLE"]);
}

- (void)testStringByReplacingOccurrencesOfRegexOptionsMatchingOptionsInRangeErrorUsingBlock
{
    NSString *pattern = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";
    NSRange entireRange = [self.candidate stringRange];

    NSString *output = [self.candidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:entireRange error:NULL usingBlock:^NSString *(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSMutableString *replacement = [NSMutableString string];
        NSString *dateRegex = @"^\\d+-\\d+-\\d+$";
        NSString *timeRegex = @"^\\d+:\\d+:\\d+\\.\\d+$";
        
        for (NSString *capture in capturedStrings) {
            if ([capture isMatchedByRegex:dateRegex]) {
                [replacement appendString:@"cray "];
            }
            else if ([capture isMatchedByRegex:timeRegex]) {
                [replacement appendString:@"cray!"];
            }
        }
        
        return [replacement copy];
    }];
    
    XCTAssert([output isMatchedByRegex:@"cray cray!"], @"We have a problem here!");
    
    pattern = @"pick(led)?";
    NSString *newCandidate = @"Peter Piper picked a peck of pickled peppers;\n"
                             @"A peck of pickled peppers Peter Piper picked;\n"
                             @"If Peter Piper picked a peck of pickled peppers,\n"
                             @"Where's the peck of pickled peppers Peter Piper picked?";
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:[newCandidate stringRange] error:NULL usingBlock:^NSString *(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ([capturedStrings[0] isMatchedByRegex:@"^pick$"]) {
            return @"select";
        }
        else if ([capturedStrings[0] isMatchedByRegex:@"^pickled$"]) {
            return @"marinated";
        }
        
        return @"FAIL";
    }];
    
    XCTAssert([output isMatchedByRegex:@"selected"], @"The block didn't work!");
    XCTAssert([output isMatchedByRegex:@"marinated"], @"The block didn't work!");
    XCTAssertFalse([output isMatchedByRegex:@"FAIL"], @"The block should NOT have inserted \'FAIL\'!!");
}

- (void)testIsRegexValid
{
    NSString *regexString = @"[a-z"; // Missing the closing ]
    XCTAssertFalse([regexString isRegexValid], @"This should have failed!");
}

- (void)testIsRegexValidWithOptionsError
{
    NSError *error;
    NSString *regexString = @"[a-z"; // Missing the closing ]
    XCTAssertFalse([regexString isRegexValidWithOptions:RKLNoOptions error:&error], @"This should have failed!");
}

- (void)testComponentsMatchedByRegexOptionsRangeCaptureError
{
    NSString *list = @"$10.23, $1024.42, $3099";
    NSRange listRange = [list stringRange];
    NSArray *listItems = [list componentsMatchedByRegex:@"\\$((\\d+)(?:\\.(\\d+)|\\.?))" options:RKLNoOptions range:listRange capture:3L error:NULL];
    
    // listItems == [NSArray arrayWithObjects:@"23", @"42", @"", NULL];
    NSString *component1 = listItems[0];
    NSString *component2 = listItems[1];
    XCTAssert([component1 isEqualToString:@"23"], @"This should match!");
    XCTAssert([component2 isEqualToString:@"42"], @"This should match!");
}

- (void)testCaptureCountWithOptionsError
{
    NSString *pattern = @"\\$((\\d+)(?:\\.(\\d+)|\\.?))";
    NSError *error;
    NSUInteger captureCount = [pattern captureCountWithOptions:RKLNoOptions error:&error];
    XCTAssert(captureCount == 3, @"This should be 4!");
}

- (void)testDictionaryByMatchingRegexOptionsRangeErrorWithKeysAndCaptures
{
    NSString *name = @"Name: Joe";
    NSString *regex = @"Name:\\s*(\\w*)\\s*(\\w*)";
    NSDictionary *nameDictionary = [name dictionaryByMatchingRegex:regex
                                                           options:RKLNoOptions
                                                             range:[name stringRange]
                                                             error:NULL
                                               withKeysAndCaptures:@"first", 1, @"last", 2, nil];

    NSString *first = nameDictionary[@"first"];
    NSString *last = nameDictionary[@"last"];
    XCTAssert([first isEqualToString:@"Joe"], @"This should be \'Joe\'");
    XCTAssert([last isEqualToString:@""], @"This should be an empty string");
    
    NSString *badRegex = @"Name:\\s*(\\w*)\\s*(\\w*";
    NSError *error;
    nameDictionary = [name dictionaryByMatchingRegex:badRegex
                                             options:RKLNoOptions
                                               range:[name stringRange]
                                               error:&error
                                 withKeysAndCaptures:@"first", 1, @"last", 2, nil];
    XCTAssertNil(nameDictionary, @"This should be nil!");
    XCTAssertNotNil(error, @"There should be an error here");
}

- (void)testArrayOfDictionariesByMatchingRegexOptionsRangeErrorWithKeysAndCaptures
{
    NSString *name = @"Name: Bob\n"
                     @"Name: John Smith";
    NSString *regex = @"(?m)^Name:\\s*(\\w*)\\s*(\\w*)$";
    NSArray  *nameArray = [name arrayOfDictionariesByMatchingRegex:regex
                                                           options:RKLNoOptions
                                                             range:[name stringRange]
                                                             error:NULL
                                               withKeysAndCaptures:@"first", 1, @"last", 2, NULL];

    NSDictionary *name1 = nameArray[0];
    XCTAssert([name1[@"first"] isEqualToString:@"Bob"], @"This should be \'Bob\'");
    XCTAssert([name1[@"last"] isEqualToString:@""], @"This should be an empty string");

    NSDictionary *name2 = nameArray[1];
    XCTAssert([name2[@"first"] isEqualToString:@"John"], @"This should be \'John\'");
    XCTAssert([name2[@"last"] isEqualToString:@"Smith"], @"This should be \'Smith\'");    
}

- (void)testEnumerateStringsSeparatedByRegex
{
    // @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";
    NSString *regexPattern = @"(,(\\s*))";
    NSArray *rangeValueChecks = @[ [NSValue valueWithRange:NSMakeRange(0, 91)],
                                   [NSValue valueWithRange:NSMakeRange(93, 30)],
                                   [NSValue valueWithRange:NSMakeRange(125, 23)],
                                   [NSValue valueWithRange:NSMakeRange(150, 19)],
                                   [NSValue valueWithRange:NSMakeRange(171, 17)],
                                   [NSValue valueWithRange:NSMakeRange(190, 8)],
                                   [NSValue valueWithRange:NSMakeRange(200, 13)],
                                   [NSValue valueWithRange:NSMakeRange(215, 12)],
                                   [NSValue valueWithRange:NSMakeRange(229, 16)],
                                   [NSValue valueWithRange:NSMakeRange(247, 13)],
                                   [NSValue valueWithRange:NSMakeRange(262, 13)],
                                   [NSValue valueWithRange:NSMakeRange(277, 15)] ];

    __block NSUInteger index = 0;
    BOOL result = [self.candidate enumerateStringsSeparatedByRegex:regexPattern usingBlock:^(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *string = capturedStrings[0];
        NSRange range = capturedRanges[0];
        NSRange rangeCheck = [rangeValueChecks[index] rangeValue];
        NSLog(@"Forward: string = %@ and range = %@", string, NSStringFromRange(range));
        XCTAssert(NSEqualRanges(range, rangeCheck), @"The string (%@) doesn't have the correct ranges: %@ != %@", string, NSStringFromRange(range), NSStringFromRange(rangeCheck));
        index++;
    }];
    
    XCTAssert(result);
    index--;

    result = [self.candidate enumerateStringsSeparatedByRegex:regexPattern options:0 matchingOptions:0 inRange:[self.candidate stringRange] error:NULL enumerationOptions:NSEnumerationReverse usingBlock:^(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *string = capturedStrings[0];
        NSRange range = capturedRanges[0];
        NSRange rangeCheck = [rangeValueChecks[index] rangeValue];
        NSLog(@"Reverse: string = %@ and range = %@", string, NSStringFromRange(range));
        XCTAssert(NSEqualRanges(range, rangeCheck), @"The string (%@) doesn't have the correct ranges: %@ != %@", string, NSStringFromRange(range), NSStringFromRange(rangeCheck));
        index--;
    }];

    XCTAssert(result);
}

- (void)testICUtoPerlOperationalFix
{
    // This is from the RKL4 sources:
    
    // "I|at|ice I eat rice" split using the regex "\b\s*" demonstrates the problem. ICU bug http://bugs.icu-project.org/trac/ticket/6826
    // ICU : "", "I", "|", "at", "|", "ice", "", "I", "", "eat", "", "rice" <- Results that RegexKitLite used to produce.
    // PERL:     "I", "|", "at", "|", "ice",     "I",     "eat",     "rice" <- Results that RegexKitLite now produces.

    // Follow-up: I followed the ticket to see what the outcome was. The ICU dev team rejected this ticket and
    // said it was closed b/c the behavior worked as intended. I'm noting this here for historic purposes.

    NSString *testString = @"I|at|ice I eat rice";
    NSString *pattern = @"\\b\\s*";
    NSArray *components = [testString componentsSeparatedByRegex:pattern];
    
    XCTAssertFalse([[components firstObject] isEqualToString:@"I"], @"For RKL4: This used to be \'I\'");
    XCTAssert([[components lastObject] isEqualToString:@"rice"], @"This should actually be \'rice\'");
}

#pragma mark - Ported RKL4 Demos/Tests

- (void)testOriginalEnumeratorExample
{
    NSString *searchString = @"one\ntwo\n\nfour\n";
    NSString *regexString = @"(?m)^.*$";
    __block NSUInteger line = 0UL;
    __block NSUInteger matchCount = 0;
    
    NSLog(@"searchString: '%@'", searchString);
    NSLog(@"regexString : '%@'", regexString);
    
    [searchString enumerateStringsMatchedByRegex:regexString usingBlock:^(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *matchedString = capturedStrings[0];
        NSLog(@"%lu: %lu '%@'", ++line, [matchedString length], matchedString);
        matchCount++;
    }];
    
    XCTAssert(matchCount == 4, @"There should have been 4 matches!");
}

- (void)testForInExample
{
    NSString *searchString = @"one\ntwo\n\nfour\n";
    NSString *regexString  = @"(?m)^.*$";
    NSUInteger line = 0UL;
    NSUInteger matchCount = 0;
    
    NSLog(@"searchString: '%@'", searchString);
    NSLog(@"regexString : '%@'", regexString);
    
    for (NSString *matchedString in [searchString componentsMatchedByRegex:regexString]) {
        NSLog(@"%lu: %lu '%@'", ++line, [matchedString length], matchedString);
        matchCount++;
    }
    
    XCTAssert(matchCount == 4, @"There should have been 4 matches!");
}

- (void)testLinkExample
{
    // Copyright COPYRIGHT_SIGN APPROXIMATELY_EQUAL_TO 2008
    // Copyright \u00a9 \u2245 2008

    char *utf8CString = "Copyright \xC2\xA9 \xE2\x89\x85 2008";
    NSString *regexString = @"Copyright (.*) (\\d+)";
    NSString *subjectString = [NSString stringWithUTF8String:utf8CString];
    NSString *matchedString = [subjectString stringByMatching:regexString capture:1L];
    NSRange matchRange = [subjectString rangeOfRegex:regexString capture:1L];
    
    XCTAssert(NSEqualRanges(matchRange, NSMakeRange(10, 3)), @"range: %@", NSStringFromRange(matchRange));

    NSLog(@"subject: \"%@\"", subjectString);
    NSLog(@"matched: \"%@\"", matchedString);
}

#pragma mark - Ported RegexKit 0.6 Test Cases

// From core.m
- (void)testRegexString
{
    NSString *pattern123 = [NSString stringWithFormat:@"123"];
    XCTAssert([pattern123 isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    NSString *patternMAGIC = [NSString stringWithFormat:@"^(Match)\\s+the\\s+(MAGIC)$"];
    XCTAssert([patternMAGIC isRegexValidWithOptions:0 error:NULL], @"Should be valid");
}

- (void)testValidRegexString
{
    XCTAssert([@"123" isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    XCTAssert([@"^(Match)\\s+the\\s+(MAGIC)$" isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    
    // ICU likes this regex under a weird options combo (that included ignoring all metacharacters)
    XCTAssert([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0xffffffff error:NULL], @"Should be valid");
    // But didn't when options = 0
    XCTAssertFalse([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL], @"Should be valid");

    // ICU fails a number of perfectly good PCRE regexes.
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&pn) )* \\) )" isRegexValidWithOptions:0 error:NULL], @"Should be invalid");
    XCTAssertFalse([@"\\( ( ( (?>[^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL], @"Should be invalid");
    XCTAssertFalse([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL], @"Should be invalid");
    
    // These are bad PCRE regexes
    XCTAssertFalse([@"^(Match)\\s+the\\s+((MAGIC)$" isRegexValidWithOptions:0 error:NULL], @"Should be invalid");
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&xq) )* \\) )" isRegexValidWithOptions:0 error:NULL], @"Should be invalid");

    NSString *nilString = nil;
    XCTAssertFalse([nilString isRegexValidWithOptions:0 error:NULL], @"Should be invalid");
}

- (void)testSimpleUnicodeMatching
{
    NSString *copyrightString = [self.unicodeStringsArray objectAtIndex:3];
    NSRange rangeOf2007 = [copyrightString rangeOfRegex:@"2007"];
    NSRange foundationRange = [copyrightString rangeOfString:@"2007"];
    XCTAssertTrue(NSEqualRanges(foundationRange, rangeOf2007), @"This should be true");
    
    NSArray *regexRanges = [copyrightString rangesOfRegex:@"^(\\w+)\\s+(\\p{Any}+)\\s+(2007)$"];
    XCTAssertTrue((NSEqualRanges([regexRanges[0] rangeValue], NSMakeRange(0, 16))), @"%@", regexRanges[0]);
    XCTAssertTrue((NSEqualRanges([regexRanges[1] rangeValue], NSMakeRange(0, 9))), @"%@", regexRanges[1]);
    XCTAssertTrue((NSEqualRanges([regexRanges[2] rangeValue], NSMakeRange(10, 1))), @"%@", regexRanges[2]);
    XCTAssertTrue((NSEqualRanges([regexRanges[3] rangeValue], NSMakeRange(12, 4))), @"%@", regexRanges[3]);
}


@end
