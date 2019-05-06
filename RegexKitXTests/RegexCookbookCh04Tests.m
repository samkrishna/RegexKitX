//
//  RegexCookbookCh04Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 12/25/18.
//  Copyright © 2018 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh04Tests : XCTestCase

@end

@implementation RegexCookbookCh04Tests

- (void)testRegexFromSection41
{
    NSString *testEmail = @"hello.from@example.com";
    XCTAssertTrue([testEmail isMatchedByRegex:@"^\\S+@\\S+$"]);
    XCTAssertTrue([testEmail isMatchedByRegex:@"^[A-Z0-9+_.-]+@[A-Z0-9.-]+$" options:RKXCaseless]);
    XCTAssertTrue([testEmail isMatchedByRegex:@"^[A-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[A-Z0-9.-]+$" options:RKXCaseless]);

    NSString *noLeadingTrailingOrConsecutiveDots = @"^[A-Z0-9_!#$%&'*+/=?`{|}~^-]+(?:\\.[A-Z0-9_!#$%&'*+/=?`{|}~^-]+)*@[A-Z0-9-]+(?:\\.[A-Z0-9-]+)*$";
    XCTAssertTrue([testEmail isMatchedByRegex:noLeadingTrailingOrConsecutiveDots options:RKXCaseless]);

    NSString *tldHas2to6LettersRegex = @"^[\\w!#$%&'*+/=?`{|}~^-]+(?:\\.[\\w!#$%&'*+/=?`{|}~^-]+)*@(?:[A-Z0-9-]+\\.)+[A-Z]{2,6}$";
    XCTAssertTrue([testEmail isMatchedByRegex:tldHas2to6LettersRegex options:RKXCaseless]);
}

- (void)testRegexFromSection42
{
    NSString *phoneRegex = @"^\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$";
    NSString *phone01 = @"3105551212";
    XCTAssertTrue([phone01 isMatchedByRegex:phoneRegex]);
    NSString *formattedPhone = [phone01 stringByReplacingOccurrencesOfRegex:phoneRegex withTemplate:@"($1) $2-$3"];
    XCTAssertTrue([formattedPhone isEqualToString:@"(310) 555-1212"]);
}

- (void)testRegexFromSection43
{
    NSString *intlPhoneRegex = @"^\\+(?:[0-9] ?){6,14}[0-9]$";
    NSString *chinesePhone = @"+86 10 6552 9988";
    NSString *usaPhone = @"+1 310 555 1212";
    NSString *argentinaPhone = @"+54 9 223 1234567";

    XCTAssertTrue([chinesePhone isMatchedByRegex:intlPhoneRegex]);
    XCTAssertTrue([usaPhone isMatchedByRegex:intlPhoneRegex]);
    XCTAssertTrue([argentinaPhone isMatchedByRegex:intlPhoneRegex]);
}

- (void)testRegexFromSection44
{
    NSString *simpleDateRegex = @"^[0-3]?[0-9]/[0-3]?[0-9]/(?:[0-9]{2})?[0-9]{2}$";
    NSString *simpleDate = @"05/03/2019";
    XCTAssertTrue([simpleDate isMatchedByRegex:simpleDateRegex]);
}

- (void)testRegexFromSection45
{
    NSString *monthDayDateRegex = @"^(?<month>[0-3]?[0-9])/(?<day>[0-3]?[0-9])/(?<year>(?:[0-9]{2})?[0-9]{2})$";
    NSString *dayMonthDateRegex = @"^(?<day>[0-3]?[0-9])/(?<month>[0-3]?[0-9])/(?<year>(?:[0-9]{2})?[0-9]{2})$";
    NSString *date01 = @"05/03/19";
    NSString *date02 = @"05/03/2019";
    NSString *invalidDate = @"02/31/2019";

    NSDate *(^testMatchLogic)(NSString *, NSString *) = ^NSDate *(NSString *testString, NSString *pattern) {
        NSString *yearString = [testString stringMatchedByRegex:pattern namedCapture:@"year"];
        NSInteger year = yearString.integerValue;

        if (year < 50) {
            year += 2000;
        }
        else if (year < 100) {
            year += 1900;
        }

        NSString *monthString = [testString stringMatchedByRegex:pattern namedCapture:@"month"];
        NSString *dayString = [testString stringMatchedByRegex:pattern namedCapture:@"day"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        NSString *dateString = [NSString stringWithFormat:@"%@/%@/%ld", monthString, dayString, year];
        NSDate *date = [formatter dateFromString:dateString];
        return date;
    };

    NSDate *outcome01 = testMatchLogic(date01, monthDayDateRegex);
    NSDate *outcome02 = testMatchLogic(date02, monthDayDateRegex);
    NSDate *noDate = testMatchLogic(invalidDate, monthDayDateRegex);
    XCTAssertTrue(outcome01);
    XCTAssertTrue(outcome02);
    XCTAssertNil(noDate);

    NSString *reverseDate01 = @"03/05/19";
    NSString *reverseDate02 = @"03/05/2019";
    NSString *reverseDate03 = @"31/02/19";
    NSString *reverseDate04 = @"31/02/2019";
    NSDate *reverseDateOutcome01 = testMatchLogic(reverseDate01, dayMonthDateRegex);
    NSDate *reverseDateOutcome02 = testMatchLogic(reverseDate02, dayMonthDateRegex);
    NSDate *reverseDateOutcome03 = testMatchLogic(reverseDate03, dayMonthDateRegex);
    NSDate *reverseDateOutcome04 = testMatchLogic(reverseDate04, dayMonthDateRegex);
    XCTAssertTrue(reverseDateOutcome01);
    XCTAssertTrue(reverseDateOutcome02);
    XCTAssertNil(reverseDateOutcome03);
    XCTAssertNil(reverseDateOutcome04);
}

- (void)testRegexFromSection46
{
    // Added seconds-precision to regex
    NSString *ampmRegex = @"^(1[0-2]|0?[1-9]):([0-5][0-9])(:([0-5][0-9]))?( ?[AP]M)?$";
    NSString *militaryTimeRegex = @"^(2[0-3]|[01]?[0-9]):([0-5][0-9])(:([0-5][0-9]))?$";
    NSString *ampmTime = @"7:44:34 AM";
    NSString *militaryTime = @"07:44:34";
    XCTAssertTrue([ampmTime isMatchedByRegex:ampmRegex]);
    XCTAssertTrue([militaryTime isMatchedByRegex:militaryTimeRegex]);
}

- (void)testRegexFromSection47
{
    // Uses strict dash and colon separators.
    NSString *iso8601Regex = @"^(?<year>[0-9]{4})-(?<month>1[0-2]|0[1-9])-(?<day>3[01]|0[1-9]|[12][0-9]) "
    "(?<hour>2[0-3]|[01][0-9]):(?<minute>[0-5][0-9]):(?<second>[0-5][0-9])$";
    NSString *dateString = @"2019-05-05 10:52:08";
    NSString *year = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"year"];
    NSString *month = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"month"];
    NSString *day = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"day"];
    NSString *hour = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"hour"];
    NSString *minute = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"minute"];
    NSString *second = [dateString stringMatchedByRegex:iso8601Regex namedCapture:@"second"];
    XCTAssertEqualObjects(year, @"2019");
    XCTAssertEqualObjects(month, @"05");
    XCTAssertEqualObjects(day, @"05");
    XCTAssertEqualObjects(hour, @"10");
    XCTAssertEqualObjects(minute, @"52");
    XCTAssertEqualObjects(second, @"08");
}

- (void)testRegexFromSection48
{
    // Latin Alphanumeric characters
    NSString *pattern = @"^[A-Z0-9]+$";
    NSString *willWork = @"ThisShouldWorkIn5Seconds";
    NSString *willFail = @"This Will Fail in 5 Seconds";
    XCTAssertTrue([willWork isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertFalse([willFail isMatchedByRegex:pattern options:RKXCaseless]);

    // Alphanumeric characters in any language
    NSString *anyLanguagePattern = @"^[\\p{L}\\p{M}\\p{Nd}]+$";
    NSString *upperCaseBravoInGreek = @"𝛣𝛲𝛢𝛶𝛰";
    NSString *lowerCaseBravoInGreek = @"𝛽𝜌𝛂𝜐𝜊";
    XCTAssertTrue([upperCaseBravoInGreek isMatchedByRegex:anyLanguagePattern options:RKXCaseless]);
    XCTAssertTrue([lowerCaseBravoInGreek isMatchedByRegex:anyLanguagePattern options:RKXCaseless]);
}

- (void)testRegexFromSection49
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection410
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection411
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection412
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection413
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection414
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection415
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection416
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection417
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection418
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection419
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection420
{
    XCTFail(@"Not Yet Implemented");
}

- (void)testRegexFromSection421
{
    XCTFail(@"Not Yet Implemented");
}

@end
