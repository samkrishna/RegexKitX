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

- (void)testRegexForURLsWithoutSpacesOrPunctuation
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

- (void)testRegexForValidatingURNs
{
    NSString *regex = @"^urn:[a-z0-9][a-z0-9-]{0,31}:[a-z0-9()+,\\-.:=@;$_!*'%/?#]+$";
    NSString *sample = @"urn:oasis:names:tc:ubl:schema:xsd:Invoice-1.0";
    XCTAssertTrue([sample isMatchedByRegex:regex options:RKXCaseless]);
}

- (void)testCanonicalAllowWhitespaceAndCommentBug
{
    NSString *regexWithHastagComments = @"(?xi)" // This allows for white space, #comments and case-insensitive matching within the pattern
    "\\A"
    "(                                              # Scheme"
    "[a-z][a-z0-9+\\-.]*:"
    "(                                              # Authority & path"
    "\\/\\/"
    "([a-z0-9\\-._~%!$&'()*+,;=]+@)?                # User"
    "([a-z0-9\\-._~%]+                              # Named host"
    "|\\[[a-f0-9:.]+\\]                             # IPv6 host"
    "|\\[v[a-f0-9][a-z0-9\\-._~%!$&'()*+,;=:]+\\])  # IPvFuture host"
    "(:[0-9]+)?                                     # Port"
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?        # Path"
    "|                                              # Path without authority"
    "(\\/?[a-z0-9\\-._~%!$&'()*+,;=:@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?)?"
    ")"
    "|                                              # Relative URL (no scheme or authority)"
    "(                                              # Relative path"
    "[a-z0-9\\-._~%!$&'()*+,;=@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?"
    "|                                              # Absolute path"
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)+\\/?"
    ")"
    ")"
    "                                               # Query"
    "(\\?[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "                                               # Fragment"
    "(\\#[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "\\Z";
    XCTAssertTrue([regexWithHastagComments isRegexValid], @"This doesn't work because \"Allows Comments and White Space\" option doesn't work with NSRegularExpresion");

    NSString *regexWithHashtagCommentsV2 = [regexWithHastagComments substringFromIndex:5];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexWithHashtagCommentsV2 options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace) error:NULL];
    XCTAssertNotNil(regex);
}

- (void)testRegexForValidatingGenericURLsWithoutHashtagComments
{
    NSString *regexWithoutHashtagComments = @"(?xi)" // This allows for white space, #comments and case-insensitive matching within the pattern
    // Convert the hashtags into regular comments
    "\\A"
    "("                                                             // Scheme
    "[a-z][a-z0-9+\\-.]*:"
    "("                                                             // Authority and path
    "\\/\\/"
    "([a-z0-9\\-._~%!$&'()*+,;=]+@)?"                               // User
    "([a-z0-9\\-._~%]+"                                             // Named host
    "|\\[[a-f0-9:.]+\\]"                                            // IPv6 host
    "|\\[v[a-f0-9][a-z0-9\\-._~%!$&'()*+,;=:]+\\])"                 // IPvFuture host
    "(:[0-9]+)?"                                                    // Port
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?"                       // Path
    "|"                                                             // Path without authority
    "(\\/?[a-z0-9\\-._~%!$&'()*+,;=:@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?)?"
    ")"
    "|"                                                             // Relative URL (no scheme or authority)
    "("                                                             // Relative path
    "[a-z0-9\\-._~%!$&'()*+,;=@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?"
    "|"                                                             // Absolute path
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)+\\/?"
    ")"
    ")"
    "" // Query
    "(\\?[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "" // Fragment
    "(\\#[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "\\Z";
    XCTAssertTrue([regexWithoutHashtagComments isRegexValid]);

    NSString *sample = @"https://www.apple.com:1024/OldSkoolWOQuery?query=iPod+iPhone+MacBook%20Pro";
    NSArray *matches = [sample arrayOfCaptureSubstringsMatchedByRegex:regexWithoutHashtagComments];
    NSArray<NSString *> *captures = matches[0];
    XCTAssertTrue(captures.count == 14);
    XCTAssertTrue([captures[5] isEqualToString:@":1024"]);
    XCTAssertTrue([captures[6] isEqualToString:@"/OldSkoolWOQuery"]);
    XCTAssertTrue([captures[12] isEqualToString:@"?query=iPod+iPhone+MacBook%20Pro"]);
}

- (void)testRegexForSchemeExtractionAndURLValidation
{
    NSString *regex = @"(?xi)" // This allows for white space, #comments and case-insensitive matching within the pattern
    // Convert the hashtags into regular comments
    "\\A"
    "("                                                             // Scheme
    "([a-z][a-z0-9+\\-.]*):"
    "("                                                             // Authority and path
    "\\/\\/"
    "([a-z0-9\\-._~%!$&'()*+,;=]+@)?"                               // User
    "([a-z0-9\\-._~%]+"                                             // Named host
    "|\\[[a-f0-9:.]+\\]"                                            // IPv6 host
    "|\\[v[a-f0-9][a-z0-9\\-._~%!$&'()*+,;=:]+\\])"                 // IPvFuture host
    "(:[0-9]+)?"                                                    // Port
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?"                       // Path
    "|"                                                             // Path without authority
    "(\\/?[a-z0-9\\-._~%!$&'()*+,;=:@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?)?"
    ")"
    "|"                                                             // Relative URL (no scheme or authority)
    "("                                                             // Relative path
    "[a-z0-9\\-._~%!$&'()*+,;=@]+(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)*\\/?"
    "|"                                                             // Absolute path
    "(\\/[a-z0-9\\-._~%!$&'()*+,;=:@]+)+\\/?"
    ")"
    ")"
    "" // Query
    "(\\?[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "" // Fragment
    "(\\#[a-z0-9\\-._~%!$&'()*+,;=:@\\/?]*)?"
    "\\Z";

    NSString *sample = @"https://www.apple.com:1024/OldSkoolWOQuery?query=iPod+iPhone+MacBook%20Pro";
    NSString *scheme = [sample stringMatchedByRegex:regex capture:2];
    XCTAssert([scheme isEqualToString:@"https"], @"No Match: scheme = %@", scheme);
}

- (void)testRegexForExtractingTheUserFromURL
{
    NSString *regex = @"^[a-z0-9+\\-.]+://([a-z0-9\\-._~%!$&'()*+,;=]+)@";
    NSString *sample = @"ftp://jan@www.regexcookbook.com";
    NSString *userString = [sample stringMatchedByRegex:regex capture:1 namedCapture:nil options:RKXCaseless];
    XCTAssertTrue([userString isEqualToString:@"jan"]);
}

- (void)testRegexForExtractingTheHostFromURL
{
    NSString *regex = @"^[a-z][a-z0-9+\\-.]*://([a-z0-9\\-._~%!$&'()*+,;=]+@)?"
                        "([a-z0-9\\-._~%]+|\\[[a-z0-9\\-._~%!$&'()*+,;=:]+\\])";
    NSString *sample = @"http://www.regexcookbook.com/";
    NSString *host = @"www.regexcookbook.com";
    NSString *hostCapture = [sample stringMatchedByRegex:regex capture:2 namedCapture:nil options:RKXCaseless];
    XCTAssertTrue([hostCapture isEqualToString:host], @"hostCapture: %@ and host: %@", hostCapture, host);
}

- (void)testRegexForExtractingThePortFromURL
{
    NSString *regex = @"^[a-z][a-z0-9+\\-.]*://([a-z0-9\\-._~%!$&'()*+,;=]+@)?"
    "([a-z0-9\\-._~%]+|\\[[a-z0-9\\-._~%!$&'()*+,;=:]+\\]):([0-9]+)";
    NSString *sample = @"http://www.regexcookbook.com:80/";
    NSString *portCapture = [sample stringMatchedByRegex:regex capture:3 namedCapture:nil options:RKXCaseless];
    XCTAssertTrue([portCapture isEqualToString:@"80"]);
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
