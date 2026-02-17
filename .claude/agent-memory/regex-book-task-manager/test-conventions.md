# Test File Conventions

## License Header Template
```objc
//
//  MasteringRegexChXXTests.m
//  RegexKitXTests

/*
 Created by Sam Krishna on 2/11/26.
 Copyright (c) 2026 Sam Krishna. All rights reserved.

 [Full BSD 3-Clause text]
*/
```

## File Structure Template
```objc
// Tests derived from "Mastering Regular Expressions, 3rd Edition" by Jeffrey E.F. Friedl
// Chapter X: Title (pp.XXX-YYY)

#import "RegexKitX.h"
#import <XCTest/XCTest.h>

@interface MasteringRegexChXXTests : XCTestCase
@end

@implementation MasteringRegexChXXTests

#pragma mark - Section Name

- (void)testDescriptiveName
{
    // MRE3 p.XX: Brief description of the concept being tested
    NSString *regex = @"pattern";
    // ... assertions ...
}

@end
```

## Key Patterns
- Page references in comments: `// MRE3 p.XX:` or `// MRE3 pp.XX-YY:`
- Use `XCTAssertTrue`/`XCTAssertFalse` for boolean checks
- Use `XCTAssertEqualObjects` for string/array comparisons
- Use `XCTAssertEqual` for numeric comparisons
- Use `XCTAssertNil`/`XCTAssertNotNil` for nil checks
- Open brace on same line as method signature: `- (void)testFoo {` wait -- actually next line
- Actually from code: open brace on NEXT line after method signature

## RKXRegexOptions Constants
- RKXNoOptions, RKXCaseless, RKXIgnoreWhitespace, RKXIgnoreMetacharacters
- RKXDotAll, RKXMultiline, RKXUseUnixLineSeparators, RKXUnicodeWordBoundaries
