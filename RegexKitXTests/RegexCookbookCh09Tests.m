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
    NSString *ampersandRegex = @"&";
    NSString *ltRegex = @"<";
    NSString *gtRegex = @">";
    NSString *newlineRegex = @"\\r\\n?|\\n";
    NSString *brRegex = @"<br>\\s*<br>";

    NSString *(^convertTextToHTML)(NSString *) = ^NSString *(NSString *text) {
        NSString *newText = [text stringByReplacingOccurrencesOfRegex:ampersandRegex withTemplate:@"&amp;"];
        newText = [newText stringByReplacingOccurrencesOfRegex:ltRegex withTemplate:@"&lt;"];
        newText = [newText stringByReplacingOccurrencesOfRegex:gtRegex withTemplate:@"&gt;"];
        newText = [newText stringByReplacingOccurrencesOfRegex:newlineRegex withTemplate:@"<br>"];
        newText = [newText stringByReplacingOccurrencesOfRegex:brRegex withTemplate:@"</p><p>"];
        newText = [NSString stringWithFormat:@"<p>%@</p>", newText];
        return newText;
    };

    NSString *output1 = convertTextToHTML(@"Test.");
    NSString *output2 = convertTextToHTML(@"Test.\n");
    NSString *output3 = convertTextToHTML(@"Test.\n\n");
    NSString *output4 = convertTextToHTML(@"Test1.\nTest2.");
    NSString *output5 = convertTextToHTML(@"Test1.\n\nTest2.");
    NSString *output6 = convertTextToHTML(@"< AT&T >");

    XCTAssertTrue([output1 isEqualToString:@"<p>Test.</p>"]);
    XCTAssertTrue([output2 isEqualToString:@"<p>Test.<br></p>"]);
    XCTAssertTrue([output3 isEqualToString:@"<p>Test.</p><p></p>"]);
    XCTAssertTrue([output4 isEqualToString:@"<p>Test1.<br>Test2.</p>"]);
    XCTAssertTrue([output5 isEqualToString:@"<p>Test1.</p><p>Test2.</p>"]);
    XCTAssertTrue([output6 isEqualToString:@"<p>&lt; AT&amp;T &gt;</p>"]);
}

- (void)testRegexForDecodingXMLEntities96
{
    NSString *regex = @"&(?:#([0-9]+)|#x([0-9a-fA-F]+)|([0-9a-zA-Z]+));";
    NSString *sample = @"&lt; AT&amp;T &gt;";
    NSString *(^convertEntitiesToLiterals)(NSString *) = ^NSString *(NSString *text) {
        NSDictionary *names = @{
            @"quot" : @34,
            @"amp" : @38,
            @"apos" : @39,
            @"lt" : @60,
            @"gt" : @62
        };

        NSString *subbedText = [text stringByReplacingOccurrencesOfRegex:regex usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
            NSNumber *subCode = names[capturedStrings[3]];
            NSString *subText = [NSString stringWithFormat:@"%c", subCode.intValue];
            return subText;
        }];

        return subbedText;
    };

    NSString *convertedText = convertEntitiesToLiterals(sample);
    XCTAssertTrue([convertedText isEqualToString:@"< AT&T >"]);
}

- (void)testRegexForFindingSpecificAttributeInXMLStyleTags97
{
    NSString *regex = @"(?xi)"
                        "<"
                        "(?: [^>\"']                # Tag and attribute names, etc.\n"
                        "| \"[^\"]*\"               # and quoted attribute values\n"
                        "| '[^']*'"
                        ")+?"
                        "\\s id                     # The target attribute name, as a whole word\n"
                        "\\s* = \\s*                # Attribute name-value delimiter\n"
                        "( \"[^\"]*\" | '[^']*' )   # Capture the attribute value to backreference 1\n"
                        "(?: [^>\"']                # Any remaining characters\n"
                        "| \"[^\"]*\"               # and quoted attribute values\n"
                        "| '[^']*'"
                        ")*"
                        ">";
    NSString *sample = @"<meta id=\"og:site_name\" content=\"Optimize - Your potential. Actualized.\">";
    NSArray<NSString *> *captures = [sample captureSubstringsMatchedByRegex:regex];
    XCTAssertTrue([captures[1] isEqualToString:@"\"og:site_name\""]);
}

- (void)testRegexForAddingCellspacingAttribute98
{
    NSString *regex = @"(?xi)"
                       "<table \\b                         # Match \"<table\", as a complete word\n"
                       "(?!                                # Not followed by: Any attributes, etc., then \"cellspacing\"\n"
                       "(?:[^>\"']|\"[^\"]*\"|'[^']*')*?"
                       "\\s cellspacing \\b"
                       ")"
                       "(                                  # Capture attributes, etc. to backreference 1\n"
                       "(?:[^>\"']|\"[^\"]*\"|'[^']*')*"
                       ")"
                       ">";
    NSString *templateString = @"<table cellspacing=\"0\"$1>";
    NSString *tableString = @""
    "<table style=\"width:100%\">"
      "<tr>"
        "<th>Firstname</th>"
        "<th>Lastname</th>"
        "<th>Age</th>"
      "</tr>"
      "<tr>"
        "<td>Jill</td>"
        "<td>Smith</td>"
        "<td>50</td>"
      "</tr>"
      "<tr>"
        "<td>Eve</td>"
        "<td>Jackson</td>"
        "<td>94</td>"
      "</tr>"
    "</table>";

    NSString *substitutionString = [tableString stringByReplacingOccurrencesOfRegex:regex withTemplate:templateString];
    XCTAssertTrue([substitutionString isMatchedByRegex:@"cellspacing"]);
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
