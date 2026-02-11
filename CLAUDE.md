# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RegexKitX (RKX) is an Objective-C framework that provides an NSString category wrapping Apple's NSRegularExpression/NSTextCheckingResult with a cleaner API. It modernizes the RegexKitLite 4.0 API with ARC compliance, named capture support, and block-based enumeration. Uses 100%-pure ICU regex syntax.

## Build & Test Commands

```bash
# Build
xcodebuild build -scheme RegexKitX

# Run all tests (265 tests across 9 test files)
xcodebuild test -scheme RegexKitX

# Run a specific test class
xcodebuild test -scheme RegexKitX -only-testing:RegexKitXTests/RegexKitXTests

# Run a single test method
xcodebuild test -scheme RegexKitX -only-testing:RegexKitXTests/RegexKitXTests/testStringMatchedByRegex
```

Build configurations: Debug (default), Release. Target platform: macOS (arm64/x86_64).

## Architecture

The entire framework is two files:

- **`RegexKitX/RegexKitX.h`** — Public API header defining `RKXRegexOptions`, `RKXMatchOptions`, timeout error constants, and all NSString/NSMutableString category methods
- **`RegexKitX/RegexKitX.m`** — Implementation wrapping NSRegularExpression. Contains internal helper categories on NSArray, NSMutableArray, and NSTextCheckingResult (under `RangeMechanics` category name)

### API Categories

The NSString category methods fall into these groups:
- **Query**: `isMatchedByRegex:`, `isRegexValid`, `rangeOfRegex:`, `rangesOfRegex:`, `stringMatchedByRegex:`
- **Capture extraction**: `captureSubstringsMatchedByRegex:`, `arrayOfCaptureSubstringsMatchedByRegex:`, `substringsMatchedByRegex:`
- **Dictionary-based**: `dictionaryMatchedByRegex:`, `dictionaryWithNamedCaptureKeysMatchedByRegex:`, `arrayOfDictionariesMatchedByRegex:`
- **Replacement**: `stringByReplacingOccurrencesOfRegex:withTemplate:` (NSString), `replaceOccurrencesOfRegex:withTemplate:` (NSMutableString)
- **Splitting**: `substringsSeparatedByRegex:`
- **Block-based enumeration**: Most methods have block variants accepting `NSEnumerationOptions` for directional control

Most methods have overloads accepting additional parameters: `options:` (RKXRegexOptions), `matchOptions:` (RKXMatchOptions), `range:` (search range), and `error:` (NSError out-param).

### Test Structure

- **`RegexKitXTests/RegexKitXTests.m`** — Core API tests; uses a Sherlock Holmes text corpus loaded from `sherlock-utf-8.txt` as test data
- **`RegexCookbookCh0[3-9]Tests.m`** — Real-world regex examples from "Regular Expressions Cookbook" (chapters 3-9)
- **`RegexTipTests.m`** — Miscellaneous regex tips

### Test Materials

- Use [Mastering Regular Expressions](https://kagi-dropbox.sfo2.cdn.digitaloceanspaces.com/Developer/mastering_regular_expressions_third_edition.pdf) for regex testing opportunities.
- Avoid duplicating any test cases or their regexes that have already been captured as a test case.

## Code Conventions

- Modern Objective-C with ARC, lightweight generics (`NSArray<NSString *>`), and `@import Foundation`
- Doxygen-style documentation (`@param`, `@return`, `@discussion`) on all public methods for Xcode option-click support
- BSD 3-Clause license header on all source files
- SwiftRegexKitX is deprecated (Apple's native Swift Regex/RegexBuilder supersedes it)
