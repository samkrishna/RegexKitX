//
//  RegexCookbookCh09Tests.m
//  RegexKitXTests
//
//  Created by Sam Krishna on 10/14/19.
//  Copyright © 2019 Sam Krishna. All rights reserved.
//

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RegexCookbookCh09Tests : XCTestCase

@end

@implementation RegexCookbookCh09Tests

- (void)testQuickRegexForAttributeMatchingFrom91
{
    NSString *quickRegex = @"<[^>]*>";
    NSString *sample = @"<title>Boring</title>";
    NSString *attribute = [sample stringMatchedByRegex:quickRegex];
    XCTAssertTrue([attribute isEqualToString:@"<title>"]);

    NSString *betterRegex = @"(?x)"
                             "<"
                             "(?: [^>\"']       # Non-quoted character\n"
                             "| \"[^\"]*\"      # Double-quoted attribute value\n"
                             "| '[^']*'         # Single-quoted attribute value\n"
                             ")*"
                             ">";
    NSString *betterSample = @"<title<<whoa>>>Coolness</title>";
    NSString *betterAttribute = [betterSample stringMatchedByRegex:betterRegex];
    XCTAssertTrue([betterAttribute isEqualToString:@"<title<<whoa>"]);
}

- (void)testRegexToReplaceBTagsWithStrongTagsFrom92
{
    NSString *regex = @"(?xi)"
                        "<"
                        "(/?)           # Capture the optional leading slash to backreference 1\n"
                        "b \\b          # Tag name, with word boundary\n"
                        "(              # Capture any attributes, etc. to backreference 2\n"
                        "(?: [^>\"']    # Any character except >, \", or '\n"
                        "| \"[^\"]*\"   # Double-quoted attribute value\n"
                        "| '[^']*'      # Single-quoted attribute value\n"
                        ")*\n"
                        ")\n"
                        ">";
    NSString *sample = @"<b>this is some bolding text</b>";
    NSString *sub = [sample stringByReplacingOccurrencesOfRegex:regex withTemplate:@"<$1strong$2>"];
    XCTAssertTrue([sub isEqualToString:@"<strong>this is some bolding text</strong>"], @"sub = %@", sub);
}

- (void)testRegexForRemovingAllXMLStyleTagsExceptEmAndStrongFrom93
{
    NSString *regex = @"(?xi)"
                        "< /?               # Permit closing tags\n"
                        "(?!"
                        "(?: em | strong )  # List of tags to avoid matching\n"
                        "\\b                # Word boundary avoids partial word matches\n"
                        ")"
                        "[a-z]              # Tag name initial character must be a-z\n"
                        "(?: [^>\"']        # Any character except >, \", or '\n"
                        "| \"[^\"]*\"       # Double-quoted attribute value\n"
                        "| '[^']*'          # Single-quoted attribute value\n"
                        ")*"
                        ">";
    NSString *sample = @"<em>this is some <b>bolding</b> text</em>";
    NSArray<NSString *> *matches = [sample substringsMatchedByRegex:regex];
    XCTAssertTrue(matches.count == 2);
    XCTAssertTrue([matches[0] isEqualToString:@"<b>"]);
    XCTAssertTrue([matches[1] isEqualToString:@"</b>"]);
}

- (void)testRegexForMatchingXMLNamesFrom94
{
    NSString *xml11ExactRegex = @"^[:_A-Za-z\\x{C0}-\\x{D6}\\x{D8}-\\x{F6}\\x{F8}-\\x{2FF}\\x{370}-\\x{37D}"
                                "\\x{37F}-\\x{1FFF}\\x{200C}\\x{200D}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}"
                                "\\x{3001}-\\x{D7FF}\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}]"
                                "[:_\\-.A-Za-z0-9\\x{B7}\\x{C0}-\\x{D6}\\x{D8}-\\x{F6}\\x{F8}-\\x{36F}"
                                "\\x{370}-\\x{37D}\\x{37F}-\\x{1FFF}\\x{200C}\\x{200D}"
                                "\\x{203F}\\x{2040}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}\\x{3001}-\\x{D7FF}"
                                "\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}]*$";

    NSString *sample1 = @"thing";
    NSString *sample2 = @"_thing_2_";
    NSString *sample3 = @":Российские-Вещь";
    NSString *sample4 = @"fantastic4:the.thing";
    NSString *sample5 = @"日本の物";
    XCTAssertTrue([sample1 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertTrue([sample2 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertTrue([sample3 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertTrue([sample4 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertTrue([sample5 isMatchedByRegex:xml11ExactRegex]);

    NSString *badSample1 = @"thing!";
    NSString *badSample2 = @"thing with spaces";
    NSString *badSample3 = @".thing.with.a.dot.in.front";
    NSString *badSample4 = @"-thingamajig";
    NSString *badSample5 = @"2nd_thing";
    XCTAssertFalse([badSample1 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertFalse([badSample2 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertFalse([badSample3 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertFalse([badSample4 isMatchedByRegex:xml11ExactRegex]);
    XCTAssertFalse([badSample5 isMatchedByRegex:xml11ExactRegex]);
}

- (void)testRegexFromSection95
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection96
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection97
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection98
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection99
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection910
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection911
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection912
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection913
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection914
{
    XCTFail(@"Not filled out yet");
}

- (void)testRegexFromSection915
{
    XCTFail(@"Not filled out yet");
}

@end
