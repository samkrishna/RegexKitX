//
//  RegexKitXTests.m
//  RegexKitXTests

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

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

- (void)testMatchesRegexRangeOptionsMatchingOptionsError
{
    // NOTE: Not Comprehensive Yet
    NSError *error;
    NSString *regex = @"(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*";
    XCTAssertTrue([self.candidate isMatchedByRegex:regex range:self.candidate.stringRange options:RKXCaseless error:nil]);
    XCTAssertFalse([self.candidate isMatchedByRegex:regex range:self.candidate.stringRange options:RKXNoOptions matchOptions:0 error:&error], @"Error: %@", error);

    NSString *testString = @"Orthogonal2";
    BOOL testResult = [testString isMatchedByRegex:@"orthogonal" range:testString.stringRange options:RKXCaseless error:&error];
    XCTAssertTrue(testResult);
}

- (void)testComponentsSeparatedByRegex
{
    NSString *regex = @", ";
    NSArray *captures = [self.candidate componentsSeparatedByRegex:regex];
    XCTAssertTrue(captures.count == 12);
    
    for (NSString *substring in captures) {
        BOOL result = [substring isMatchedByRegex:@", "];
        XCTAssertFalse(result, @"There should be no separators in this substring! (%@)", substring);
    }
}

- (void)testRangeOfRegexOptionsMatchingOptionsInRangeCaptureError
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSRange entireRange = self.candidate.stringRange;
    NSRange captureRange = [self.candidate rangeOfRegex:regex range:entireRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(captureRange.location == 0);
    XCTAssertTrue(captureRange.length == 19);
    
    NSRange dateRange = [self.candidate rangeOfRegex:regex range:entireRange capture:1 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(dateRange.location == 0);
    XCTAssertTrue(dateRange.length == 10);

    NSRange yearRange = [self.candidate rangeOfRegex:regex range:entireRange capture:2 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(yearRange.location == 0);
    XCTAssertTrue(yearRange.length == 4);

    NSRange monthRange = [self.candidate rangeOfRegex:regex range:entireRange capture:3 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(monthRange.location == 5);
    XCTAssertTrue(monthRange.length == 2);

    NSRange dayRange = [self.candidate rangeOfRegex:regex range:entireRange capture:4 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(dayRange.location == 8);
    XCTAssertTrue(dayRange.length == 2);

    NSRange timeRange = [self.candidate rangeOfRegex:regex range:entireRange capture:5 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(timeRange.location == 11);
    XCTAssertTrue(timeRange.length == 8);

    NSRange hourRange = [self.candidate rangeOfRegex:regex range:entireRange capture:6 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(hourRange.location == 11);
    XCTAssertTrue(hourRange.length == 2);

    NSRange minuteRange = [self.candidate rangeOfRegex:regex range:entireRange capture:7 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(minuteRange.location == 14);
    XCTAssertTrue(minuteRange.length == 2);

    NSRange secondRange = [self.candidate rangeOfRegex:regex range:entireRange capture:8 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(secondRange.location == 17);
    XCTAssertTrue(secondRange.length == 2);
}

- (void)testFailedRangeOfRegex
{
    NSRange failRange = [self.candidate rangeOfRegex:@"blah"];
    XCTAssertTrue(failRange.location == NSNotFound);
}

- (void)testStringMatchedByRegexRangeCaptureOptionsMatchOptionsError
{
    NSString *regexPattern = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
    NSRange entireRange = self.candidate.stringRange;
    NSString *fullTimestamp = [self.candidate stringMatchedByRegex:regexPattern range:entireRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue([fullTimestamp isEqualToString:@"2014-05-06 17:03:17"]);

    NSString *datestamp = [self.candidate stringMatchedByRegex:regexPattern range:entireRange capture:1 options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue([datestamp isEqualToString:@"2014-05-06"]);
}

- (void)testStringByReplacingOccurrencesOfRegexWithTemplateOptionsMatchingOptionsRangeError
{
    NSString *failedPattern = @"2014-05-06 17:03:17.967 EXECUTION_DINO";
    NSString *failureControl = @"2014-05-06 17:03:17.967 EXECUTION_DATA";
    NSRange failureRange = NSMakeRange(0, 38);
    NSString *failureResult = [self.candidate stringByReplacingOccurrencesOfRegex:failedPattern withTemplate:@"BARNEY RUBBLE" range:failureRange options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue([failureResult isEqualToString:failureControl]);

    NSString *successPattern = @"\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+ (EXECUTION_DATA)";
    NSString *successResult = [self.candidate stringByReplacingOccurrencesOfRegex:successPattern withTemplate:@"BARNEY RUBBLE ~~~$1~~~" range:failureRange options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue([successResult isMatchedByRegex:@"BARNEY RUBBLE"]);
    XCTAssertTrue([successResult isMatchedByRegex:@"~~~EXECUTION_DATA~~~"]);
}

- (void)testStringByReplacingOccurrencesOfRegexRangeOptionsMatchOptionsErrorUsingBlock
{
    NSString *pattern = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";
    NSRange entireRange = self.candidate.stringRange;

    NSString *output = [self.candidate stringByReplacingOccurrencesOfRegex:pattern range:entireRange options:RKXNoOptions matchOptions:0 error:NULL usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
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
    pattern = @"pick(led)?";
    NSString *newCandidate = @"Peter Piper picked a peck of pickled peppers;\n"
                             @"A peck of pickled peppers Peter Piper picked;\n"
                             @"If Peter Piper picked a peck of pickled peppers,\n"
                             @"Where's the peck of pickled peppers Peter Piper picked?";
    output = [newCandidate stringByReplacingOccurrencesOfRegex:pattern range:newCandidate.stringRange options:RKXNoOptions matchOptions:0 error:NULL usingBlock:^NSString *(NSArray *capturedStrings, NSArray *capturedRanges, BOOL *stop) {
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

- (void)testArrayOfCaptureComponentsMatchedByRegexRangeOptionsMatchOptionsError
{
    NSString *list      = @"$10.23, $1024.42, $3099";
    NSArray *listItems = [list arrayOfCaptureComponentsMatchedByRegex:@"\\$((\\d+)(?:\\.(\\d+)|\\.?))" range:list.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
    XCTAssertTrue(listItems.count == 3);

    NSArray *list0 = listItems[0];
    BOOL result0 = [list0 isEqualToArray:@[ @"$10.23", @"10.23", @"10", @"23" ]];
    XCTAssertTrue(result0);

    NSArray *list1 = listItems[1];
    BOOL result1 = [list1 isEqualToArray:@[ @"$1024.42", @"1024.42", @"1024", @"42" ]];
    XCTAssertTrue(result1);

    NSArray *list2 = listItems[2];
    BOOL result2 = [list2 isEqualToArray:@[ @"$3099", @"3099", @"3099", @"" ]];
    XCTAssertTrue(result2);
}

- (void)testComponentsMatchedByRegexRangeCaptureOptionsError
{
    NSString *list = @"$10.23, $1024.42, $3099";
    NSArray *listItems = [list componentsMatchedByRegex:@"\\$((\\d+)(?:\\.(\\d+)|\\.?))" range:list.stringRange capture:3 options:RKXNoOptions error:NULL];
    
    XCTAssertTrue([listItems[0] isEqualToString:@"23"]);
    XCTAssertTrue([listItems[1] isEqualToString:@"42"]);
    XCTAssertTrue([listItems[2] isEqualToString:@""]);
}

- (void)testCaptureComponentsMatchedByRegex
{
    NSString *regex = @"((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+).(\\d+))";
    NSArray *captures = [self.candidate captureComponentsMatchedByRegex:regex];
    XCTAssertTrue(captures.count == 10);
    XCTAssertTrue([captures[1] isEqualToString:@"2014-05-06"]);
    XCTAssertTrue([captures[5] isEqualToString:@"17:03:17.967"]);
}

- (void)testCaptureCountWithOptionsError
{
    NSString *pattern = @"\\$((\\d+)(?:\\.(\\d+)|\\.?))";
    NSError *error;
    NSUInteger captureCount = [pattern captureCountWithOptions:RKXNoOptions error:&error];
    XCTAssertTrue(captureCount == 3);
}

- (void)testDictionaryMatchedByRegexRangeOptionsErrorWithKeysAndCaptures
{
    NSString *name = @"Name: Joe";
    NSString *regex = @"Name:\\s*(\\w*)\\s*(\\w*)";
    NSString *firstKey = @"first";
    NSString *lastKey = @"last";
    NSDictionary *nameDictionary = [name dictionaryMatchedByRegex:regex
                                                            range:name.stringRange
                                                          options:RKXNoOptions
                                                            error:NULL
                                              withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];

    XCTAssertTrue([nameDictionary[firstKey] isEqualToString:@"Joe"]);
    XCTAssertTrue([nameDictionary[lastKey] isEqualToString:@""]);
    
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

- (void)testArrayOfDictionariesMatchedByRegexRangeOptionsMatchOptionsErrorWithKeysAndCaptures
{
    NSString *name = @"Name: Bob\nName: John Smith";
    NSString *regex = @"(?m)^Name:\\s*(\\w*)\\s*(\\w*)$";
    NSString *firstKey = @"first";
    NSString *lastKey = @"last";
    NSArray  *nameArray = [name arrayOfDictionariesMatchedByRegex:regex
                                                            range:name.stringRange
                                                          options:RKXNoOptions
                                                     matchOptions:0
                                                            error:NULL
                                              withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];

    NSDictionary *name1 = nameArray[0];
    XCTAssertTrue([name1[firstKey] isEqualToString:@"Bob"]);
    XCTAssertTrue([name1[lastKey] isEqualToString:@""]);

    NSDictionary *name2 = nameArray[1];
    XCTAssertTrue([name2[firstKey] isEqualToString:@"John"]);
    XCTAssertTrue([name2[lastKey] isEqualToString:@"Smith"]);

    NSArray *failureResult = [self.candidate arrayOfDictionariesMatchedByRegex:regex
                                                                         range:self.candidate.stringRange
                                                                       options:RKXNoOptions
                                                                  matchOptions:0
                                                                         error:NULL
                                                           withKeysAndCaptures:firstKey, 1, lastKey, 2, nil];
    XCTAssertNotNil(failureResult);
    XCTAssertTrue(failureResult.count == 0);
}

- (void)testEnumerateStringsSeparatedByRegexUsingBlock
{
    NSString *regexPattern = @",(\\s+)";
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
    BOOL result = [self.candidate enumerateStringsSeparatedByRegex:regexPattern usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSRange range = capturedRanges[0].rangeValue;
        NSRange rangeCheck = rangeValueChecks[index].rangeValue;
        NSLog(@"Forward: string = %@ and range = %@", capturedStrings[0], NSStringFromRange(range));
        XCTAssertTrue(NSEqualRanges(range, rangeCheck), @"The string (%@) doesn't have the correct ranges: %@ != %@", capturedStrings[0], NSStringFromRange(range), NSStringFromRange(rangeCheck));
        index++;
    }];

    XCTAssertTrue(result);
    index--;

    result = [self.candidate enumerateStringsSeparatedByRegex:regexPattern range:self.candidate.stringRange options:0 matchOptions:0 enumerationOptions:NSEnumerationReverse error:NULL usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
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
    // ICU bug http://bugs.icu-project.org/trac/ticket/6826
    //
    // ICU : "", "I", "|", "at", "|", "ice", "", "I", "", "eat", "", "rice" <- Results that RegexKitX produces
    // PERL:     "I", "|", "at", "|", "ice",     "I",     "eat",     "rice" <- Results that RKL4 produces.

    // Follow-up: I followed the ticket to see what the outcome was. The ICU dev team closed this ticket
    // by asserting that the behavior worked as intended, which is to clone Java's split().
    // I'm noting this here for historical purposes.

    NSString *testString = @"I|at|ice I eat rice";
    NSString *pattern = @"\\b\\s*";
    NSArray<NSString *> *components = [testString componentsSeparatedByRegex:pattern];
    XCTAssertFalse([components.firstObject isEqualToString:@"I"]);
    XCTAssertTrue([components.firstObject isEqualToString:@""]);
    XCTAssertTrue([components.lastObject isEqualToString:@"rice"]);
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
        NSLog(@"%lu: %lu '%@'", ++line, matchedString.length, matchedString);
        matchCount++;
    }];
    
    XCTAssertTrue(matchCount == 4);
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
        NSLog(@"%lu: %lu '%@'", ++line, matchedString.length, matchedString);
        matchCount++;
    }
    
    XCTAssertTrue(matchCount == 4);
}

- (void)testLinkExample
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

- (void)testRegexString
{
    NSString *pattern123 = [NSString stringWithFormat:@"123"];
    XCTAssertTrue([pattern123 isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    NSString *patternMAGIC = [NSString stringWithFormat:@"^(Match)\\s+the\\s+(MAGIC)$"];
    XCTAssertTrue([patternMAGIC isRegexValidWithOptions:0 error:NULL], @"Should be valid");
}

- (void)testValidRegexString
{
    XCTAssertTrue([@"123" isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    XCTAssertTrue([@"^(Match)\\s+the\\s+(MAGIC)$" isRegexValidWithOptions:0 error:NULL], @"Should be valid");
    
    // ICU likes this regex under a weird options combo (that included ignoring all metacharacters)
    XCTAssertTrue([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0xffffffff error:NULL]);
    // But didn't when options = 0
    XCTAssertFalse([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL]);

    // ICU fails a number of perfectly good PCRE regexes.
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&pn) )* \\) )" isRegexValidWithOptions:0 error:NULL]);
    XCTAssertFalse([@"\\( ( ( (?>[^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL]);
    XCTAssertFalse([@"\\( ( ( ([^()]+) | (?R) )* ) \\)" isRegexValidWithOptions:0 error:NULL]);
    
    // These are bad PCRE regexes
    XCTAssertFalse([@"^(Match)\\s+the\\s+((MAGIC)$" isRegexValidWithOptions:0 error:NULL]);
    XCTAssertFalse([@"(?<pn> \\( ( (?>[^()]+) | (?&xq) )* \\) )" isRegexValidWithOptions:0 error:NULL]);

    NSString *nilString = nil;
    XCTAssertFalse([nilString isRegexValidWithOptions:0 error:NULL]);
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

    NSString *pattern = @"\\b([A-Za-z]+) \\1\\b";
    XCTAssertTrue([mre3Text isMatchedByRegex:pattern]);
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

    // Positive lookbehind and lookahead
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

    // Negative lookbehind (?<!)
    formattedUSPop = [rawUSPop stringByReplacingOccurrencesOfRegex:@"(?<!\\b)(?=(?:\\d{3})+$)" withTemplate:@","];
    XCTAssertTrue([formattedUSPop isEqualToString:testControl]);
}

#pragma mark - Performance Tests
// These performance tests were adapted from https://rpubs.com/jonclayden/regex-performance
// by Jon Clayden

- (void)testPerformanceRegex01
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"Sherlock" options:RKXMultiline];
        XCTAssertTrue(matches.count == 97);
    }];
}

- (void)testPerformanceRegex02
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"^Sherlock" options:RKXMultiline];
        XCTAssertTrue(matches.count == 34, @"The count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex03
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"Sherlock$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 6, @"The count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex04
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"a[^x]{20}b" options:RKXMultiline];
        XCTAssertTrue(matches.count == 405, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex05
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"Holmes|Watson" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex06
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@".{0,3}(Holmes|Watson)" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex07
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"[a-zA-Z]+ing" options:RKXMultiline];
        XCTAssertTrue(matches.count == 2824, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex08
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"^([a-zA-Z]{0,4}ing)[^a-zA-Z]" options:RKXMultiline];
        XCTAssertTrue(matches.count == 163, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex09
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"[a-zA-Z]+ing$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 152, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex10
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"^[a-zA-Z ]{5,}$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 876, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex11
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"^.{16,20}$" options:RKXMultiline];
        XCTAssertTrue(matches.count == 238, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex12
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"([a-f](.[d-m].){0,2}[h-n]){2}" options:RKXMultiline];
        XCTAssertTrue(matches.count == 1597, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex13
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"([A-Za-z]olmes)|([A-Za-z]atson)[^a-zA-Z]" options:RKXMultiline];
        XCTAssertTrue(matches.count == 542, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex14
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"\"[^\"]{0,30}[?!\\.]\"" options:RKXMultiline];
        XCTAssertTrue(matches.count == 582, @"The match count is %lu", matches.count);
    }];
}

- (void)testPerformanceRegex15
{
    [self measureBlock:^{
        NSArray *matches = [self.testCorpus componentsMatchedByRegex:@"Holmes.{10,60}Watson|Watson.{10,60}Holmes"];
        XCTAssertTrue(matches.count == 2, @"The match count is %lu", matches.count);
    }];
}


@end
