//
//  RegexKitXTests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 6/12/17.
 Copyright © 2017 Sam Krishna. All rights reserved.

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
@import XCTest;

#define NFA_FAIL_TEST 0
#define TEST_APPLE_BUGS 0

@interface RegexKitXTests : XCTestCase
@property (nonatomic, readonly, strong) NSString *testCorpus;
@property (nonatomic, readwrite, strong) NSString *candidate;
@property (nonatomic, readwrite, strong) NSMutableArray<NSString *> *unicodeStrings;
@end

@implementation RegexKitXTests

- (NSString *)testCorpus
{
    static dispatch_once_t onceToken;
    static NSString *_testCorpus;

    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"sherlock-utf-8" ofType:@"txt"];
        _testCorpus = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    });

    NSAssert(_testCorpus, @"There was a failure in loading the test corpus!");
    return _testCorpus;
}

- (void)setUp
{
    [super setUp];
    self.candidate = @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU275587, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";

    const char *unicodeCStrings[] = {
        /* 0 */ "pi \xE2\x89\x85 3 (apx eq)",
        /* 1 */ "\xC2\xA5""55 (yen)",
        /* 2 */ "\xC3\x86 (ae)",
        /* 3 */ "Copyright \xC2\xA9 2007",
        /* 4 */ "Ring of integers \xE2\x84\xA4 (double struck Z)",
        /* 5 */ "At the \xE2\x88\xA9 of two sets.",
        /* 6 */ "A w\xC5\x8D\xC5\x95\xC4\x91 \xF0\x9D\x8C\xB4\xF4\x8F\x8F\xBC w\xC4\xA9\xC8\x9B\xC8\x9F extra \xC8\xBF\xC5\xA3\xE1\xB9\xBB\xE1\xB8\x9F" "f",
        /* 7 */ "Frank Tang\xE2\x80\x99s I\xC3\xB1t\xC3\xABrn\xC3\xA2ti\xC3\xB4n\xC3\xA0liz\xC3\xA6ti\xC3\xB8n Secrets",
        NULL
    };
    const char **cString = unicodeCStrings;
    self.unicodeStrings = [NSMutableArray array];
    
    while (*cString != NULL) {
        [self.unicodeStrings addObject:[NSString stringWithUTF8String:*cString]];
        cString++;
    }

    static NSString *hj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hj = @"The Hero's Journey:\n"
            "䷂ - Difficulty at the Beginning\n"
            "𝌢 - Decisiveness\n"
            "𝌌 - Ascent\n"
            "䷢ - Progress\n"
            "𝍕 - Labouring\n"
            "𝍐 - Failure\n"
            "𝍃 - Doubt\n"
            "䷣ - Darkening of the Light\n"
            "䷅ - Conflict\n"
            "䷿ - Before Completion\n"
            "𝍓 - On The Verge\n"
            "䷪ - Breakthrough\n"
            "𝌴 - Pattern\n"
            "䷧ - Deliverance\n"
            "𝍎 - Completion\n"
            "䷾ - After Completion\n"
            "䷊ - Peace\n"
            "䷍ - Great Possession\n"
            "䷶ - Abundance\n"
            "䷀ - Creative Heaven";
    });

    [self.unicodeStrings addObject:hj];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMatchesRegex
{
    NSString *regex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex]);
}

- (void)testMatchesRegexRange
{
    NSString *regex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex range:self.candidate.stringRange]);
    XCTAssertFalse([self.candidate isMatchedByRegex:regex range:NSMakeRange(0, (self.candidate.length / 2))]);
}

- (void)testMatchesRegexOptionsRangeError
{
    // NOTE: Not Comprehensive Yet
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex range:self.candidate.stringRange options:RKXCaseless error:NULL]);
    XCTAssertFalse([self.candidate isMatchedByRegex:regex range:self.candidate.stringRange options:RKXNoOptions error:NULL]);
}

- (void)testMatchesRegexOptions
{
    // NOTE: Not Comprehensive Yet
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex options:RKXCaseless]);
    XCTAssertFalse([self.candidate isMatchedByRegex:regex options:RKXNoOptions]);
}

- (void)testIsMatchedByRegex
{
    // NOTE: Not Comprehensive Yet
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex options:RKXCaseless]);
    XCTAssertFalse([self.candidate isMatchedByRegex:regex options:RKXNoOptions]);

    NSString *testString = @"Orthogonal2";
    BOOL testResult = [testString isMatchedByRegex:@"orthogonal" options:RKXCaseless];
    XCTAssertTrue(testResult);
}

- (void)testSubstringsSeparatedByRegex
{
    NSString *regex = @", ";
    NSArray *substrings = [self.candidate substringsSeparatedByRegex:regex];
    XCTAssertTrue(substrings.count == 12);
    
    for (NSString *string in substrings) {
        BOOL result = [string isMatchedByRegex:@", "];
        XCTAssertFalse(result, @"There should be no separators in this substring! (%@)", string);
    }
}

- (void)testRangeOfRegex
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSRange captureRange = [self.candidate rangeOfRegex:regex capture:0];
    XCTAssertTrue(captureRange.location == 0);
    XCTAssertTrue(captureRange.length == 19);
    
    NSRange dateRange = [self.candidate rangeOfRegex:regex capture:1];
    XCTAssertTrue(dateRange.location == 0);
    XCTAssertTrue(dateRange.length == 10);

    NSRange yearRange = [self.candidate rangeOfRegex:regex capture:2];
    XCTAssertTrue(yearRange.location == 0);
    XCTAssertTrue(yearRange.length == 4);

    NSRange monthRange = [self.candidate rangeOfRegex:regex capture:3];
    XCTAssertTrue(monthRange.location == 5);
    XCTAssertTrue(monthRange.length == 2);

    NSRange dayRange = [self.candidate rangeOfRegex:regex capture:4];
    XCTAssertTrue(dayRange.location == 8);
    XCTAssertTrue(dayRange.length == 2);

    NSRange timeRange = [self.candidate rangeOfRegex:regex capture:5];
    XCTAssertTrue(timeRange.location == 11);
    XCTAssertTrue(timeRange.length == 8);

    NSRange hourRange = [self.candidate rangeOfRegex:regex capture:6];
    XCTAssertTrue(hourRange.location == 11);
    XCTAssertTrue(hourRange.length == 2);

    NSRange minuteRange = [self.candidate rangeOfRegex:regex capture:7];
    XCTAssertTrue(minuteRange.location == 14);
    XCTAssertTrue(minuteRange.length == 2);

    NSRange secondRange = [self.candidate rangeOfRegex:regex capture:8];
    XCTAssertTrue(secondRange.location == 17);
    XCTAssertTrue(secondRange.length == 2);
}

- (void)testRangeOfRegexNamedCapture
{
    NSString *regex = @"((?<year>\\d+)-(?<month>\\d+)-(?<day>\\d+)) ((?<hour>\\d+):(?<minute>\\d+):(?<second>\\d+))";
    NSRange captureRange = [self.candidate rangeOfRegex:regex capture:0];
    XCTAssertTrue(captureRange.location == 0);
    XCTAssertTrue(captureRange.length == 19);

    NSRange yearRange = [self.candidate rangeOfRegex:regex namedCapture:@"year"];
    XCTAssertTrue(yearRange.location == 0);
    XCTAssertTrue(yearRange.length == 4);

    NSRange monthRange = [self.candidate rangeOfRegex:regex namedCapture:@"month"];
    XCTAssertTrue(monthRange.location == 5);
    XCTAssertTrue(monthRange.length == 2);

    NSRange dayRange = [self.candidate rangeOfRegex:regex namedCapture:@"day"];
    XCTAssertTrue(dayRange.location == 8);
    XCTAssertTrue(dayRange.length == 2);

    NSRange timeRange = [self.candidate rangeOfRegex:regex capture:5];
    XCTAssertTrue(timeRange.location == 11);
    XCTAssertTrue(timeRange.length == 8);

    NSRange hourRange = [self.candidate rangeOfRegex:regex namedCapture:@"hour"];
    XCTAssertTrue(hourRange.location == 11);
    XCTAssertTrue(hourRange.length == 2);

    NSRange minuteRange = [self.candidate rangeOfRegex:regex namedCapture:@"minute"];
    XCTAssertTrue(minuteRange.location == 14);
    XCTAssertTrue(minuteRange.length == 2);

    NSRange secondRange = [self.candidate rangeOfRegex:regex namedCapture:@"second"];
    XCTAssertTrue(secondRange.location == 17);
    XCTAssertTrue(secondRange.length == 2);

    NSRange notFoundRange = [self.candidate rangeOfRegex:regex namedCapture:@"justKidding"];
    XCTAssertTrue(notFoundRange.location == NSNotFound);
    XCTAssertTrue(notFoundRange.length == 0);
}

- (void)testRangeOfRegexWithCaptureAndNamedCapture
{
    // 2014-05-06 17:03:17.967
    NSString *regex = @"(?<calendarDate>(?<year>\\d+)-(?<month>\\d+)-(?<day>\\d+)) ((?<hour>\\d+):(?<minute>\\d+):(?<second>\\d+)\\.(?<millisecond>\\d+))";
    NSRange captureRange = [self.candidate rangeOfRegex:regex capture:2 namedCapture:@"calendarDate"];
    XCTAssertTrue(captureRange.location == 0);
    XCTAssertTrue(captureRange.length == 10);
    NSString *calendarDate = [self.candidate substringWithRange:captureRange];
    XCTAssertTrue([calendarDate isEqualToString:@"2014-05-06"]);

    NSRange yearRange = [self.candidate rangeOfRegex:regex capture:2 namedCapture:nil];
    XCTAssertTrue(yearRange.location == 0);
    XCTAssertTrue(yearRange.length == 4);
    NSString *year = [self.candidate substringWithRange:yearRange];
    XCTAssertTrue([year isEqualToString:@"2014"]);
}

- (void)testFailedRangeOfRegex
{
    NSRange failRange = [self.candidate rangeOfRegex:@"blah"];
    XCTAssertTrue(failRange.location == NSNotFound);
}

- (void)testStringMatchedByRegex
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSString *fullTimestamp = [self.candidate stringMatchedByRegex:regex];
    XCTAssertTrue([fullTimestamp isEqualToString:@"2014-05-06 17:03:17"]);

    NSString *datestamp = [self.candidate stringMatchedByRegex:regex capture:1];
    XCTAssertTrue([datestamp isEqualToString:@"2014-05-06"]);
}

- (void)testStringMatchedByRegexNamedCapture
{
    NSString *regex = @"(?<calendardate>(?<year>\\d+)-(?<month>\\d+)-(?<day>\\d+)) ((?<hour>\\d+):(?<minute>\\d+):(?<second>\\d+))";
    NSString *fullTimestamp = [self.candidate stringMatchedByRegex:regex];
    XCTAssertTrue([fullTimestamp isEqualToString:@"2014-05-06 17:03:17"]);

    NSString *datestamp = [self.candidate stringMatchedByRegex:regex namedCapture:@"calendardate"];
    XCTAssertTrue([datestamp isEqualToString:@"2014-05-06"]);

    NSString *tickSizeKey = @"10-Tick";
    NSString *tickSizeCapture = [tickSizeKey stringMatchedByRegex:@"(\\d+)" range:[tickSizeKey stringRange] capture:1 options:RKXCaseless error:NULL];
    NSUInteger tickSize = (NSUInteger)tickSizeCapture.integerValue;
    NSUInteger control = 10;
    XCTAssertTrue(tickSize == control, @"tickSize = %lu, should be %lu", tickSize, control);
}

- (void)testStringMatchedByRegexCaptureNamedCapture
{
    // 2014-05-06 17:03:17.967
    NSString *regex = @"(?<calendarDate>(?<year>\\d+)-(?<month>\\d+)-(?<day>\\d+)) ((?<hour>\\d+):(?<minute>\\d+):(?<second>\\d+)\\.(?<millisecond>\\d+))";
    NSString *calendarDateString = [self.candidate stringMatchedByRegex:regex capture:2 namedCapture:@"calendarDate"];
    XCTAssertTrue([calendarDateString isEqualToString:@"2014-05-06"]);

    NSString *year = [self.candidate stringMatchedByRegex:regex capture:2 namedCapture:nil];
    XCTAssertTrue([year isEqualToString:@"2014"]);
}

- (void)testStringByReplacingOccurrencesOfRegexWithTemplateOptionsMatchingOptionsRangeError
{
    NSString *failedPattern = @"2014-05-06 17:03:17.967 EXECUTION_DINO";
    NSString *failureControl = @"2014-05-06 17:03:17.967 EXECUTION_DATA";
    NSRange failureRange = NSMakeRange(0, 38);
    NSString *failureResult = [self.candidate stringByReplacingOccurrencesOfRegex:failedPattern withTemplate:@"BARNEY RUBBLE" range:failureRange options:RKXNoOptions matchOptions:kNilOptions error:NULL];
    XCTAssertTrue([failureResult isEqualToString:failureControl]);

    NSString *successPattern = @"\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+ (EXECUTION_DATA)";
    NSString *successResult = [self.candidate stringByReplacingOccurrencesOfRegex:successPattern withTemplate:@"BARNEY RUBBLE ~~~$1~~~" range:failureRange options:RKXNoOptions matchOptions:kNilOptions error:NULL];
    XCTAssertTrue([successResult isMatchedByRegex:@"BARNEY RUBBLE"]);
    XCTAssertTrue([successResult isMatchedByRegex:@"~~~EXECUTION_DATA~~~"]);
}

- (void)testStringByReplacingOccurrencesOfRegexRangeOptionsMatchOptionsErrorUsingBlock
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";
    NSRange entireRange = self.candidate.stringRange;

    NSString *output = [self.candidate stringByReplacingOccurrencesOfRegex:regex range:entireRange options:RKXNoOptions matchOptions:kNilOptions error:NULL usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
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
    
    XCTAssertTrue([output isMatchedByRegex:@"cray cray!"]);

    __block NSUInteger blockCount = 0;
    regex = @"pick(led)?";
    NSString *newCandidate = @"Peter Piper picked a peck of pickled peppers;\n"
                             @"A peck of pickled peppers Peter Piper picked;\n"
                             @"If Peter Piper picked a peck of pickled peppers,\n"
                             @"Where's the peck of pickled peppers Peter Piper picked?";
    output = [newCandidate stringByReplacingOccurrencesOfRegex:regex range:newCandidate.stringRange options:RKXNoOptions matchOptions:kNilOptions error:NULL usingBlock:^NSString *(NSArray *capturedStrings, NSArray *capturedRanges, BOOL *stop) {
        blockCount++;

        if (blockCount == 2) {
            *stop = YES;
        }

        if ([capturedStrings[0] isMatchedByRegex:@"^pick$"]) {
            return @"select";
        }
        else if ([capturedStrings[0] isMatchedByRegex:@"^pickled$"]) {
            return @"marinated";
        }
        
        return @"FAIL";
    }];
    
    XCTAssertTrue([output isMatchedByRegex:@"selected"]);
    XCTAssertTrue([output isMatchedByRegex:@"marinated"]);
    XCTAssertTrue([output isMatchedByRegex:@"pick"]);
    XCTAssertTrue([output isMatchedByRegex:@"pickled"]);
    XCTAssertFalse([output isMatchedByRegex:@"FAIL"]);
}

- (void)testIsRegexValidWithOptionsError
{
    NSError *error;
    NSString *regexString = @"[a-z";
    XCTAssertFalse([regexString isRegexValidWithOptions:RKXNoOptions error:&error]);
    XCTAssertTrue(error.code == 2048);
    XCTAssertTrue(error.domain == NSCocoaErrorDomain);
}

- (void)testArrayOfCaptureSubstringsMatchedByRegex
{
    NSString *list = @"$10.23, $1024.42, $3099";
    NSArray *listItems = [list arrayOfCaptureSubstringsMatchedByRegex:@"\\$((\\d+)(?:\\.(\\d+)|\\.?))"];
    XCTAssertTrue(listItems.count == 3);

    NSArray *list0 = listItems[0];
    BOOL result0 = [list0 isEqualToArray:@[ @"$10.23", @"10.23", @"10", @"23" ]];
    XCTAssertTrue(result0);

    NSArray *list1 = listItems[1];
    BOOL result1 = [list1 isEqualToArray:@[ @"$1024.42", @"1024.42", @"1024", @"42" ]];
    XCTAssertTrue(result1);

    NSArray *list2 = listItems[2];
    BOOL result2 = [list2 isEqualToArray:@[ @"$3099", @"3099", @"3099", RKXEmptyStringKey ]];
    XCTAssertTrue(result2);
}

- (void)testSubstringsMatchedByRegex
{
    NSString *list = @"$10.23, $1024.42, $3099";
    NSArray *listItems = [list substringsMatchedByRegex:@"\\$((\\d+)(?:\\.(\\d+)|\\.?))" capture:3];
    
    XCTAssertTrue([listItems[0] isEqualToString:@"23"]);
    XCTAssertTrue([listItems[1] isEqualToString:@"42"]);
    XCTAssertTrue([listItems[2] isEqualToString:RKXEmptyStringKey]);
}

- (void)testCaptureSubstringsMatchedByRegex
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+).(\\d+))";
    NSArray *captures = [self.candidate captureSubstringsMatchedByRegex:regex];
    XCTAssertTrue(captures.count == 10);
    XCTAssertTrue([captures[1] isEqualToString:@"2014-05-06"]);
    XCTAssertTrue([captures[5] isEqualToString:@"17:03:17.967"]);
}

- (void)testCaptureCountWithOptionsError
{
    NSString *regex = @"\\$((\\d+)(?:\\.(\\d+)|\\.?))";
    NSError *error;
    NSUInteger captureCount = [regex captureCountWithOptions:RKXNoOptions error:&error];
    XCTAssertTrue(captureCount == 3);
}

- (void)testDictionaryMatchedByRegexRangeOptionsErrorWithKeysAndCaptures
{
    NSString *name = @"Name: Joe";
    NSString *regex = @"Name:\\s*(\\w*)\\s*(\\w*)";
    NSString *firstKey = @"first";
    NSString *lastKey = @"last";
    NSDictionary *nameDictionary = [name dictionaryMatchedByRegex:regex
                                              withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];

    XCTAssertTrue([nameDictionary[firstKey] isEqualToString:@"Joe"]);
    XCTAssertTrue([nameDictionary[lastKey] isEqualToString:RKXEmptyStringKey]);
    
    NSString *badRegex = @"Name:\\s*(\\w*)\\s*(\\w*";
    NSError *error;
    nameDictionary = [name dictionaryMatchedByRegex:badRegex
                                              range:name.stringRange
                                            options:RKXNoOptions
                                              error:&error
                                withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];
    XCTAssertNil(nameDictionary);
    XCTAssertNotNil(error);

    NSString *execRegex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), time:(\\d+\\s+\\d+:\\d+:\\d+), acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    NSDictionary *executionDict = [self.candidate dictionaryMatchedByRegex:execRegex withKeysAndCaptures:
                                   @"executionDate", 1,
                                   @"currencyPair", 2,
                                   @"orderID", 3,
                                   @"clientID", 4,
                                   @"executionID", 5,
                                   @"canonicalExecutionDate", 6,
                                   @"accountID", 7,
                                   @"orderSide", 8,
                                   @"orderVolume", 9,
                                   @"executionPrice", 10,
                                   @"permanentID", 11, nil];

    XCTAssertTrue(executionDict.count == 11);
    XCTAssertTrue([executionDict[@"executionDate"] isEqualToString:@"2014-05-06 17:03:17.967"]);
    XCTAssertTrue([executionDict[@"currencyPair"] isEqualToString:@"EUR.JPY"]);
    XCTAssertTrue([executionDict[@"orderID"] isEqualToString:@"439"]);
    XCTAssertTrue([executionDict[@"clientID"] isEqualToString:@"75018"]);
    XCTAssertTrue([executionDict[@"executionID"] isEqualToString:@"0001f4e8.536956da.01.01"]);
    XCTAssertTrue([executionDict[@"canonicalExecutionDate"] isEqualToString:@"20140506  17:03:18"]);
    XCTAssertTrue([executionDict[@"accountID"] isEqualToString:@"DU275587"]);
    XCTAssertTrue([executionDict[@"orderSide"] isEqualToString:@"SLD"]);
    XCTAssertTrue([executionDict[@"orderVolume"] isEqualToString:@"141500"]);
    XCTAssertTrue([executionDict[@"executionPrice"] isEqualToString:@"141.73"]);
    XCTAssertTrue([executionDict[@"permanentID"] isEqualToString:@"825657452"]);
}

- (void)testArrayOfDictionariesMatchedByRegexWithKeysAndCaptures
{
    NSString *name = @"Name: Bob\nName: John Smith";
    NSString *regex = @"(?m)^Name:\\s*(\\w*)\\s*(\\w*)$";
    NSString *firstKey = @"first";
    NSString *lastKey = @"last";
    NSArray  *nameArray = [name arrayOfDictionariesMatchedByRegex:regex
                                              withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];

    NSDictionary *name1 = nameArray[0];
    XCTAssertTrue([name1[firstKey] isEqualToString:@"Bob"]);
    XCTAssertTrue([name1[lastKey] isEqualToString:RKXEmptyStringKey]);

    NSDictionary *name2 = nameArray[1];
    XCTAssertTrue([name2[firstKey] isEqualToString:@"John"]);
    XCTAssertTrue([name2[lastKey] isEqualToString:@"Smith"]);

    NSArray *failureResult = [self.candidate arrayOfDictionariesMatchedByRegex:regex
                                                           withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];
    XCTAssertNotNil(failureResult);
    XCTAssertTrue(failureResult.count == 0);
}

- (void)testDictionaryWithNamedCaptureKeysMatchedByRegex
{
    NSString *execRegex = @"(?<executionDate>.*) EXECUTION_DATA: .* (?<currencyPair>\\w{3}.\\w{3}) .* orderId:(?<orderID>-?\\d+): clientId:(?<clientID>\\w+), execId:(?<executionID>.*.01), time:(?<canonicalExecutionDate>\\d+\\s+\\d+:\\d+:\\d+), acctNumber:(?<accountID>\\w+).*, side:(?<orderSide>\\w+), shares:(?<orderVolume>\\d+), price:(?<executionPrice>.*), permId:(?<permanentID>\\d+).*";
    NSDictionary *executionDict = [self.candidate dictionaryWithNamedCaptureKeysMatchedByRegex:execRegex];
    XCTAssertTrue(executionDict.count == 11);
    XCTAssertTrue([executionDict[@"executionDate"] isEqualToString:@"2014-05-06 17:03:17.967"]);
    XCTAssertTrue([executionDict[@"currencyPair"] isEqualToString:@"EUR.JPY"]);
    XCTAssertTrue([executionDict[@"orderID"] isEqualToString:@"439"]);
    XCTAssertTrue([executionDict[@"clientID"] isEqualToString:@"75018"]);
    XCTAssertTrue([executionDict[@"executionID"] isEqualToString:@"0001f4e8.536956da.01.01"]);
    XCTAssertTrue([executionDict[@"canonicalExecutionDate"] isEqualToString:@"20140506  17:03:18"]);
    XCTAssertTrue([executionDict[@"accountID"] isEqualToString:@"DU275587"]);
    XCTAssertTrue([executionDict[@"orderSide"] isEqualToString:@"SLD"]);
    XCTAssertTrue([executionDict[@"orderVolume"] isEqualToString:@"141500"]);
    XCTAssertTrue([executionDict[@"executionPrice"] isEqualToString:@"141.73"]);
    XCTAssertTrue([executionDict[@"permanentID"] isEqualToString:@"825657452"]);

    NSString *emptyNamedCaptureRegex = @"(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), time:(\\d+\\s+\\d+:\\d+:\\d+), acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    NSDictionary *emptyDict = [self.candidate dictionaryWithNamedCaptureKeysMatchedByRegex:emptyNamedCaptureRegex];
    XCTAssertNotNil(emptyDict);
    XCTAssertTrue(emptyDict.count == 0);

    NSError *error;
    NSDictionary *nilDict = [self.candidate dictionaryWithNamedCaptureKeysMatchedByRegex:@"(?<pn> \\( ( (?>[^()]+) | (?&pn) )* \\) )" range:self.candidate.stringRange options:RKXNoOptions error:&error];
    XCTAssertNil(nilDict);
    XCTAssertNotNil(error);
}

- (void)testAnotherDictionaryWithNamedCaptureKeysMatchedByRegex
{
    NSString *categoryPlusBlock = @"-[SFXHalo_v3(StateMachine) attachWillEnterStateBlockToVirginState:]_block_invoke";
    NSString *regularMethod = @"-[SFXStreamer init]";
    NSString *categoryMethod = @"-[SFXOrderContext(StateMachine) startOrderStateWithDictionary:andOrder:]";

    NSString *regex = @"(?<methodType>[+-])\\[\\w+(\\+\\w+)? (?<methodName>.+)\\]";
    NSString *regex2 = @"(?<methodType>[+-])\\[(?<className>\\w+)"
                        "(\\((?<categoryName>\\w+)\\))? (?<methodName>.+)\\](?<block>_block_invoke)?";

    NSDictionary *cpbDict = [categoryPlusBlock dictionaryWithNamedCaptureKeysMatchedByRegex:regex options:RKXCaseless];
    XCTAssertNil(cpbDict[@"methodType"]);
    XCTAssertNil(cpbDict[@"methodName"]);

    NSDictionary *regularDict = [regularMethod dictionaryWithNamedCaptureKeysMatchedByRegex:regex2 options:RKXCaseless];
    XCTAssertNotNil(regularDict[@"methodType"]);
    XCTAssertNotNil(regularDict[@"methodName"]);

    NSDictionary *categoryDict = [categoryMethod dictionaryWithNamedCaptureKeysMatchedByRegex:regex2 options:RKXCaseless];
    XCTAssertNotNil(categoryDict[@"methodType"]);
    XCTAssertNotNil(categoryDict[@"methodName"]);
    XCTAssertNil(categoryDict[@"blockKey"]);
    XCTAssertNotNil(categoryDict[@"categoryName"]);

    cpbDict = [categoryPlusBlock dictionaryWithNamedCaptureKeysMatchedByRegex:regex2 options:RKXCaseless];
    XCTAssertNotNil(cpbDict[@"methodType"]);
    XCTAssertNotNil(cpbDict[@"methodName"]);
    XCTAssertNotNil(cpbDict[@"block"]);
}

- (void)testEnumerateStringsSeparatedByRegexUsingBlock
{
    NSString *regex = @",(\\s+)";
    NSArray<NSValue *> *rangeValueChecks = @[ [NSValue valueWithRange:NSMakeRange(0, 91)],
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
    BOOL result = [self.candidate enumerateStringsSeparatedByRegex:regex usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSRange range = capturedRanges[0].rangeValue;
        NSRange rangeCheck = rangeValueChecks[index].rangeValue;
        NSLog(@"Forward: string = %@ and range = %@", capturedStrings[0], NSStringFromRange(range));
        XCTAssertTrue(NSEqualRanges(range, rangeCheck), @"The string (%@) doesn't have the correct ranges: %@ != %@", capturedStrings[0], NSStringFromRange(range), NSStringFromRange(rangeCheck));
        index++;
    }];

    XCTAssertTrue(result);
    index--;

    result = [self.candidate enumerateStringsSeparatedByRegex:regex range:self.candidate.stringRange options:RKXNoOptions matchOptions:kNilOptions enumerationOptions:NSEnumerationReverse error:NULL usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSRange range = capturedRanges[0].rangeValue;
        NSRange rangeCheck = rangeValueChecks[index].rangeValue;
        NSLog(@"Reverse: string = %@ and range = %@", capturedStrings[0], NSStringFromRange(range));
        XCTAssertTrue(NSEqualRanges(range, rangeCheck), @"The string (%@) doesn't have the correct ranges: %@ != %@", capturedStrings[0], NSStringFromRange(range), NSStringFromRange(rangeCheck));
        index--;
    }];

    XCTAssertTrue(result);
}

- (void)testLegacyICUtoPerlOperationalFix
{
    // This is from the RKL4 sources:
    
    // "I|at|ice I eat rice" split using the regex "\b\s*" demonstrates the problem.
    // ICU bug https://unicode-org.atlassian.net/browse/ICU-6826
    //
    // ICU : "", "I", "|", "at", "|", "ice", "", "I", "", "eat", "", "rice" <- Results that RegexKitX produces
    // PERL:     "I", "|", "at", "|", "ice",     "I",     "eat",     "rice" <- Results that RKL4 produces.

    // Follow-up: I followed the ticket to see what the outcome was. The ICU dev team closed this ticket
    // by asserting that the behavior worked as intended, which is to clone Java's split().
    // I'm noting this here for historical purposes.

    NSString *testString = @"I|at|ice I eat rice";
    NSString *regex = @"\\b\\s*";
    NSArray<NSString *> *substrings = [testString substringsSeparatedByRegex:regex];
    XCTAssertFalse([substrings.firstObject isEqualToString:@"I"]);
    XCTAssertTrue([substrings.firstObject isEqualToString:RKXEmptyStringKey]);
    XCTAssertTrue([substrings.lastObject isEqualToString:@"rice"]);
}

#pragma mark - Named Backreference tests

- (void)testSubstringsMatchedByRegexWithNamedCaptures
{
    // da = directory assistance
    NSString *da = @"310-555-1212";
    NSString *regex = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSArray<NSString *> *captures = [da substringsMatchedByRegex:regex range:da.stringRange capture:2 namedCapture:@"area" options:RKXNoOptions matchOptions:kNilOptions error:NULL];
    XCTAssertTrue(captures.count == 2);
    XCTAssertTrue([captures[0] isEqualToString:@"555-1212"]);
    XCTAssertTrue([captures[1] isEqualToString:@"310"]);

    NSString *daOf3AreaCodes = @"310-555-1212 919-555-1212 212-555-1212";
    captures = [daOf3AreaCodes substringsMatchedByRegex:regex namedCapture:@"area"];
    XCTAssertTrue(captures.count == 3);
    XCTAssertTrue([captures[0] isEqualToString:@"310"]);
    XCTAssertTrue([captures[1] isEqualToString:@"919"]);
    XCTAssertTrue([captures[2] isEqualToString:@"212"]);

    NSString *markup = @"<strong><b>Hello</b></strong>, <em>World</em>";
    NSString *markupRegex = @"<(?<tag>\\w+)[^>]*>(?<content>.*?)</\\k<tag>>";
    captures = [markup substringsMatchedByRegex:markupRegex options:RKXCaseless];
    XCTAssertTrue(captures.count == 2);
    XCTAssertTrue([captures[0] isMatchedByRegex:@"<strong>"]);
    XCTAssertTrue([captures[0] isMatchedByRegex:@"</strong>"]);
    XCTAssertTrue([captures[1] isMatchedByRegex:@"<em>"]);
    XCTAssertTrue([captures[1] isMatchedByRegex:@"</em>"]);
}

- (void)testStringByReplacingOccurrencesOfRegexWithTemplateWithNamedBackreferences
{
    NSString *daOf3AreaCodes = @"310-555-1212 919-555-1212 212-555-1212";
    NSString *regex = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSString *output = [daOf3AreaCodes stringByReplacingOccurrencesOfRegex:regex withTemplate:@"${area}-666-2323 (Satan 411 in the ${area}!)"];
    NSArray<NSString *> *captures = [output substringsMatchedByRegex:@"\\d{3}-666-2323 \\(Satan 411 in the \\d{3}!\\)"];
    XCTAssertTrue(captures.count == 3);
    XCTAssertTrue([captures[0] substringsMatchedByRegex:@"310"].count == 2);
    XCTAssertTrue([captures[1] substringsMatchedByRegex:@"919"].count == 2);
    XCTAssertTrue([captures[2] substringsMatchedByRegex:@"212"].count == 2);
}

- (void)testStringByReplaceOccurrencesOfRegexWithTemplateWithMixedBackreferenceTypesInTemplate
{
    NSString *daOf3AreaCodes = @"310-555-1212 919-555-1212 212-555-1212";
    NSString *regex = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSString *output = [daOf3AreaCodes stringByReplacingOccurrencesOfRegex:regex withTemplate:@"${area}-666-2323 (old number: ${area}-$2)"];
    XCTAssertTrue([output isMatchedByRegex:@"\\(old number: 310-555-1212\\)"]);
    XCTAssertTrue([output isMatchedByRegex:@"\\(old number: 919-555-1212\\)"]);
    XCTAssertTrue([output isMatchedByRegex:@"\\(old number: 212-555-1212\\)$"]);

    NSString *da = @"310-555-1212";
    NSString *pattern = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSString *output2 = [da stringByReplacingOccurrencesOfRegex:pattern withTemplate:@"Reversed number: ${num}-${exch}-${area}"];
    NSString *testControl = @"Reversed number: 1212-555-310";
    XCTAssertTrue([output2 isEqualToString:testControl], @"Output is %@", output2);
}

#pragma mark - NSMutableString tests

- (void)testReplaceOccurrencesOfRegexWithTemplate
{
    NSMutableString *mutableCandidate = [NSMutableString stringWithString:self.candidate];
    NSUInteger count = [mutableCandidate replaceOccurrencesOfRegex:@", " withTemplate:@" barney "];

    XCTAssertTrue([mutableCandidate isMatchedByRegex:@" barney "]);
    XCTAssertFalse([mutableCandidate isMatchedByRegex:@", "]);
    XCTAssertTrue(count == 11);
}

- (void)testReplaceOccurrencesOfRegexUsingBlock
{
    NSMutableString *mutableCandidate = [NSMutableString stringWithString:self.candidate];
    NSUInteger count = [mutableCandidate replaceOccurrencesOfRegex:@", " usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        *stop = YES;
        return @" barney ";
    }];

    XCTAssertTrue(count == 1);
    XCTAssertTrue([mutableCandidate isMatchedByRegex:@" barney "]);
    XCTAssertTrue([mutableCandidate isMatchedByRegex:@", "]);
}

#pragma mark - Ported RKL4 Demos/Tests

- (void)testEnumerateStringsMatchedByRegexUsingBlock
{
    NSString *searchString = @"one\ntwo\n\nfour\n";
    NSString *regexString = @"(?m)^.*$";
    __block NSUInteger line = 0UL;
    __block NSUInteger matchCount = 0;
    
    NSLog(@"searchString: '%@'", searchString);
    NSLog(@"regexString : '%@'", regexString);
    
    [searchString enumerateStringsMatchedByRegex:regexString usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSString *matchedString = capturedStrings[0];
        NSLog(@"Line: %lu, length: %lu, matched string: '%@'", ++line, matchedString.length, matchedString);
        matchCount++;
    }];
    
    XCTAssertTrue(matchCount == 4);
}

- (void)testForInExample
{
    NSString *searchString = @"one\ntwo\n\nfour\n";
    NSString *regexString = @"(?m)^.*$";
    NSUInteger line = 0UL;
    NSUInteger matchCount = 0;
    
    NSLog(@"searchString: '%@'", searchString);
    NSLog(@"regexString : '%@'", regexString);
    
    for (NSString *matchedString in [searchString substringsMatchedByRegex:regexString]) {
        NSLog(@"Line: %lu, length: %lu, matched string: '%@'", ++line, matchedString.length, matchedString);
        matchCount++;
    }
    
    XCTAssertTrue(matchCount == 4);
}

- (void)testCaptureExample
{
    // Copyright COPYRIGHT_SIGN APPROXIMATELY_EQUAL_TO 2008
    // Copyright \u00a9 \u2245 2008

    char *utf8CString = "Copyright \xC2\xA9 \xE2\x89\x85 2008";
    NSString *regexString = @"Copyright (.*) (\\d+)";
    NSString *subjectString = [NSString stringWithUTF8String:utf8CString];
    NSString *matchedString = [subjectString stringMatchedByRegex:regexString capture:1L];
    NSRange matchRange = [subjectString rangeOfRegex:regexString capture:1L];
    
    XCTAssertTrue(NSEqualRanges(matchRange, NSMakeRange(10, 3)), @"range: %@", NSStringFromRange(matchRange));

    NSLog(@"subject: \"%@\"", subjectString);
    NSLog(@"matched: \"%@\"", matchedString);
}

#pragma mark - Ported RegexKit 0.6 Test Cases

- (void)testValidationOfRegexStrings
{
    XCTAssertTrue([@"123" isRegexValidWithOptions:RKXNoOptions error:NULL], @"Should be valid");
    XCTAssertTrue([@"^(Match)\\s+the\\s+(MAGIC)$" isRegexValidWithOptions:RKXNoOptions error:NULL], @"Should be valid");
    
    // ICU likes this regex under a weird options combo (that included ignoring all metacharacters)
    NSString *weirdMetacharacterRegex = @"\\( ( ( ([^()]+) | (?R) )* ) \\)";
    XCTAssertTrue([weirdMetacharacterRegex isRegexValidWithOptions:0xffffffff error:NULL]);
    // But didn't when options = 0
    XCTAssertFalse([weirdMetacharacterRegex isRegexValidWithOptions:RKXNoOptions error:NULL]);

    // ICU fails a number of perfectly good PCRE regexes.
    NSError *error;
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&pn) )* \\) )" isRegexValidWithOptions:RKXNoOptions error:&error], @"error: %@ (This is a good PCRE regex)", error.localizedDescription);
    NSLog(@"error: %@ (This is a good PCRE regex)", error.localizedDescription);
    XCTAssertFalse([@"\\( ( ( (?>[^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:RKXNoOptions error:&error], @"error: %@ (This is a good PCRE regex)", error.localizedDescription);
    NSLog(@"error: %@ (This is a good PCRE regex)", error.localizedDescription);
    XCTAssertFalse([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:RKXNoOptions error:&error], @"error: %@ (This is a good PCRE regex)", error.localizedDescription);
    NSLog(@"error: %@ (This is a good PCRE regex)", error.localizedDescription);

    // These are bad PCRE regexes
    XCTAssertFalse([@"^(Match)\\s+the\\s+((MAGIC)$" isRegexValidWithOptions:RKXNoOptions error:&error], @"error: %@", error.localizedDescription);
    NSLog(@"error: %@", error.localizedDescription);
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&xq) )* \\) )" isRegexValidWithOptions:RKXNoOptions error:&error], @"error: %@", error.localizedDescription);
    NSLog(@"error: %@", error.localizedDescription);

    NSString *nilString = nil;
    XCTAssertFalse([nilString isRegexValidWithOptions:RKXNoOptions error:NULL]);
}

- (void)testSimpleUnicodeMatching
{
    NSString *copyrightString = self.unicodeStrings[3];
    NSRange rangeOf2007 = [copyrightString rangeOfRegex:@"2007"];
    NSRange foundationRange = [copyrightString rangeOfString:@"2007"];
    XCTAssertTrue(NSEqualRanges(foundationRange, rangeOf2007));
    
    NSArray<NSValue *> *regexRanges = [copyrightString rangesOfRegex:@"^(\\w+)\\s+(\\p{Any}+)\\s+(2007)$"];
    XCTAssertTrue((NSEqualRanges(regexRanges[0].rangeValue, NSMakeRange(0, 16))), @"%@", regexRanges[0]);
    XCTAssertTrue((NSEqualRanges(regexRanges[1].rangeValue, NSMakeRange(0, 9))), @"%@", regexRanges[1]);
    XCTAssertTrue((NSEqualRanges(regexRanges[2].rangeValue, NSMakeRange(10, 1))), @"%@", regexRanges[2]);
    XCTAssertTrue((NSEqualRanges(regexRanges[3].rangeValue, NSMakeRange(12, 4))), @"%@", regexRanges[3]);
}

#pragma mark - Hero's Journey Unicode Testing

- (void)testHerosJourneyUnicode
{
    NSString *herosJourney = self.unicodeStrings[8];
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷂"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝌢"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝌌"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷢"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝍕"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝍐"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝍃"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷣"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷅"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷿"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝍓"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷪"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝌴"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷧"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"𝍎"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷾"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷊"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷍"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷶"]);
    XCTAssertTrue([herosJourney isMatchedByRegex:@"䷀"]);
}

#pragma mark - Mastering Regular Expression 3rd Ed. examples

- (void)testDoubledWordExampleUsingBackreferences
{
    // mre3 = "Mastering Regular Expressions, 3rd Ed."
    NSString *mre3Text = @"In many regular-expression flavors, parentheses can \"remember\" text matched by the subexpression they enclose. We'll use this in a partial solution to the doubled-word problem at the beginning of this chapter. If you knew the the specific doubled word to find (such as \"the\" earlier in this sentence — did you catch it?)....\n"
    "\nExcerpt From: Jeffrey E. F. Friedl. \"Mastering Regular Expressions, Third Edition.\" Apple Books.";

    NSString *regex = @"\\b([A-Za-z]+) \\1\\b";
    XCTAssertTrue([mre3Text isMatchedByRegex:regex]);
}

- (void)testFirstLookaheadExample
{
    NSString *jeffs = @"Jeffs";

    // backward-to-forward lookaround
    NSString *output = [jeffs stringByReplacingOccurrencesOfRegex:@"(?<=\\bJeff)(?=s\\b)" withTemplate:@"\'"];
    XCTAssertTrue([output isEqualToString:@"Jeff\'s"]);

    // forward-to-backward lookaround
    NSString *output2 = [jeffs stringByReplacingOccurrencesOfRegex:@"(?=s\\b)(?<=\\bJeff)" withTemplate:@"\'"];
    XCTAssertTrue([output2 isEqualToString:@"Jeff\'s"]);
}

- (void)testLookaheadPopulationExample
{
    // As of 2018-10-16 07:06:50 -0700 from https://www.census.gov/popclock/
    NSString *rawUSPop = @"328807309";
    NSString *testControl = @"328,807,309";

    // Positive lookbehind (?<=...) and positive lookahead (?=...)
    NSString *formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d\\d\\d)+$)" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);

    // More compact digit-matching sub-regex
    formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+$)" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);

    // Positive lookbehind (?<=...), positive lookahead (?=...), and Negative lookahead (?!...)
    formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+(?!\\d))" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);

    // Non-capturing parentheses (?:...)
    // NOTE: A little more efficient since they don't spend extra ops capturing.
    formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(?:\\d{3})+$)" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);

    // Negative lookbehind (?<!...)
    formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<!\\b)(?=(?:\\d{3})+$)" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);

    // Positive lookbehind (?<=...), positive lookahead (?=...)
    NSString *someBillions = @"8927369280";
    NSString *commaOutput = [someBillions stringByReplacingOccurrencesOfRegex:@"(?<=\\d)(?=(\\d{3})+$)" withTemplate:@","];
    XCTAssertTrue([commaOutput isEqualToString:@"8,927,369,280"]);
}

#if NFA_FAIL_TEST
- (void)testCrazyNFAPerformance
{
    // This is from the NFA example in MRE3 chapter 4.
    // It didn't finish after runnning about a minute or so.
    // That's why I'm using a preprocessor directive to turn this test off.
    NSString *equalString = @"=XX=========================================";
    BOOL result = [equalString isMatchedByRegex:@"X(.+)+X"];
    XCTAssertFalse(result);
}
#endif

- (void)testCrazyNFAPerformanceWithNSMatchingProgressExample
{
    // This is from the NFA example in MRE3 chapter 4.
    // It didn't finish after runnning about a minute or so.

    NSString *equalString = @"=XX=========================================";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"X(.+)+X" options:kNilOptions error:&error];
    NSDate *date1 = [NSDate date];
    __block NSDate *date2;
    __block BOOL didExitOnPunt = NO;
    NSRange zeroRange = NSMakeRange(0, 0);

    [regex enumerateMatchesInString:equalString options:NSMatchingReportProgress range:equalString.stringRange usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        date2 = [NSDate date];
        NSTimeInterval delta = [date2 timeIntervalSinceDate:date1];
        XCTAssertNil(result);
        XCTAssertTrue(NSEqualRanges(result.range, zeroRange));

        if (delta > 1.0) {
            *stop = YES;
            NSLog(@"This is taking too long! Punting...");
            didExitOnPunt = YES;
        }
    }];

    XCTAssertTrue(didExitOnPunt);
}

- (void)testCrazyNFAWithPunting
{
    NSString *equalString = @"=XX=========================================";
    NSString *regex = @"X(.+)+X";
    NSError *error;
    BOOL result = [equalString isMatchedByRegex:regex
                                          range:equalString.stringRange
                                        options:RKXNoOptions
                                   matchOptions:(RKXReportProgress | RKXReportCompletion)
                                          error:&error];
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
    XCTAssertTrue([error.domain isEqualToString:RKXMatchingTimeoutErrorDomain]);
    XCTAssertEqual(error.code, RKXMatchingTimeoutError);
    XCTAssertNotNil(error.userInfo[NSLocalizedDescriptionKey]);
    XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey]);
    XCTAssertNotNil(error.userInfo[NSLocalizedRecoverySuggestionErrorKey]);
}

- (void)testNormalNFAWithPuntingOptionThatSuccessfullyMatches
{
    NSString *da = @"310-555-1212";
    NSString *regex = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSError *error;
    BOOL result = [da isMatchedByRegex:regex
                                 range:da.stringRange
                               options:RKXNoOptions
                          matchOptions:(RKXReportProgress | RKXReportCompletion)
                                 error:&error];
    XCTAssertTrue(result);
    XCTAssertNil(error);
}

#pragma mark - Apple Bugs

#if TEST_APPLE_BUGS
// These two tests are for Apple's devs to fix. They demonstrate the issues
// documented in their respected Radars.
- (void)testAppleBugWithNamedBackreferenceSubstitutionTest
{
    // da = directory assistance
    // rdar://46309223
    NSString *da = @"310-555-1212";
    NSString *pattern = @"(?<area>\\d{3})-((?<exch>\\d{3})-(?<num>\\d{4}))";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
    NSString *template = @"Reversed number: ${num}-${exch}-${area}";
    NSString *output = [regex stringByReplacingMatchesInString:da options:kNilOptions range:NSMakeRange(0, da.length) withTemplate:template];
    NSString *testControl = @"Reversed number: 1212-555-310";
    XCTAssertTrue([output isEqualToString:testControl], @"Output is %@", output);

    NSMutableString *mutableDA = [da mutableCopy];
    NSUInteger substitutionCount = [regex replaceMatchesInString:mutableDA options:kNilOptions range:NSMakeRange(0, da.length) withTemplate:template];
    XCTAssertTrue(substitutionCount == 3, @"substitution count = %lu", substitutionCount);
    XCTAssertTrue([mutableDA isEqualToString:testControl], @"mutatated string is %@", output);
}

- (void)testAppleBugWithCaseSensitiveUnicodeMatching
{
    // In Greek, the "BRAVO" characters are:
    // 'B' - Beta
    // 'R' - Rho
    // 'A' - Alpha
    // 'V' - Upsilon (Best I could do instead of a classic "V"
    // 'O' - Omicron

    // rdar://46309431
    NSString *upperCaseBravo = @"𝛣𝛲𝛢𝛶𝛰";
    NSString *lowerCaseBravo = @"𝛽𝜌𝛂𝜐𝜊";
    NSRegularExpression *bravoRegex = [NSRegularExpression regularExpressionWithPattern:upperCaseBravo options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRange ucBravoRange = [bravoRegex rangeOfFirstMatchInString:upperCaseBravo options:kNilOptions range:NSMakeRange(0, upperCaseBravo.length)];
    XCTAssertTrue(ucBravoRange.location == 0, @"Failed match: location = %@", (ucBravoRange.location == NSNotFound) ? @"NSNotFound" : @(ucBravoRange.location));
    XCTAssertTrue(ucBravoRange.length == 10, @"Failed match: length = %lu", ucBravoRange.length);

    NSRange lcBravoRange = [bravoRegex rangeOfFirstMatchInString:lowerCaseBravo options:kNilOptions range:NSMakeRange(0, lowerCaseBravo.length)];
    XCTAssertTrue(lcBravoRange.location == 0, @"Failed match: location = %@", (lcBravoRange.location == NSNotFound) ? @"NSNotFound" : @(lcBravoRange.location));
    XCTAssertTrue(lcBravoRange.length == 10, @"Failed match: length = %lu", lcBravoRange.length);
}
#endif

#pragma mark - Performance Tests
// These performance tests were adapted from https://rpubs.com/jonclayden/regex-performance
// by Jon Clayden

- (void)testPerformanceRegex01
{
    // The literal string, “Sherlock”
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"Sherlock" options:RKXMultiline];
        XCTAssertTrue(matches.count == 97);
    }];
}

- (void)testPerformanceRegex01WithProgress
{
    [self measureBlock:^{
        NSError *error;
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"Sherlock"
                                                               range:self.testCorpus.stringRange
                                                             capture:0
                                                        namedCapture:nil
                                                             options:RKXMultiline
                                                        matchOptions:RKXReportProgress
                                                               error:&error];
        XCTAssertTrue(matches.count == 97);
        XCTAssertNil(error);
    }];
}

- (void)testPerformanceRegex02
{
    // “Sherlock” at the beginning of a line
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"^Sherlock" options:RKXMultiline];
        XCTAssertTrue(matches.count == 34, @"The count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex03
{
    // “Sherlock” at the end of a line
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"Sherlock$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 6, @"The count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex04
{
    // The letters “a” and “b”, separated by 20 other characters that aren’t “x”
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"a[^x]{20}b" options:RKXMultiline];
        XCTAssertTrue(matches.count == 405, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex05
{
    // Either of the strings “Holmes” or “Watson”
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"Holmes|Watson" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex06
{
    // Zero to three characters, followed by either of the strings “Holmes” or “Watson”
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@".{0,3}(Holmes|Watson)" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex07
{
    // Any word ending in “ing”
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"[a-zA-Z]+ing" options:RKXMultiline];
        XCTAssertTrue(matches.count == 2824, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex08
{
    // Up to four letters followed by “ing” and then a non-letter, at the beginning of a line
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"^([a-zA-Z]{0,4}ing)[^a-zA-Z]" options:RKXMultiline];
        XCTAssertTrue(matches.count == 163, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex09
{
    // Any word ending in “ing”, at the end of a line
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"[a-zA-Z]+ing$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 152, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex10
{
    // Lines consisting of five or more letters and spaces, only
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"^[a-zA-Z ]{5,}$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 876, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex11
{
    // Lines of between 16 and 20 characters
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"^.{16,20}$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 238, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex12
{
    // Sequences of characters from certain sets (complex to explain!)
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"([a-f](.[d-m].){0,2}[h-n]){2}" options:RKXMultiline];
        XCTAssertTrue(matches.count == 1597, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex13
{
    // A word ending in “olmes” or “atson”, followed by a non-letter
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"([A-Za-z]olmes)|([A-Za-z]atson)[^a-zA-Z]" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex14
{
    // A quoted string of between 0 and 30 characters, ending with a punctuation mark
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"\"[^\"]{0,30}[?!\\.]\"" options:RKXMultiline];
        XCTAssertTrue(matches.count == 582, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex15
{
    // The names “Holmes” and “Watson” on the same line, separated by 10 to 60 other characters
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus substringsMatchedByRegex:@"Holmes.{10,60}Watson|Watson.{10,60}Holmes" options:RKXMultiline];
        XCTAssertTrue(matches.count == 2, @"The match count is %lu", matches.count);
    }];
}

#pragma mark - NSHipster

- (void)testNSHipsterCluedoRegex
{
    // From: https://nshipster.com/swift-regular-expressions/
    NSString *suggestion = @"I suspect it was Professor Plum, "
    "in the Dining Room, "
    "with the Candlestick.";
    NSString *regex = @""
    "(?xi)" // This allows for white space, #comments and case-insensitive matching within the pattern
    "(?<suspect>"
    "((Miss|Ms\\.) \\h Scarlett?) |"
    "((Colonel | Col\\.) \\h Mustard) |"
    "((Reverend | Mr\\.) \\h Green) |"
    "(Mrs\\. \\h Peacock) |"
    "((Professor | Prof\\.) \\h Plum) |"
    "((Mrs\\. \\h White) | ((Doctor | Dr\\.) \\h Orchid))"
    "),?(?-x: in the )"
    "(?<location>"
    "Kitchen           | Ballroom | Conservatory |"
    "Dining \\h Room   | Library  |"
    "Lounge            | Hall     | Study"
    "),?(?-x: with the )"
    "(?<weapon>"
    "Candlestick"
    "| Knife"
    "| (Lead(en)?\\h)? Pipe"
    "| Revolver"
    "| Rope"
    "| Wrench"
    ")"
    "";

    for (NSString *component in @[ @"suspect", @"location", @"weapon" ]) {
        NSString *result = [suggestion stringMatchedByRegex:regex namedCapture:component];
        NSLog(@"%@: %@", component, result);
    }
}

#pragma mark - Palindrome

- (void)testPalindromeRegex
{
    NSString *regex = @"\\b(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*"
                        "(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*"
                        "(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*(?:(\\w)[ \\t,'\"]*\\11?"
                        "[ \\t,'\"]*\\10|\\10?)[ \\t,'\"]*\\9|\\9?)[ \\t,'\"]*\\8|\\8?)"
                        "[ \\t,'\"]*\\7|\\7?)[ \\t,'\"]*\\6|\\6?)[ \\t,'\"]*\\5|\\5?)"
                        "[ \\t,'\"]*\\4|\\4?)[ \\t,'\"]*\\3|\\3?)[ \\t,'\"]*\\2|\\2?))?[ \\t,'\"]*\\1\\b";
    NSString *palindrome = @"A man, a plan, a canal, Panama!";
    NSString *reversedString = [palindrome stringByReplacingOccurrencesOfRegex:regex withTemplate:@"$11$10$9$8$7 $6$5$4$3$2$1" options:RKXCaseless];
    XCTAssertTrue([reversedString isEqualToString:@"canal panamA!"]);
}

#pragma mark - Test Internal Assertions

- (void)testNilRegex
{
    XCTAssertThrows([self.candidate isMatchedByRegex:nil], @"This should have raised on a nil pattern");
}

- (void)testInvalidRanges
{
    XCTAssertThrows([self.candidate isMatchedByRegex:RKXEmptyStringKey range:NSMakeRange(0, NSNotFound)]);
    XCTAssertThrows([self.candidate isMatchedByRegex:RKXEmptyStringKey range:NSMakeRange(NSNotFound, 0)]);
    XCTAssertThrows([self.candidate isMatchedByRegex:RKXEmptyStringKey range:NSMakeRange(NSNotFound, self.candidate.stringRange.length)]);
}

#pragma mark - Miscellaneous

- (void)testCaptureSplitting
{
    NSString *regex = @"([RS])(\\d{1,2})";
    NSArray<NSString *> *captures = [@"R5" captureSubstringsMatchedByRegex:regex];
    NSString *letter = captures[1];
    NSString *number = captures[2];
    XCTAssertTrue([letter isEqualToString:@"R"]);
    XCTAssertTrue([number isEqualToString:@"5"]);
}

- (void)testAnotherNegativeLookahead
{
    // ^(?!(.)\1*$)[0-9A-Z]{0,25}$
    // 111112 - match
    // AABD333434 - match
    // 55555555 - no match
    // 555 - no match
    NSString *regex = @"^(?!(.)\\1*$)[0-9A-Z]{0,25}$";

    XCTAssertTrue([@"111112" isMatchedByRegex:regex]);
    XCTAssertTrue([@"AABD333434" isMatchedByRegex:regex]);
    XCTAssertFalse([@"55555555" isMatchedByRegex:regex]);
    XCTAssertFalse([@"555" isMatchedByRegex:regex]);
}

@end
