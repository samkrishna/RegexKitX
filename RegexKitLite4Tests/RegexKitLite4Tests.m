//
//  RegexKitLite4Tests.m
//  RegexKitLite4Tests
//
//  Created by Sam Krishna on 6/17/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "RegexKitLite.h"
#import <XCTest/XCTest.h>

@interface NSString (EntireRange)
- (NSRange)stringRange;
@end

@implementation NSString (EntireRange)
- (NSRange)stringRange
{
    return NSMakeRange(0, [self length]);
}
@end

@interface RegexKitLite4Tests : XCTestCase
@property (nonatomic, readwrite, strong) NSString *candidate;
@end

@implementation RegexKitLite4Tests
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
    XCTAssertFalse([self.candidate isMatchedByRegex:regex options:RKLNoOptions inRange:[self.candidate stringRange] error:&error], @"Case-sensitive match has failed! Error: %@", error);
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
    NSRange captureRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:0 error:NULL];
    XCTAssert(captureRange.location == 0, @"We have a problem here!");
    XCTAssert(captureRange.length == 19, @"We have a problem here!");
    
    NSRange dateRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:1 error:NULL];
    XCTAssert(dateRange.location == 0, @"We have a problem here!");
    XCTAssert(dateRange.length == 10, @"We have a problem here!");
    
    NSRange yearRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:2 error:NULL];
    XCTAssert(yearRange.location == 0, @"We have a problem here!");
    XCTAssert(yearRange.length == 4, @"We have a problem here!");
    
    NSRange monthRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:3 error:NULL];
    XCTAssert(monthRange.location == 5, @"We have a problem here!");
    XCTAssert(monthRange.length == 2, @"We have a problem here!");
    
    NSRange dayRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:4 error:NULL];
    XCTAssert(dayRange.location == 8, @"We have a problem here!");
    XCTAssert(dayRange.length == 2, @"We have a problem here!");
    
    NSRange timeRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:5 error:NULL];
    XCTAssert(timeRange.location == 11, @"We have a problem here!");
    XCTAssert(timeRange.length == 8, @"We have a problem here!");
    
    NSRange hourRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:6 error:NULL];
    XCTAssert(hourRange.location == 11, @"We have a problem here!");
    XCTAssert(hourRange.length == 2, @"We have a problem here!");
    
    NSRange minuteRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:7 error:NULL];
    XCTAssert(minuteRange.location == 14, @"We have a problem here!");
    XCTAssert(minuteRange.length == 2, @"We have a problem here!");
    
    NSRange secondRange = [self.candidate rangeOfRegex:regex options:RKLNoOptions inRange:entireRange capture:8 error:NULL];
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
    NSString *timestamp = [self.candidate stringByMatching:regex options:RKLNoOptions inRange:entireRange capture:0 error:NULL];
    XCTAssert([timestamp isEqualToString:@"2014-05-06 17:03:17"], @"We have a problem here!");
}


- (void)testStringByReplacingOccurrencesOfRegexOptionsMatchingOptionsInRangeErrorUsingBlock
{
    NSString *pattern = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";
    NSRange entireRange = [self.candidate stringRange];
    
    NSString *output = [self.candidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions inRange:entireRange error:NULL enumerationOptions:0 usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSMutableString *replacement = [NSMutableString string];
        NSString *dateRegex = @"^\\d+-\\d+-\\d+$";
        NSString *timeRegex = @"^\\d+:\\d+:\\d+\\.\\d+$";
        
        for (int i = 0; i < captureCount; i++) {
            NSString *capture = capturedStrings[i];
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
    
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions inRange:[newCandidate stringRange] error:NULL enumerationOptions:0 usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
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
    
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
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
@end
