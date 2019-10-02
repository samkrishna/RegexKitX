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
    // \p{L} => Unicode Letter category
    // \p{M} => Unicode Mark category
    // \p{Nd} => Decimal Number category
    NSString *anyLanguagePattern = @"^[\\p{L}\\p{M}\\p{Nd}]+$";
    NSString *upperCaseBravoInGreek = @"𝛣𝛲𝛢𝛶𝛰";
    NSString *lowerCaseBravoInGreek = @"𝛽𝜌𝛂𝜐𝜊";
    XCTAssertTrue([upperCaseBravoInGreek isMatchedByRegex:anyLanguagePattern]);
    XCTAssertTrue([lowerCaseBravoInGreek isMatchedByRegex:anyLanguagePattern]);
}

- (void)testRegexFromSection49
{
    NSString *testText1 = @"TRUE";
    NSString *testText2 = @"Oh So False!";
    NSString *pattern = @"^[A-Z]{1,10}$";
    XCTAssertTrue([testText1 isMatchedByRegex:pattern]);
    XCTAssertFalse([testText2 isMatchedByRegex:pattern]);
}

- (void)testRegexFromSection410
{
    NSString *lineCountPattern = @"\\A(?>[^\\r\\n]*(?>\\r\\n?|\\n)){0,4}[^\\r\\n]*\\z";
    NSString *lines = @"Hickory\n"
    "Dickory\n"
    "Dock\n"
    "The mouse came down.";
    XCTAssertTrue([lines isMatchedByRegex:lineCountPattern]);
    NSString *moreLines = [lines stringByAppendingString:@"\n"
                           "The house came down.\n"
                           "Hickory Dickory Dock."];
    XCTAssertFalse([moreLines isMatchedByRegex:lineCountPattern]);
}

- (void)testRegexFromSection411
{
    NSString *pattern = @"^(?:1|t(?:rue)?|y(?:es)?|ok(?:ay)?)$";
    XCTAssertTrue([@"t" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"true" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"1" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"y" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"yes" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"ok" isMatchedByRegex:pattern]);
    XCTAssertTrue([@"okay" isMatchedByRegex:pattern]);

    XCTAssertTrue([@"T" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"TRUE" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"1" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"Y" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"YES" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"OK" isMatchedByRegex:pattern options:RKXCaseless]);
    XCTAssertTrue([@"OKAY" isMatchedByRegex:pattern options:RKXCaseless]);

    XCTAssertFalse([@"f" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"false" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"7" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"n" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"no" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"not ok" isMatchedByRegex:pattern]);
    XCTAssertFalse([@"not okay" isMatchedByRegex:pattern]);
}

- (void)testRegexFromSection412
{
    NSString *ssnPattern = @"^(?!000|666)[0-8][0-9]{2}-?(?!00)[0-9]{2}-?(?!0000)[0-9]{4}$";
    NSString *ssn = @"565998218";
    XCTAssertTrue([ssn isMatchedByRegex:ssnPattern]);
}

- (void)testRegexFromSection413
{
    NSString *isbn10Regex = @"^(?:ISBN(?:-10)?:?●)?(?=[0-9X]{10}$|(?=(?:[0-9]+[-●]){3})[-●0-9X]{13}$)[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$";
    NSString *isbn13Regex = @"^(?:ISBN(?:-13)?:? )?(?=[0-9]{13}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)97[89][- ]?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9]$";
    NSString *isbn10Example = @"0205080057";
    NSString *isbn13Example = @"978-3-16-148410-0";
    XCTAssertTrue([isbn10Example isMatchedByRegex:isbn10Regex]);
    XCTAssertTrue([isbn13Example isMatchedByRegex:isbn13Regex]);
}

- (void)testRegexFromSection414
{
    NSString *zipRegex = @"^[0-9]{5}(?:-[0-9]{4})?$";
    XCTAssertTrue([@"12345" isMatchedByRegex:zipRegex]);
    XCTAssertTrue([@"12345-0000" isMatchedByRegex:zipRegex]);
}

- (void)testRegexFromSection415
{
    NSString *caPostalCodeRegex = @"(?!.*[DFIOQU])[A-VXY][0-9][A-Z] ?[0-9][A-Z][0-9]";
    NSString *caCode1 = @"T7Z 2W1";
    NSString *caCode2 = @"E5N 5J2";
    NSString *caCode3 = @"J5A 1H8";
    NSString *caCode4 = @"J9H 7J7";
    NSString *caCode5 = @"G1R 4E1";
    NSString *caCode6 = @"V2N 6C1";

    XCTAssertTrue([caCode1 isMatchedByRegex:caPostalCodeRegex]);
    XCTAssertTrue([caCode2 isMatchedByRegex:caPostalCodeRegex]);
    XCTAssertTrue([caCode3 isMatchedByRegex:caPostalCodeRegex]);
    XCTAssertTrue([caCode4 isMatchedByRegex:caPostalCodeRegex]);
    XCTAssertTrue([caCode5 isMatchedByRegex:caPostalCodeRegex]);
    XCTAssertTrue([caCode6 isMatchedByRegex:caPostalCodeRegex]);
}

- (void)testRegexFromSection416
{
    NSString *ukPostalCodeRegex = @"^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$";
    NSString *london = @"WC2N 5DU";
    NSString *birmingham = @"B4 7DA";
    NSString *liverpool = @"L2 2DP";
    XCTAssertTrue([london isMatchedByRegex:ukPostalCodeRegex]);
    XCTAssertTrue([birmingham isMatchedByRegex:ukPostalCodeRegex]);
    XCTAssertTrue([liverpool isMatchedByRegex:ukPostalCodeRegex]);
}

- (void)testRegexFromSection417
{
    NSString *poBoxRegex = @"^(?:Post(?:al)? (?:Office )?|P[. ]?O\\.? )?Box\\b";
    NSString *address1 = @"John Smith\n4303 Acme Ave.\nTexarkana, AR 71854";
    NSString *address2 = @"John Smith\nP.O. Box 1234\nTexarkana, AR 71854";
    NSString *address3 = @"John Smith\nPost Office Box 1234\nTexarkana, AR 71854";
    NSString *address4 = @"John Smith\nPostal Office Box 1234\nTexarkana, AR 71854";
    XCTAssertFalse([address1 isMatchedByRegex:poBoxRegex options:(RKXCaseless | RKXMultiline)]);
    XCTAssertTrue([address2 isMatchedByRegex:poBoxRegex options:(RKXCaseless | RKXMultiline)]);
    XCTAssertTrue([address3 isMatchedByRegex:poBoxRegex options:(RKXCaseless | RKXMultiline)]);
    XCTAssertTrue([address4 isMatchedByRegex:poBoxRegex options:(RKXCaseless | RKXMultiline)]);
}

- (void)testRegexFromSection418
{
    NSString *fullNameRegex = @"^(.+?) ([^\\s,]+)(,? (?:[JS]r\\.?|III?|IV))?$";
    NSArray *names = @[ @"Tom Jones",
                        @"Robert Downey, Jr.",
                        @"Jack Canfield",
                        @"John F. Kennedy",
                        @"Barak H. Obama, Sr.",
                        @"Catherine Zeta-Jones",
                        @"J.K. Rowling" ];

    NSArray *testChecks = @[ @"Jones, Tom",
                             @"Downey, Robert Jr.",
                             @"Canfield, Jack",
                             @"Kennedy, John F.",
                             @"Obama, Barack H., Sr.",
                             @"Zeta-Jones, Catherine",
                             @"Rowling, J.K." ];

    for (NSUInteger i = 0; i < names.count; i++) {
        NSString *fullName = names[i];
        NSString *reorderedName = [fullName stringByReplacingOccurrencesOfRegex:fullNameRegex withTemplate:@"$2, $1"];
        NSString *check = testChecks[i];
        XCTAssert([reorderedName isEqualToString:reorderedName], @"We have a reordering failure: attempt (%@) does not match check (%@)", reorderedName, check);
    }
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
