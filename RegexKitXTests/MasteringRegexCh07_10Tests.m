//
//  MasteringRegexCh07_10Tests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 2/11/26.
 Copyright © 2026 Sam Krishna. All rights reserved.

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

// Tests derived from "Mastering Regular Expressions, 3rd Edition" by Jeffrey E.F. Friedl
// Chapters 7-10: Language-specific chapters — ICU-compatible concepts extracted
// Chapter 7: Perl (pp.285-370)
// Chapter 8: Java (pp.371-434)
// Chapter 9: .NET (pp.435-482)
// Chapter 10: PHP (pp.483-528)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexCh07_10Tests : XCTestCase
@end

@implementation MasteringRegexCh07_10Tests

#pragma mark - Named Captures and Backreferences (Ch7 pp.306-308, Ch8 p.401, Ch9 pp.452-454)

- (void)testNamedCaptureGroupsBasic
{
    // MRE3 pp.306-308: Named captures (?<name>...) and \k<name> backreference
    NSString *dateRegex = @"(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2})";
    NSString *date = @"Today is 2024-12-25 and tomorrow is 2024-12-26";

    NSDictionary *firstDate = [date dictionaryWithNamedCaptureKeysMatchedByRegex:dateRegex];
    XCTAssertEqualObjects(firstDate[@"year"], @"2024");
    XCTAssertEqualObjects(firstDate[@"month"], @"12");
    XCTAssertEqualObjects(firstDate[@"day"], @"25");

    // Extract all dates
    NSArray<NSDictionary *> *allDates = [date arrayOfDictionariesMatchedByRegex:dateRegex
                                                           withKeysAndCaptures:@"year", 1, @"month", 2, @"day", 3, nil];
    XCTAssertEqual(allDates.count, 2);
    XCTAssertEqualObjects(allDates[0][@"year"], @"2024");
    XCTAssertEqualObjects(allDates[0][@"day"], @"25");
    XCTAssertEqualObjects(allDates[1][@"day"], @"26");
}

- (void)testNamedBackreferences
{
    // MRE3 p.307: \k<name> refers back to named capture
    // Match repeated words using named backreference
    NSString *regex = @"\\b(?<word>\\w+)\\s+\\k<word>\\b";
    NSString *text = @"the the quick brown fox fox";

    NSArray<NSString *> *repeated = [text substringsMatchedByRegex:regex];
    XCTAssertEqual(repeated.count, 2);
    XCTAssertEqualObjects(repeated[0], @"the the");
    XCTAssertEqualObjects(repeated[1], @"fox fox");

    // Extract the repeated word itself
    NSArray<NSString *> *words = [text substringsMatchedByRegex:regex capture:1];
    XCTAssertEqual(words.count, 2);
    XCTAssertEqualObjects(words[0], @"the");
    XCTAssertEqualObjects(words[1], @"fox");
}

#pragma mark - Complex Lookaround Patterns (Ch7 pp.312-316, Ch8 pp.404-407)

- (void)testLookaheadForOverlappingMatches
{
    // MRE3 pp.312-313: Using lookahead to find overlapping patterns
    // Find all positions where "aba" occurs, even overlapping ones
    NSString *text = @"abababa";

    // Normal matching: non-overlapping
    NSArray<NSString *> *normal = [text substringsMatchedByRegex:@"aba"];
    XCTAssertEqual(normal.count, 2); // positions 0 and 4

    // Lookahead trick: (?=(aba)) finds overlapping matches since lookahead is zero-width
    NSArray<NSString *> *overlapping = [text substringsMatchedByRegex:@"(?=(aba))" capture:1];
    XCTAssertEqual(overlapping.count, 3); // positions 0, 2, and 4
    XCTAssertEqualObjects(overlapping[0], @"aba");
    XCTAssertEqualObjects(overlapping[1], @"aba");
    XCTAssertEqualObjects(overlapping[2], @"aba");
}

- (void)testLookbehindPlusLookaheadForBoundary
{
    // MRE3 pp.313-314: Combining lookbehind and lookahead to match at a boundary
    // Insert a hyphen between a lowercase letter and an uppercase letter (camelCase splitting)
    NSString *camelCase = @"camelCaseVariableName";
    NSString *split = [camelCase stringByReplacingOccurrencesOfRegex:@"(?<=\\p{Ll})(?=\\p{Lu})" withTemplate:@"-"];
    XCTAssertEqualObjects(split, @"camel-Case-Variable-Name");
}

- (void)testNegativeLookbehindForExclusion
{
    // MRE3 pp.315-316: Negative lookbehind to exclude specific word endings
    // Match words that do NOT end in "ing"
    // Since lookbehind (?<!ing) tests at the \b position (end of word),
    // it rejects words whose last 3 characters are "ing"
    NSString *text = @"running jumping coding rest play thinking";
    NSArray<NSString *> *nonIng = [text substringsMatchedByRegex:@"\\b\\w+(?<!ing)\\b"];
    XCTAssertTrue([nonIng containsObject:@"rest"]);
    XCTAssertTrue([nonIng containsObject:@"play"]);
    XCTAssertFalse([nonIng containsObject:@"running"]);
    XCTAssertFalse([nonIng containsObject:@"jumping"]);
    XCTAssertFalse([nonIng containsObject:@"thinking"]);

    // Verify short words (less than 3 chars) are not excluded
    NSString *text2 = @"is am do run";
    NSArray<NSString *> *shortWords = [text2 substringsMatchedByRegex:@"\\b\\w+(?<!ing)\\b"];
    XCTAssertTrue([shortWords containsObject:@"is"]);
    XCTAssertTrue([shortWords containsObject:@"am"]);
    XCTAssertTrue([shortWords containsObject:@"do"]);
    XCTAssertTrue([shortWords containsObject:@"run"]);
}

#pragma mark - Multi-Step Regex Processing Pipelines (Ch7 pp.320-328)

- (void)testMultiStepTextTransformation
{
    // MRE3 pp.320-325: Chaining multiple regex operations for text transformation
    NSString *text = @"John Smith <john@example.com> and Jane Doe <jane@example.com>";

    // Step 1: Extract email addresses
    NSArray<NSString *> *emails = [text substringsMatchedByRegex:@"<([^>]+)>" capture:1];
    XCTAssertEqual(emails.count, 2);
    XCTAssertEqualObjects(emails[0], @"john@example.com");
    XCTAssertEqualObjects(emails[1], @"jane@example.com");

    // Step 2: Extract names (text before each <email>)
    NSArray<NSString *> *names = [text substringsMatchedByRegex:@"(\\w+ \\w+)\\s*<" capture:1];
    XCTAssertEqual(names.count, 2);
    XCTAssertEqualObjects(names[0], @"John Smith");
    XCTAssertEqualObjects(names[1], @"Jane Doe");

    // Step 3: Reformat as "last, first <email>"
    NSString *reformatted = [text stringByReplacingOccurrencesOfRegex:@"(\\w+) (\\w+) (<[^>]+>)"
                                                        withTemplate:@"$2, $1 $3"];
    XCTAssertTrue([reformatted isMatchedByRegex:@"Smith, John"]);
    XCTAssertTrue([reformatted isMatchedByRegex:@"Doe, Jane"]);
}

- (void)testRegexBasedCSVParsing
{
    // MRE3 pp.326-328: Using regex to parse CSV-like data
    // Simple comma-separated values (no quoted fields)
    NSString *csv = @"Alice,30,Engineer";
    NSArray<NSString *> *fields = [csv substringsSeparatedByRegex:@","];
    XCTAssertEqual(fields.count, 3);
    XCTAssertEqualObjects(fields[0], @"Alice");
    XCTAssertEqualObjects(fields[1], @"30");
    XCTAssertEqualObjects(fields[2], @"Engineer");

    // CSV with quoted fields containing commas
    NSString *quotedCSV = @"\"Smith, John\",42,\"New York, NY\"";
    // Match each field: either a quoted field or a non-comma sequence
    NSArray<NSString *> *quotedFields = [quotedCSV substringsMatchedByRegex:@"\"[^\"]*\"|[^,]+"];
    XCTAssertEqual(quotedFields.count, 3);
    XCTAssertEqualObjects(quotedFields[0], @"\"Smith, John\"");
    XCTAssertEqualObjects(quotedFields[1], @"42");
    XCTAssertEqualObjects(quotedFields[2], @"\"New York, NY\"");
}

#pragma mark - Unicode-Aware Matching (Ch8 pp.395-400)

- (void)testUnicodeAwareWordBoundary
{
    // MRE3 pp.395-396: Unicode word boundaries with \b
    // ICU \b is Unicode-aware by default with RKXUnicodeWordBoundaries
    NSString *text = @"caf\u00E9 na\u00EFve r\u00E9sum\u00E9";

    // Standard \b treats accented chars as word characters in ICU
    NSArray<NSString *> *words = [text substringsMatchedByRegex:@"\\b\\w+\\b"];
    XCTAssertEqual(words.count, 3);
    XCTAssertEqualObjects(words[0], @"caf\u00E9");
    XCTAssertEqualObjects(words[1], @"na\u00EFve");
    XCTAssertEqualObjects(words[2], @"r\u00E9sum\u00E9");
}

- (void)testUnicodePropertyMatchingForScripts
{
    // MRE3 pp.397-399: Matching across Unicode scripts
    NSString *mixed = @"Hello \u4F60\u597D \u041F\u0440\u0438\u0432\u0435\u0442 \u3053\u3093\u306B\u3061\u306F";

    // Match Latin words
    NSArray<NSString *> *latin = [mixed substringsMatchedByRegex:@"\\p{Latin}+"];
    XCTAssertEqual(latin.count, 1);
    XCTAssertEqualObjects(latin[0], @"Hello");

    // Match Chinese characters (Han script)
    NSArray<NSString *> *chinese = [mixed substringsMatchedByRegex:@"\\p{Han}+"];
    XCTAssertEqual(chinese.count, 1);
    XCTAssertEqualObjects(chinese[0], @"\u4F60\u597D");

    // Match Cyrillic
    NSArray<NSString *> *cyrillic = [mixed substringsMatchedByRegex:@"\\p{Cyrillic}+"];
    XCTAssertEqual(cyrillic.count, 1);
    XCTAssertEqualObjects(cyrillic[0], @"\u041F\u0440\u0438\u0432\u0435\u0442");

    // Match Hiragana
    NSArray<NSString *> *hiragana = [mixed substringsMatchedByRegex:@"\\p{Hiragana}+"];
    XCTAssertEqual(hiragana.count, 1);
    XCTAssertEqualObjects(hiragana[0], @"\u3053\u3093\u306B\u3061\u306F");
}

- (void)testUnicodeCaseFolding
{
    // MRE3 pp.399-400: Case-insensitive matching with Unicode
    // German sharp-s (ß) case-folds to "ss" in some engines
    NSString *german = @"Stra\u00DFe"; // Straße

    // Case-insensitive match against uppercase
    XCTAssertTrue([german isMatchedByRegex:@"(?i)stra\\u00DFe"]);
    XCTAssertTrue([german isMatchedByRegex:@"(?i)STRA\\u00DFE"]);

    // Turkish dotless i: case folding for i/I with dot above
    NSString *turkish = @"Istanbul";
    XCTAssertTrue([turkish isMatchedByRegex:@"(?i)istanbul"]);
    XCTAssertTrue([turkish isMatchedByRegex:@"(?i)ISTANBUL"]);
}

#pragma mark - Boundary Matchers (Ch8 pp.402-404)

- (void)testStringBoundaryAnchors
{
    // MRE3 pp.402-403: \A (start of string), \Z (end before final newline), \z (absolute end)
    NSString *text = @"first line\nsecond line\n";

    // \A matches only at the very start of the string
    XCTAssertEqualObjects([text stringMatchedByRegex:@"\\A\\w+"], @"first");

    // \z matches at the very end (after the trailing newline)
    XCTAssertTrue([text isMatchedByRegex:@"\\n\\z"]);

    // \Z matches before the final newline
    XCTAssertTrue([text isMatchedByRegex:@"line\\Z" options:RKXMultiline]);

    // Verify \A does not match at line boundaries even with multiline
    NSArray<NSString *> *aMatches = [text substringsMatchedByRegex:@"\\A\\w+" options:RKXMultiline];
    XCTAssertEqual(aMatches.count, 1); // only one match at string start
}

#pragma mark - Quantifier Type Comparison (Ch8 pp.407-410)

- (void)testQuantifierTriad
{
    // MRE3 pp.407-410: Three types of quantifiers — greedy, lazy, possessive
    NSString *text = @"aaaa";

    // Greedy a{2,4}: takes maximum (4)
    NSString *greedy = [text stringMatchedByRegex:@"^a{2,4}"];
    XCTAssertEqualObjects(greedy, @"aaaa");

    // Lazy a{2,4}?: takes minimum (2)
    NSString *lazy = [text stringMatchedByRegex:@"^a{2,4}?"];
    XCTAssertEqualObjects(lazy, @"aa");

    // Possessive a{2,4}+: takes maximum and locks (4)
    NSString *possessive = [text stringMatchedByRegex:@"^a{2,4}+"];
    XCTAssertEqualObjects(possessive, @"aaaa");

    // The difference shows with a trailing requirement:
    // greedy a{2,4}a on "aaaa": takes 4, gives back 1, match = "aaaa"
    XCTAssertTrue([text isMatchedByRegex:@"^a{2,4}a$"]);
    // possessive a{2,4}+a on "aaaa": takes 4, can't give back, fails
    XCTAssertFalse([text isMatchedByRegex:@"^a{2,4}+a$"]);
    // lazy a{2,4}?a on "aaaa": takes 2, then 'a' matches 3rd -> "aaa"
    NSString *lazyWithTrailing = [text stringMatchedByRegex:@"a{2,4}?a"];
    XCTAssertEqualObjects(lazyWithTrailing, @"aaa"); // lazy 2 + literal 1 = 3
}

#pragma mark - Region-Based Matching (Ch8 pp.411-413)

- (void)testSearchWithinRange
{
    // MRE3 pp.411-413: Limiting search to a region of the string
    // This maps to RegexKitX's range: parameter
    NSString *text = @"apple banana cherry date elderberry";

    // Search only within the middle portion
    NSRange middleRange = NSMakeRange(6, 20); // "banana cherry date"
    NSString *firstWord = [text stringMatchedByRegex:@"\\b\\w+\\b" range:middleRange];
    XCTAssertEqualObjects(firstWord, @"banana");

    // Search in a different range
    // "apple banana cherry date elderberry"
    //  0     6      13     20   25
    NSRange lastPart = NSMakeRange(20, text.length - 20); // "date elderberry"
    NSString *match = [text stringMatchedByRegex:@"\\b\\w+\\b" range:lastPart];
    XCTAssertEqualObjects(match, @"date");
}

#pragma mark - Regex-Based String Splitting (Ch9 pp.460-464)

- (void)testSplittingWithCapturedDelimiters
{
    // MRE3 pp.460-462: Splitting strings while preserving delimiters through captures
    NSString *text = @"one::two:::three";

    // Split on one or more colons
    NSArray<NSString *> *parts = [text substringsSeparatedByRegex:@":+"];
    XCTAssertEqual(parts.count, 3);
    XCTAssertEqualObjects(parts[0], @"one");
    XCTAssertEqualObjects(parts[1], @"two");
    XCTAssertEqualObjects(parts[2], @"three");
}

- (void)testSplittingHTMLIntoTagsAndText
{
    // MRE3 pp.462-464: Splitting HTML into tags and text segments
    NSString *html = @"<p>Hello <b>world</b></p>";

    // Split by tags, keeping tag text as matches
    NSArray<NSString *> *tags = [html substringsMatchedByRegex:@"<[^>]+>"];
    XCTAssertEqual(tags.count, 4);
    XCTAssertEqualObjects(tags[0], @"<p>");
    XCTAssertEqualObjects(tags[1], @"<b>");
    XCTAssertEqualObjects(tags[2], @"</b>");
    XCTAssertEqualObjects(tags[3], @"</p>");

    // Get the text portions by splitting on tags
    NSArray<NSString *> *textParts = [html substringsSeparatedByRegex:@"<[^>]+>"];
    // textParts: ["", "Hello ", "world", "", ""]
    // Non-empty parts contain the text
    NSMutableArray<NSString *> *nonEmpty = [NSMutableArray array];
    for (NSString *part in textParts) {
        if (part.length > 0) {
            [nonEmpty addObject:part];
        }
    }
    XCTAssertEqual(nonEmpty.count, 2);
    XCTAssertEqualObjects(nonEmpty[0], @"Hello ");
    XCTAssertEqualObjects(nonEmpty[1], @"world");
}

#pragma mark - Complex Replacement Patterns (Ch10 pp.500-505)

- (void)testReplacementWithBackreferences
{
    // MRE3 pp.500-502: Using backreferences in replacement templates
    // Swap first and last names
    NSString *text = @"John Smith, Jane Doe, Bob Johnson";
    NSString *swapped = [text stringByReplacingOccurrencesOfRegex:@"(\\w+) (\\w+)" withTemplate:@"$2 $1"];
    XCTAssertEqualObjects(swapped, @"Smith John, Doe Jane, Johnson Bob");

    // Wrap matched text: surround each word in brackets
    NSString *words = @"hello world";
    NSString *wrapped = [words stringByReplacingOccurrencesOfRegex:@"(\\w+)" withTemplate:@"[$1]"];
    XCTAssertEqualObjects(wrapped, @"[hello] [world]");
}

- (void)testReplacementWithNamedCaptures
{
    // MRE3 pp.502-503: Named capture references in replacements ($+{name} syntax varies by engine)
    // In ICU/NSRegularExpression, we use $1, $2, etc. for numbered captures
    // Named captures are accessed by their group number
    NSString *dateText = @"2024-12-25";
    // Reformat from YYYY-MM-DD to DD/MM/YYYY using numbered capture references
    NSString *reformatted = [dateText stringByReplacingOccurrencesOfRegex:@"(\\d{4})-(\\d{2})-(\\d{2})"
                                                            withTemplate:@"$3/$2/$1"];
    XCTAssertEqualObjects(reformatted, @"25/12/2024");
}

#pragma mark - Pattern Matching for Data Validation (Ch10 pp.505-510)

- (void)testEmailValidationPattern
{
    // MRE3 pp.505-507: Email validation with regex
    // Simplified but reasonably robust email pattern
    NSString *emailRegex = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

    XCTAssertTrue([@"user@example.com" isMatchedByRegex:emailRegex]);
    XCTAssertTrue([@"john.doe+tag@sub.domain.org" isMatchedByRegex:emailRegex]);
    XCTAssertTrue([@"user123@test.co.uk" isMatchedByRegex:emailRegex]);

    XCTAssertFalse([@"@example.com" isMatchedByRegex:emailRegex]);
    XCTAssertFalse([@"user@" isMatchedByRegex:emailRegex]);
    XCTAssertFalse([@"user@.com" isMatchedByRegex:emailRegex]);
    XCTAssertFalse([@"user@com" isMatchedByRegex:emailRegex]);
    XCTAssertFalse([@"user @example.com" isMatchedByRegex:emailRegex]);
}

- (void)testURLValidationPattern
{
    // MRE3 pp.508-510: URL matching pattern
    NSString *urlRegex = @"https?://[a-zA-Z0-9][-a-zA-Z0-9]*(?:\\.[a-zA-Z0-9][-a-zA-Z0-9]*)+(?::\\d+)?(?:/[^\\s]*)?";

    NSString *text = @"Visit https://www.example.com/path?q=1 or http://api.test.org:8080/v2/data here.";
    NSArray<NSString *> *urls = [text substringsMatchedByRegex:urlRegex];
    XCTAssertEqual(urls.count, 2);
    XCTAssertEqualObjects(urls[0], @"https://www.example.com/path?q=1");
    XCTAssertEqualObjects(urls[1], @"http://api.test.org:8080/v2/data");

    // Edge cases
    XCTAssertFalse([@"ftp://example.com" isMatchedByRegex:urlRegex]); // ftp not matched
    XCTAssertTrue([@"https://a.co" isMatchedByRegex:urlRegex]);       // short domain
}

#pragma mark - Block-Based Enumeration and Transformation (Derived from Ch7 pp.330-335)

- (void)testBlockBasedEnumeration
{
    // MRE3 pp.330-335: Iterating over matches with callbacks (Perl's while(m//g))
    // RegexKitX equivalent: enumerateStringsMatchedByRegex:usingBlock:
    NSString *logLine = @"[ERROR] 2024-01-15 Connection failed at 10.0.0.1:8080";

    NSMutableArray<NSDictionary *> *parts = [NSMutableArray array];
    NSString *partRegex = @"\\[(?<level>\\w+)\\]\\s+(?<date>\\d{4}-\\d{2}-\\d{2})\\s+(?<msg>.+)";

    [logLine enumerateStringsMatchedByRegex:partRegex usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        [parts addObject:@{
            @"level" : capturedStrings[1],
            @"date" : capturedStrings[2],
            @"message" : capturedStrings[3]
        }];
    }];

    XCTAssertEqual(parts.count, 1);
    XCTAssertEqualObjects(parts[0][@"level"], @"ERROR");
    XCTAssertEqualObjects(parts[0][@"date"], @"2024-01-15");
    XCTAssertEqualObjects(parts[0][@"message"], @"Connection failed at 10.0.0.1:8080");
}

- (void)testBlockBasedReplacement
{
    // MRE3 pp.333-335: Dynamic replacement using code (Perl's s///e)
    // RegexKitX equivalent: stringByReplacingOccurrencesOfRegex:usingBlock:
    NSString *text = @"I have 3 cats and 12 dogs and 1 fish";

    // Double all numbers using block-based replacement
    NSString *doubled = [text stringByReplacingOccurrencesOfRegex:@"\\d+" usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSInteger value = capturedStrings[0].integerValue;
        return [NSString stringWithFormat:@"%ld", (long)(value * 2)];
    }];
    XCTAssertEqualObjects(doubled, @"I have 6 cats and 24 dogs and 2 fish");
}

- (void)testBlockBasedConditionalReplacement
{
    // Extending MRE3 concept: Conditionally transform matches
    NSString *text = @"ERROR: disk full. WARNING: low memory. INFO: all ok.";

    // Uppercase the severity level
    NSString *result = [text stringByReplacingOccurrencesOfRegex:@"\\b(ERROR|WARNING|INFO)\\b" usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSString *level = capturedStrings[0];
        if ([level isEqualToString:@"ERROR"]) {
            return @"[!!!ERROR!!!]";
        } else if ([level isEqualToString:@"WARNING"]) {
            return @"[!WARNING!]";
        }
        return @"[info]";
    }];
    XCTAssertTrue([result isMatchedByRegex:@"\\[!!!ERROR!!!\\]"]);
    XCTAssertTrue([result isMatchedByRegex:@"\\[!WARNING!\\]"]);
    XCTAssertTrue([result isMatchedByRegex:@"\\[info\\]"]);
}

#pragma mark - Verbose/Extended Mode Patterns (Ch7 p.292, Ch8 p.400)

- (void)testVerboseModeComplexPattern
{
    // MRE3 pp.292, 400: (?x) mode / RKXIgnoreWhitespace for readable complex patterns
    // A well-commented pattern for matching a date
    NSString *dateRegex =
        @"(?<year>  \\d{4} )   # 4-digit year  \n"
        @"-                     # separator      \n"
        @"(?<month> \\d{2} )   # 2-digit month  \n"
        @"-                     # separator      \n"
        @"(?<day>   \\d{2} )   # 2-digit day    ";

    NSString *text = @"Date: 2024-06-15";
    NSDictionary *result = [text dictionaryWithNamedCaptureKeysMatchedByRegex:dateRegex options:RKXIgnoreWhitespace];
    XCTAssertEqualObjects(result[@"year"], @"2024");
    XCTAssertEqualObjects(result[@"month"], @"06");
    XCTAssertEqualObjects(result[@"day"], @"15");
}

#pragma mark - Regex Validation (Ch9 pp.445-447)

- (void)testRegexPatternValidation
{
    // MRE3 pp.445-447: Validating regex patterns before use
    // RegexKitX: isRegexValidWithOptions:error:
    NSError *error = nil;

    // Valid patterns
    XCTAssertTrue([@"\\d+" isRegexValidWithOptions:RKXNoOptions error:NULL]);
    XCTAssertTrue([@"(?<name>\\w+)" isRegexValidWithOptions:RKXNoOptions error:NULL]);
    XCTAssertTrue([@"[a-z&&[^aeiou]]" isRegexValidWithOptions:RKXNoOptions error:NULL]);

    // Invalid patterns
    XCTAssertFalse([@"[unclosed" isRegexValidWithOptions:RKXNoOptions error:&error]);
    XCTAssertNotNil(error);

    error = nil;
    XCTAssertFalse([@"(unmatched" isRegexValidWithOptions:RKXNoOptions error:&error]);
    XCTAssertNotNil(error);

    error = nil;
    XCTAssertFalse([@"*invalid" isRegexValidWithOptions:RKXNoOptions error:&error]);
    XCTAssertNotNil(error);

    error = nil;
    XCTAssertFalse([@"(?<=a+)b" isRegexValidWithOptions:RKXNoOptions error:&error]);
    XCTAssertNotNil(error); // variable-length lookbehind not supported in ICU
}

@end
