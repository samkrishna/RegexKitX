//
//  RealWorldRegexTests.m
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

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface RealWorldRegexTests : XCTestCase
@end

@implementation RealWorldRegexTests

#pragma mark - Semantic Versioning

- (void)testSemanticVersioning
{
    // SemVer 2.0: MAJOR.MINOR.PATCH with optional pre-release and build metadata
    NSString *semverPattern = @"^(?<major>0|[1-9]\\d*)\\.(?<minor>0|[1-9]\\d*)\\.(?<patch>0|[1-9]\\d*)(?:-(?<prerelease>[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+(?<build>[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$";

    // Test with captureSubstringsMatchedByRegex:
    NSString *version1 = @"1.2.3-alpha.1+build.456";
    NSArray *captures = [version1 captureSubstringsMatchedByRegex:semverPattern];
    XCTAssertEqualObjects(captures[0], version1);
    XCTAssertEqualObjects(captures[1], @"1");
    XCTAssertEqualObjects(captures[2], @"2");
    XCTAssertEqualObjects(captures[3], @"3");
    XCTAssertEqualObjects(captures[4], @"alpha.1");
    XCTAssertEqualObjects(captures[5], @"build.456");

    // Test with dictionaryWithNamedCaptureKeysMatchedByRegex:
    NSDictionary *dict = [version1 dictionaryWithNamedCaptureKeysMatchedByRegex:semverPattern];
    XCTAssertEqualObjects(dict[@"major"], @"1");
    XCTAssertEqualObjects(dict[@"minor"], @"2");
    XCTAssertEqualObjects(dict[@"patch"], @"3");
    XCTAssertEqualObjects(dict[@"prerelease"], @"alpha.1");
    XCTAssertEqualObjects(dict[@"build"], @"build.456");

    // Simple version without pre-release/build
    NSString *version2 = @"10.0.99";
    NSDictionary *dict2 = [version2 dictionaryWithNamedCaptureKeysMatchedByRegex:semverPattern];
    XCTAssertEqualObjects(dict2[@"major"], @"10");
    XCTAssertEqualObjects(dict2[@"minor"], @"0");
    XCTAssertEqualObjects(dict2[@"patch"], @"99");

    // Invalid: leading zeros
    XCTAssertFalse([@"01.2.3" isMatchedByRegex:semverPattern]);
    XCTAssertFalse([@"1.02.3" isMatchedByRegex:semverPattern]);
}

#pragma mark - UUID Validation

- (void)testUUIDValidation
{
    NSString *uuidPattern = @"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";

    // Valid UUIDs
    XCTAssertTrue([@"550e8400-e29b-41d4-a716-446655440000" isMatchedByRegex:uuidPattern]);
    XCTAssertTrue([@"6BA7B810-9DAD-11D1-80B4-00C04FD430C8" isMatchedByRegex:uuidPattern]);

    // Extract all UUIDs from text
    NSString *text = @"User 550e8400-e29b-41d4-a716-446655440000 created session f47ac10b-58cc-4372-a567-0e02b2c3d479 at 10:30";
    NSArray *uuids = [text substringsMatchedByRegex:uuidPattern];
    XCTAssertEqual(uuids.count, 2UL);
    XCTAssertEqualObjects(uuids[0], @"550e8400-e29b-41d4-a716-446655440000");
    XCTAssertEqualObjects(uuids[1], @"f47ac10b-58cc-4372-a567-0e02b2c3d479");

    // Invalid UUIDs
    XCTAssertFalse([@"550e8400-e29b-41d4-a716-44665544000" isMatchedByRegex:uuidPattern]); // too short
    XCTAssertFalse([@"550e8400-e29b-41d4-a716" isMatchedByRegex:uuidPattern]); // incomplete
    XCTAssertFalse([@"ZZZZZZZZ-e29b-41d4-a716-446655440000" isMatchedByRegex:uuidPattern]); // non-hex chars
}

#pragma mark - Hex Color Codes

- (void)testHexColorCodeExtraction
{
    NSString *hexColorPattern = @"#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\\b";

    NSString *css = @"body { color: #333; background: #FF5733; border: #abc; outline: #00CC99; }";
    NSArray<NSDictionary *> *results = [css arrayOfDictionariesMatchedByRegex:hexColorPattern withKeysAndCaptures:@"fullMatch", 0, @"hexValue", 1, nil];

    XCTAssertEqual(results.count, 4UL);
    XCTAssertEqualObjects(results[0][@"fullMatch"], @"#333");
    XCTAssertEqualObjects(results[0][@"hexValue"], @"333");
    XCTAssertEqualObjects(results[1][@"fullMatch"], @"#FF5733");
    XCTAssertEqualObjects(results[1][@"hexValue"], @"FF5733");
    XCTAssertEqualObjects(results[2][@"fullMatch"], @"#abc");
    XCTAssertEqualObjects(results[2][@"hexValue"], @"abc");
    XCTAssertEqualObjects(results[3][@"fullMatch"], @"#00CC99");
    XCTAssertEqualObjects(results[3][@"hexValue"], @"00CC99");

    // Should not match invalid hex colors
    XCTAssertFalse([@"#GGG" isMatchedByRegex:hexColorPattern]);
    XCTAssertFalse([@"#12345" isMatchedByRegex:hexColorPattern]); // 5 digits
}

#pragma mark - MAC Address Formats

- (void)testMACAddressFormats
{
    // Colon-separated (common Unix format)
    NSString *macColonPattern = @"(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}";
    XCTAssertTrue([@"01:23:45:67:89:AB" isMatchedByRegex:macColonPattern]);

    // Dash-separated (common Windows format)
    NSString *macDashPattern = @"(?:[0-9a-fA-F]{2}-){5}[0-9a-fA-F]{2}";
    XCTAssertTrue([@"01-23-45-67-89-AB" isMatchedByRegex:macDashPattern]);

    // Normalize MAC addresses: replace dashes with colons using template replacement
    NSString *dashMAC = @"Device at 01-23-45-67-89-AB connected via 00-1A-2B-3C-4D-5E";
    NSString *normalized = [dashMAC stringByReplacingOccurrencesOfRegex:@"([0-9a-fA-F]{2})-([0-9a-fA-F]{2})-([0-9a-fA-F]{2})-([0-9a-fA-F]{2})-([0-9a-fA-F]{2})-([0-9a-fA-F]{2})" withTemplate:@"$1:$2:$3:$4:$5:$6"];
    XCTAssertEqualObjects(normalized, @"Device at 01:23:45:67:89:AB connected via 00:1A:2B:3C:4D:5E");
}

#pragma mark - Base64 Validation

- (void)testBase64StringValidation
{
    NSString *base64Pattern = @"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$";

    // Valid base64 strings
    XCTAssertTrue([@"SGVsbG8gV29ybGQ=" isMatchedByRegex:base64Pattern]);   // "Hello World"
    XCTAssertTrue([@"dGVzdA==" isMatchedByRegex:base64Pattern]);            // "test"
    XCTAssertTrue([@"YWJjZGVm" isMatchedByRegex:base64Pattern]);           // "abcdef" (no padding)
    XCTAssertTrue([@"" isMatchedByRegex:base64Pattern]);                    // empty is valid

    // Invalid base64 strings
    XCTAssertFalse([@"SGVsbG8gV29ybGQ" isMatchedByRegex:base64Pattern]);   // wrong padding
    XCTAssertFalse([@"invalid!@#" isMatchedByRegex:base64Pattern]);         // illegal characters
    XCTAssertFalse([@"abc" isMatchedByRegex:base64Pattern]);                // wrong length
}

#pragma mark - JWT Token Structure

- (void)testJWTTokenStructure
{
    // JWT: three base64url-encoded segments separated by dots
    NSString *jwtPattern = @"^([A-Za-z0-9_-]+)\\.([A-Za-z0-9_-]+)\\.([A-Za-z0-9_-]+)$";

    NSString *jwt = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

    NSArray *parts = [jwt captureSubstringsMatchedByRegex:jwtPattern];
    XCTAssertEqual(parts.count, 4UL); // full match + 3 captures
    XCTAssertEqualObjects(parts[1], @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9");
    XCTAssertEqualObjects(parts[2], @"eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ");
    XCTAssertEqualObjects(parts[3], @"SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c");

    // Invalid JWTs
    XCTAssertFalse([@"only.two" isMatchedByRegex:jwtPattern]);
    XCTAssertFalse([@"has spaces.in.token" isMatchedByRegex:jwtPattern]);
    XCTAssertFalse([@"too.many.parts.here" isMatchedByRegex:jwtPattern]);
}

#pragma mark - Markdown Bold and Italic

- (void)testMarkdownBoldAndItalic
{
    NSString *boldPattern = @"\\*\\*(.+?)\\*\\*";
    NSString *italicPattern = @"(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)";

    // Extract bold text
    NSString *markdown = @"This is **bold** and **strong text** here";
    NSArray *boldMatches = [markdown substringsMatchedByRegex:boldPattern capture:1];
    XCTAssertEqual(boldMatches.count, 2UL);
    XCTAssertEqualObjects(boldMatches[0], @"bold");
    XCTAssertEqualObjects(boldMatches[1], @"strong text");

    // Extract italic text
    NSString *markdown2 = @"This is *italic* and *emphasized* text";
    NSArray *italicMatches = [markdown2 substringsMatchedByRegex:italicPattern capture:1];
    XCTAssertEqual(italicMatches.count, 2UL);
    XCTAssertEqualObjects(italicMatches[0], @"italic");
    XCTAssertEqualObjects(italicMatches[1], @"emphasized");
}

#pragma mark - Markdown Link Extraction

- (void)testMarkdownLinkExtraction
{
    NSString *linkPattern = @"!?\\[([^\\]]+)\\]\\(([^)]+)\\)";

    NSString *markdown = @"Visit [Google](https://google.com) and see ![logo](img/logo.png) then [Docs](https://docs.example.com)";
    NSArray<NSArray *> *allCaptures = [markdown arrayOfCaptureSubstringsMatchedByRegex:linkPattern];

    XCTAssertEqual(allCaptures.count, 3UL);

    // First: regular link
    XCTAssertEqualObjects(allCaptures[0][0], @"[Google](https://google.com)");
    XCTAssertEqualObjects(allCaptures[0][1], @"Google");
    XCTAssertEqualObjects(allCaptures[0][2], @"https://google.com");

    // Second: image link
    XCTAssertEqualObjects(allCaptures[1][0], @"![logo](img/logo.png)");
    XCTAssertEqualObjects(allCaptures[1][1], @"logo");
    XCTAssertEqualObjects(allCaptures[1][2], @"img/logo.png");

    // Third: regular link
    XCTAssertEqualObjects(allCaptures[2][1], @"Docs");
    XCTAssertEqualObjects(allCaptures[2][2], @"https://docs.example.com");
}

#pragma mark - ISO 8601 Timestamps

- (void)testISO8601TimestampWithTimezone
{
    NSString *iso8601Pattern = @"(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2})T(?<hour>\\d{2}):(?<minute>\\d{2}):(?<second>\\d{2})(?:\\.(?<fraction>\\d+))?(?<tz>Z|[+-]\\d{2}:\\d{2})";

    // UTC timestamp with fractional seconds
    NSString *ts1 = @"2024-01-15T09:30:00.123Z";
    NSDictionary *dict1 = [ts1 dictionaryWithNamedCaptureKeysMatchedByRegex:iso8601Pattern];
    XCTAssertEqualObjects(dict1[@"year"], @"2024");
    XCTAssertEqualObjects(dict1[@"month"], @"01");
    XCTAssertEqualObjects(dict1[@"day"], @"15");
    XCTAssertEqualObjects(dict1[@"hour"], @"09");
    XCTAssertEqualObjects(dict1[@"minute"], @"30");
    XCTAssertEqualObjects(dict1[@"second"], @"00");
    XCTAssertEqualObjects(dict1[@"fraction"], @"123");
    XCTAssertEqualObjects(dict1[@"tz"], @"Z");

    // Timestamp with timezone offset, no fractional seconds
    NSString *ts2 = @"2024-06-30T14:45:59+05:30";
    NSDictionary *dict2 = [ts2 dictionaryWithNamedCaptureKeysMatchedByRegex:iso8601Pattern];
    XCTAssertEqualObjects(dict2[@"year"], @"2024");
    XCTAssertEqualObjects(dict2[@"hour"], @"14");
    XCTAssertEqualObjects(dict2[@"second"], @"59");
    XCTAssertEqualObjects(dict2[@"tz"], @"+05:30");

    // Negative offset
    NSString *ts3 = @"2025-12-31T23:59:59.999-08:00";
    NSDictionary *dict3 = [ts3 dictionaryWithNamedCaptureKeysMatchedByRegex:iso8601Pattern];
    XCTAssertEqualObjects(dict3[@"tz"], @"-08:00");
    XCTAssertEqualObjects(dict3[@"fraction"], @"999");
}

#pragma mark - Insecure HTTP URL Detection

- (void)testInsecureHTTPURLDetection
{
    NSString *insecurePattern = @"http(?!s)://\\S+";

    NSString *text = @"Visit http://example.com and https://secure.com and http://another.org/path?q=1";
    NSArray *insecureURLs = [text substringsMatchedByRegex:insecurePattern];
    XCTAssertEqual(insecureURLs.count, 2UL);
    XCTAssertEqualObjects(insecureURLs[0], @"http://example.com");
    XCTAssertEqualObjects(insecureURLs[1], @"http://another.org/path?q=1");

    // HTTPS-only text should yield no matches
    NSArray *noMatches = [@"https://secure.com https://safe.io" substringsMatchedByRegex:insecurePattern];
    XCTAssertEqual(noMatches.count, 0UL);
}

#pragma mark - Currency Extraction with Lookbehind

- (void)testCurrencyExtractionWithLookbehind
{
    // Fixed-width lookbehind for single currency symbol
    // Use \d+(?:,\d{3})* to match comma-separated groups properly (not trailing commas)
    NSString *currencyPattern = @"(?<=[$\u20AC\u00A3])\\d+(?:,\\d{3})*(?:\\.\\d{2})?";

    NSString *text = @"Prices: $19.99, \u20AC1,234.56, \u00A3500, $3,000.00, and \u20AC42";
    NSArray *amounts = [text substringsMatchedByRegex:currencyPattern];
    XCTAssertEqual(amounts.count, 5UL);
    XCTAssertEqualObjects(amounts[0], @"19.99");
    XCTAssertEqualObjects(amounts[1], @"1,234.56");
    XCTAssertEqualObjects(amounts[2], @"500");
    XCTAssertEqualObjects(amounts[3], @"3,000.00");
    XCTAssertEqualObjects(amounts[4], @"42");
}

#pragma mark - Username Validation

- (void)testUsernameValidation
{
    NSString *usernamePattern = @"^[a-zA-Z0-9_-]{3,16}$";

    // Valid usernames
    XCTAssertTrue([@"john_doe" isMatchedByRegex:usernamePattern]);
    XCTAssertTrue([@"user-123" isMatchedByRegex:usernamePattern]);
    XCTAssertTrue([@"abc" isMatchedByRegex:usernamePattern]);           // minimum length
    XCTAssertTrue([@"a234567890123456" isMatchedByRegex:usernamePattern]); // 16 chars, maximum

    // Invalid usernames
    XCTAssertFalse([@"ab" isMatchedByRegex:usernamePattern]);            // too short
    XCTAssertFalse([@"a2345678901234567" isMatchedByRegex:usernamePattern]); // 17 chars, too long
    XCTAssertFalse([@"user name" isMatchedByRegex:usernamePattern]);     // space
    XCTAssertFalse([@"user@name" isMatchedByRegex:usernamePattern]);     // @ symbol
    XCTAssertFalse([@"user.name" isMatchedByRegex:usernamePattern]);     // dot
}

#pragma mark - Markdown Heading Extraction

- (void)testMarkdownHeadingExtraction
{
    NSString *headingPattern = @"^(#{1,6})\\s+(.+)$";
    NSString *markdown = @"# Title\n## Subtitle\n### Section\nNot a heading\n###### Deepest";

    NSMutableArray<NSDictionary *> *headings = [NSMutableArray array];

    [markdown enumerateStringsMatchedByRegex:headingPattern options:RKXMultiline usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSUInteger level = capturedStrings[1].length;
        NSString *text = capturedStrings[2];
        [headings addObject:@{ @"level" : @(level), @"text" : text }];
    }];

    XCTAssertEqual(headings.count, 4UL);
    XCTAssertEqualObjects(headings[0][@"level"], @1);
    XCTAssertEqualObjects(headings[0][@"text"], @"Title");
    XCTAssertEqualObjects(headings[1][@"level"], @2);
    XCTAssertEqualObjects(headings[1][@"text"], @"Subtitle");
    XCTAssertEqualObjects(headings[2][@"level"], @3);
    XCTAssertEqualObjects(headings[2][@"text"], @"Section");
    XCTAssertEqualObjects(headings[3][@"level"], @6);
    XCTAssertEqualObjects(headings[3][@"text"], @"Deepest");
}

#pragma mark - Slug URL Generation

- (void)testSlugURLGeneration
{
    NSString *input = @"Hello, World! This is a --Test-- of Slug Generation.";

    // Step 1: Lowercase
    NSString *slug = input.lowercaseString;

    // Step 2: Replace non-alphanumeric chars (except hyphens) with hyphens using block API
    slug = [slug stringByReplacingOccurrencesOfRegex:@"[^a-z0-9-]+" usingBlock:^NSString *(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        return @"-";
    }];

    // Step 3: Collapse multiple hyphens
    slug = [slug stringByReplacingOccurrencesOfRegex:@"-{2,}" withTemplate:@"-"];

    // Step 4: Trim leading/trailing hyphens
    slug = [slug stringByReplacingOccurrencesOfRegex:@"^-|-$" withTemplate:@""];

    XCTAssertEqualObjects(slug, @"hello-world-this-is-a-test-of-slug-generation");
}

#pragma mark - ICD-11 Code Validation
#pragma mark   Source: https://www.johndcook.com/blog/2022/10/06/icd11-regex/

- (void)testICD11StemCodeValidation
{
    // ICD-11 stem code: no letters I or O; position 1=alphanumeric, position 2=alpha, position 3=digit,
    // position 4=alphanumeric, optionally followed by dot + 1-2 alphanumeric chars
    // Character class [A-HJ-NP-Z] excludes I and O
    NSString *icd11Pattern = @"^[A-HJ-NP-Z0-9][A-HJ-NP-Z][0-9][A-HJ-NP-Z0-9](?:\\.[A-HJ-NP-Z0-9][A-HJ-NP-Z0-9]?)?$";

    // Valid ICD-11 codes from WHO classification
    XCTAssertTrue([@"ND52" isMatchedByRegex:icd11Pattern]);      // Fracture of forearm
    XCTAssertTrue([@"9D00.3" isMatchedByRegex:icd11Pattern]);    // Presbyopia
    XCTAssertTrue([@"8B60.Y" isMatchedByRegex:icd11Pattern]);    // Increased intracranial pressure
    XCTAssertTrue([@"DB98.7Z" isMatchedByRegex:icd11Pattern]);   // Portal hypertension
    XCTAssertTrue([@"BA00" isMatchedByRegex:icd11Pattern]);      // Essential hypertension
    XCTAssertTrue([@"CA40.0" isMatchedByRegex:icd11Pattern]);    // Asthma
    XCTAssertTrue([@"5A11" isMatchedByRegex:icd11Pattern]);      // Type 2 diabetes
    XCTAssertTrue([@"MG30" isMatchedByRegex:icd11Pattern]);      // Headache

    // Invalid: contains letter I or O
    XCTAssertFalse([@"IA00" isMatchedByRegex:icd11Pattern]);     // I not allowed
    XCTAssertFalse([@"AO00" isMatchedByRegex:icd11Pattern]);     // O not allowed
    XCTAssertFalse([@"AB0I" isMatchedByRegex:icd11Pattern]);     // I in 4th position
    XCTAssertFalse([@"AB00.O" isMatchedByRegex:icd11Pattern]);   // O in extension

    // Invalid structure
    XCTAssertFalse([@"A100" isMatchedByRegex:icd11Pattern]);     // Position 2 must be alpha
    XCTAssertFalse([@"AAA0" isMatchedByRegex:icd11Pattern]);     // Position 3 must be digit
    XCTAssertFalse([@"AB0" isMatchedByRegex:icd11Pattern]);      // Too short (3 chars)
    XCTAssertFalse([@"AB00.ABC" isMatchedByRegex:icd11Pattern]); // Extension too long
    XCTAssertFalse([@"AB00." isMatchedByRegex:icd11Pattern]);    // Trailing dot with no extension
}

- (void)testICD11NamedCaptureComponentExtraction
{
    // Named capture version for parsing ICD-11 code components
    NSString *icd11NamedPattern = @"^(?<block>[A-HJ-NP-Z0-9][A-HJ-NP-Z])(?<category>[0-9][A-HJ-NP-Z0-9])(?:\\.(?<extension>[A-HJ-NP-Z0-9]{1,2}))?$";

    NSDictionary *parts = [@"DB98.7Z" dictionaryWithNamedCaptureKeysMatchedByRegex:icd11NamedPattern];
    XCTAssertEqualObjects(parts[@"block"], @"DB");
    XCTAssertEqualObjects(parts[@"category"], @"98");
    XCTAssertEqualObjects(parts[@"extension"], @"7Z");

    NSDictionary *simple = [@"BA00" dictionaryWithNamedCaptureKeysMatchedByRegex:icd11NamedPattern];
    XCTAssertEqualObjects(simple[@"block"], @"BA");
    XCTAssertEqualObjects(simple[@"category"], @"00");

    NSDictionary *withExt = [@"9D00.3" dictionaryWithNamedCaptureKeysMatchedByRegex:icd11NamedPattern];
    XCTAssertEqualObjects(withExt[@"block"], @"9D");
    XCTAssertEqualObjects(withExt[@"category"], @"00");
    XCTAssertEqualObjects(withExt[@"extension"], @"3");
}

- (void)testICD11CodeExtractionFromClinicalText
{
    // Extract ICD-11 codes embedded in clinical text (word-bounded)
    NSString *icd11InTextPattern = @"\\b[A-HJ-NP-Z0-9][A-HJ-NP-Z][0-9][A-HJ-NP-Z0-9](?:\\.[A-HJ-NP-Z0-9]{1,2})?\\b";

    NSString *note = @"Patient diagnosed with BA00 (essential hypertension), "
                      "CA40.0 (asthma), and 5A11 (type 2 diabetes). "
                      "Also see DB98.7Z for portal hypertension.";

    NSArray *codes = [note substringsMatchedByRegex:icd11InTextPattern];
    XCTAssertEqual(codes.count, 4UL);
    XCTAssertEqualObjects(codes[0], @"BA00");
    XCTAssertEqualObjects(codes[1], @"CA40.0");
    XCTAssertEqualObjects(codes[2], @"5A11");
    XCTAssertEqualObjects(codes[3], @"DB98.7Z");
}

- (void)testICD11BatchExtractionWithCaptures
{
    NSString *icd11CapturePattern = @"\\b([A-HJ-NP-Z0-9][A-HJ-NP-Z])([0-9][A-HJ-NP-Z0-9])(?:\\.([A-HJ-NP-Z0-9]{1,2}))?\\b";

    NSString *records = @"Codes: ND52, 9D00.3, MG30, 8B60.Y";
    NSArray<NSArray *> *allCaptures = [records arrayOfCaptureSubstringsMatchedByRegex:icd11CapturePattern];

    XCTAssertEqual(allCaptures.count, 4UL);

    // ND52: block=ND, category=52, no extension
    XCTAssertEqualObjects(allCaptures[0][1], @"ND");
    XCTAssertEqualObjects(allCaptures[0][2], @"52");

    // 9D00.3: block=9D, category=00, extension=3
    XCTAssertEqualObjects(allCaptures[1][1], @"9D");
    XCTAssertEqualObjects(allCaptures[1][2], @"00");
    XCTAssertEqualObjects(allCaptures[1][3], @"3");

    // MG30: block=MG, category=30
    XCTAssertEqualObjects(allCaptures[2][1], @"MG");
    XCTAssertEqualObjects(allCaptures[2][2], @"30");

    // 8B60.Y: block=8B, category=60, extension=Y
    XCTAssertEqualObjects(allCaptures[3][1], @"8B");
    XCTAssertEqualObjects(allCaptures[3][2], @"60");
    XCTAssertEqualObjects(allCaptures[3][3], @"Y");
}

- (void)testICD11EnumerationWithBlockAPI
{
    NSString *icd11Pattern = @"\\b([A-HJ-NP-Z0-9][A-HJ-NP-Z][0-9][A-HJ-NP-Z0-9](?:\\.[A-HJ-NP-Z0-9]{1,2})?)\\b";
    NSString *report = @"Discharge: BA00, CA40.0, 5A11, DB98.7Z, ND52";

    NSMutableArray<NSString *> *codesWithExtensions = [NSMutableArray array];
    NSMutableArray<NSString *> *codesWithoutExtensions = [NSMutableArray array];

    [report enumerateStringsMatchedByRegex:icd11Pattern usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop) {
        NSString *code = capturedStrings[1];
        if ([code isMatchedByRegex:@"\\."]) {
            [codesWithExtensions addObject:code];
        } else {
            [codesWithoutExtensions addObject:code];
        }
    }];

    XCTAssertEqual(codesWithExtensions.count, 2UL);
    XCTAssertTrue([codesWithExtensions containsObject:@"CA40.0"]);
    XCTAssertTrue([codesWithExtensions containsObject:@"DB98.7Z"]);

    XCTAssertEqual(codesWithoutExtensions.count, 3UL);
    XCTAssertTrue([codesWithoutExtensions containsObject:@"BA00"]);
    XCTAssertTrue([codesWithoutExtensions containsObject:@"5A11"]);
    XCTAssertTrue([codesWithoutExtensions containsObject:@"ND52"]);
}

@end
