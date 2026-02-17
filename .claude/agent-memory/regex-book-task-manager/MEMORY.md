# Regex Book Task Manager - Agent Memory

## Project Baseline
- 397 tests pass, 0 failures (verified 2026-02-11, after adding Ch4/Ch6/Ch7-10)
- Was 328 tests before this session; added 69 new tests total
- Current branch: `ai-testing` (based off `master`)
- Test files live in: `/Users/achilles/Projects/OpenSource/RegexKitX/RegexKitXTests/`

## Xcode Project Integration
- pbxproj: `/Users/achilles/Projects/OpenSource/RegexKitX/RegexKitX.xcodeproj/project.pbxproj`
- ID pattern for MasteringRegex files: `AA000000XX000000AABB0001` (fileRef), `AA000000XX000000AABB0002` (buildFile)
- New files need entries in: PBXBuildFile, PBXFileReference, PBXGroup (children), PBXSourcesBuildPhase
- See [xcode-integration.md](xcode-integration.md) for details

## MRE3 Book Coverage Status
- Ch1 (pp.1-33): DONE - 11 tests in MasteringRegexCh01Tests.m
- Ch2 (pp.35-81): DONE - 8 tests in MasteringRegexCh02Tests.m
- Ch3 (pp.83-142): DONE - 11 tests in MasteringRegexCh03Tests.m
- Ch4 (pp.143-184): DONE - 26 tests in MasteringRegexCh04Tests.m (added 2026-02-11)
- Ch5 (pp.185-219): DONE - 10 tests in MasteringRegexCh05Tests.m
- Ch6 (pp.221-284): DONE - 19 tests in MasteringRegexCh06Tests.m (added 2026-02-11)
- Ch7-10 (pp.285-528): DONE - 24 tests in MasteringRegexCh07_10Tests.m (added 2026-02-11)
- ALL CHAPTERS COVERED

## Test Conventions
- BSD 3-Clause license header (Sam Krishna, 2026)
- `#import "RegexKitX.h"` and `#import <XCTest/XCTest.h>`
- `#pragma mark -` section headers organize tests by topic
- Method naming: `testDescriptiveName` (camelCase)
- Comments reference MRE3 page numbers: `// MRE3 p.XX: description`
- See [test-conventions.md](test-conventions.md) for template

## Key API Methods for Tests
- `isMatchedByRegex:` / `isMatchedByRegex:options:`
- `stringMatchedByRegex:` / `stringMatchedByRegex:options:`
- `substringsMatchedByRegex:` / `substringsMatchedByRegex:capture:`
- `captureSubstringsMatchedByRegex:`
- `arrayOfCaptureSubstringsMatchedByRegex:`
- `dictionaryWithNamedCaptureKeysMatchedByRegex:`
- `stringByReplacingOccurrencesOfRegex:withTemplate:`
- `substringsSeparatedByRegex:`
- `enumerateStringsMatchedByRegex:options:usingBlock:`
- `isRegexValidWithOptions:error:`
- `captureCountWithOptions:error:`

## Work Job History (all completed)
1. ch04-engine-mechanics: 26 tests - backtracking, alternation order, atomic/possessive, lookaround
2. ch06-efficient-expressions: 19 tests - unrolled loop, leading char, atomic perf, comma insertion
3. ch07-10-icu-patterns: 24 tests - named captures, lookaround combos, Unicode, block APIs

## Lessons Learned
- `-Werror` in the project: all warnings are errors. Unused variables cause build failure.
- `short` is a C keyword -- cannot be used as a variable name in Objective-C
- `stringMatchedByRegex:options:capture:` does not exist; use `stringMatchedByRegex:range:capture:options:error:`
- Negative lookbehind `(?<!XXX)\d+` can match partial digit runs (e.g. "00" within "200" after "EUR")
- Possessive `*+` on outer groups truly prevents all backtracking (unlike just `++` inside)
- ICU regex supports: atomic groups (?>), possessive quantifiers (++, *+, ?+), named captures, class intersection (&&)
- ICU regex does NOT support: variable-length lookbehind, recursive patterns, conditional patterns
