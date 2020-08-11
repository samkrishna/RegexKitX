//
//  RegexCookbookCh08Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh08Tests : XCTestCase

@end

@implementation RegexCookbookCh08Tests

- (void)testAllowsAlmostAnyURLRegex
{
    NSString *allowAlmostAnyURLRegex = @"^(https?|ftp|file):\\/\\/.+$";
    NSString *httpSample = @"http://example.com";
    NSString *ftpSample = @"http://example.com";
    NSString *fileSample = @"http://example.com";
    XCTAssertTrue([httpSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
    XCTAssertTrue([ftpSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
    XCTAssertTrue([fileSample isMatchedByRegex:allowAlmostAnyURLRegex options:RKXCaseless]);
}

- (void)testRegexForRequiringDomainNameWithoutUsernameOrPassword
{
    NSString *regex = @"^(https?|ftp)://[a-z0-9-]+(\\.[a-z0-9-]+)+([/?].+)?$";
    NSString *sample123 = @"https://www.apple.com/easyAs123.html";
    XCTAssertTrue([sample123 isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexForRequiringDomainNameWithAllowedOmittanceByInference
{
    NSString *regex = @"^((https?|ftp):\\/\\/|(www|ftp)\\.)([a-z0-9-]+\\.[a-z0-9-]+)+([\\/?].*)?$";
    NSString *sample = @"www.apple.com/easyAs123.html";
    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXCaseless]);

    NSArray<NSString *> *captures = [sample captureSubstringsMatchedByRegex:regex options:RKXCaseless];
    XCTAssertTrue([captures[4] isEqualToString:@"apple.com"]);
}

- (void)testRegexForMatchingURLWithImageFilePath
{
    NSString *regex = @"^(https?|ftp)://[a-z0-9-]+(\\.[a-z0-9-]+)+(/[\\w-]+)*/[\\w-]+\\.(gif|png|jpg)$";
    NSString *sample = @"https://www.apple.com/apple.png";
    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexForURLsWithoutSpaces
{
    NSString *regex = @"\\b(https?|ftp|file)://\\S+";
    NSString *sample = @"THis is a lorem ipsum https://www.apple.com/apple.png test of the regex";
    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testRegexFromSection86
{
    NSString *regexForURLWithoutSpaces = @"\\b(https?|ftp|file)://\\S+";
    NSString *sample = @"THis is a lorem ipsum https://www.apple.com/apple.png test of the regex";
    XCTAssertTrue([sample isMatchedByRegex:regexForURLWithoutSpaces options:RKXCaseless]);

    NSString *regexForURLsSansSpacesOrFinalPunctuation = @"\\b(https?|ftp|file)://[-A-Z0-9+&@#/%?=~"
                                                          "_|$!:,.;]*[A-Z0-9+&@#/%=~_|$]";
    XCTAssertTrue([sample isMatchedByRegex:regexForURLsSansSpacesOrFinalPunctuation options:RKXCaseless]);

    NSString *modifiedRegexSansSpacesOrPunctuation = @"\\b((https?|ftp|file)://|(www|ftp)\\.)[-A-Z0-9+&@#/%?"
                                                      "=~_|$!:,.;]*[A-Z0-9+&@#/%=~_|$]" ;
    NSString *sample2 = @"THis is a lorem ipsum www.apple.com/apple.png test of the regex";
    XCTAssertTrue([sample2 isMatchedByRegex:modifiedRegexSansSpacesOrPunctuation options:RKXCaseless]);

}

- (void)testRegexForFindingQuotedURLsInText
{
    NSString *regex = @"\\b(?:(?:https?|ftp|file)://|(www|ftp)\\.)[-A-Z0-9+&@#/%?=~_|$!:,.;]*[-A-Z0-9+&@#/%=~_|$]";
    NSString *sample1 = @"THis is a lorem ipsum \"https://www.apple.com/apple.png\" test of the regex";
    NSString *sample2 = @"THis is a lorem ipsum https://www.apple.com/apple.png test of the regex";
    RKXRegexOptions opts = (RKXCaseless | RKXMultiline | RKXDotAll);
    XCTAssertTrue([sample1 isMatchedByRegex:regex options:opts]);
    XCTAssertTrue([sample2 isMatchedByRegex:regex options:opts]);
}

- (void)testRegexForFindingURLsWithOptionalParentheses
{
    NSString *regex = @"\\b(?:(?:https?|ftp|file)://|www\\.|ftp\\.)"
                        "(?:\\([-A-Z0-9+&@#/%=~_|$?!:,.]*\\)|[-A-Z0-9+&@#/%=~_|$?!:,.])*"
                        "(?:\\([-A-Z0-9+&@#/%=~_|$?!:,.]*\\)|[A-Z0-9+&@#/%=~_|$])";
    NSString *sample1 = @"THis is a lorem ipsum https://www.apple.com/apple.png test of the regex";
    NSString *sample2 = @"A paren URL: http://en.wikipedia.org/wiki/PC_Tools_(Central_Point_Software)";
    NSString *sample3 = @"Another paren URL: http://msdn.microsoft.com/en-us/library/aa752574(VS.85).aspx";
    NSString *sample4 = @"RegexBuddy\'s website (at http://www.regexbuddy.com) is really cool.";
    RKXRegexOptions opts = (RKXCaseless | RKXMultiline | RKXDotAll);
    XCTAssertTrue([sample1 isMatchedByRegex:regex options:opts]);
    XCTAssertTrue([sample2 isMatchedByRegex:regex options:opts]);
    XCTAssertTrue([sample3 isMatchedByRegex:regex options:opts]);
    XCTAssertTrue([sample4 isMatchedByRegex:regex options:opts]);
}

- (void)testRegexForTurningURLsIntoLinks
{
    NSString *regex = @"\\b(?:(?:https?|ftp|file)://|www\\.|ftp\\.)"
                        "(?:\\([-A-Z0-9+&@#/%=~_|$?!:,.]*\\)|[-A-Z0-9+&@#/%=~_|$?!:,.])*"
                        "(?:\\([-A-Z0-9+&@#/%=~_|$?!:,.]*\\)|[A-Z0-9+&@#/%=~_|$])";
    NSString *sample2 = @"A paren URL: http://en.wikipedia.org/wiki/PC_Tools_(Central_Point_Software)";
    RKXRegexOptions opts = (RKXCaseless | RKXMultiline | RKXDotAll);
    NSString *output = [sample2 stringByReplacingOccurrencesOfRegex:regex withTemplate:@"<a href=\"$0\">$0</a>" options:opts];
    XCTAssertTrue([output isMatchedByRegex:@"href"]);
}

- (void)testRegexFromSection810
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection811
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection812
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection813
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection814
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection815
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection816
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection817
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection818
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection819
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection820
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection821
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection822
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection823
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection824
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection825
{
    XCTFail(@"Not filled out yet");
}

@end
