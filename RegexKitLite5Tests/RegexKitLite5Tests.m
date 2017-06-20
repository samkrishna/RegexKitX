//
//  RegexKitLite5Tests.m
//  RegexKitLite5Tests
//
//  Created by Sam Krishna on 6/12/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "RegexKitLite5.h"

#import <XCTest/XCTest.h>

@interface RegexKitLite5Tests : XCTestCase
@property (nonatomic, readwrite, strong) NSString *candidate;
@end

@implementation RegexKitLite5Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.candidate = @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";
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

- (void)testStringByReplacingOccurrencesOfRegexOptionsMatchingOptionsInRangeErrorUsingBlock
{
    NSString *pattern = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";
    NSRange entireRange = [self.candidate stringRange];

    NSString *output = [self.candidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:entireRange error:NULL usingBlock:^NSString *(NSInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
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
                            "A peck of pickled peppers Peter Piper picked;\n"
                            "If Peter Piper picked a peck of pickled peppers,\n"
                            "Where's the peck of pickled peppers Peter Piper picked?";
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:[newCandidate stringRange] error:NULL usingBlock:^NSString *(NSInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
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
    
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern usingBlock:^NSString *(NSInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
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
//    NSError *error;
    NSString *regexString = @"[a-z"; // Missing the closing ]
    XCTAssertFalse([regexString isRegexValidWithOptions:RKLNoOptions error:NULL], @"This should have failed!");
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
    NSInteger captureCount = [pattern captureCountWithOptions:RKLNoOptions error:&error];
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
    
    BOOL result = [self.candidate enumerateStringsSeparatedByRegex:@"(,(\\s*))" usingBlock:^(NSInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *firstString = capturedStrings[0];
        NSRange range1 = capturedRanges[0];
        NSRange range2 = capturedRanges[1];
        NSLog(@"firstString = %@ and range1 = %@ and range2 = %@", firstString, NSStringFromRange(range1), NSStringFromRange(range2));
    }];
    
    XCTAssert(result, @"This should be YES");
}

- (void)testICUtoPerlOperationalFix
{
    // This is from the RKL4 sources:
    
    // "I|at|ice I eat rice" split using the regex "\b\s*" demonstrates the problem. ICU bug http://bugs.icu-project.org/trac/ticket/6826
    // ICU : "", "I", "|", "at", "|", "ice", "", "I", "", "eat", "", "rice" <- Results that RegexKitLite used to produce.
    // PERL:     "I", "|", "at", "|", "ice",     "I",     "eat",     "rice" <- Results that RegexKitLite now produces.

    NSString *testString = @"I|at|ice I eat rice";
    NSString *pattern = @"\\b\\s*";
    NSArray *components = [testString componentsSeparatedByRegex:pattern];
    
    XCTAssert([[components firstObject] isEqualToString:@"I"], @"This should actually be \'I\'");
    XCTAssert([[components lastObject] isEqualToString:@"I"], @"This should actually be \'rice\'");
}

@end
