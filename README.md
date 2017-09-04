# RegexKitLite5

Use the pattern-matching Force.

## Swift

This is a Swift 4 implementation inspired by the *RKL4* API. It is:

- Yet another cover for `NSRegularExpression` and `NSTextCheckingResult`.
- 100% pure ICU regex syntax

## Objective-C

This is a API port of the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) NSString category that John Engelhart (@johnezang) shipped back on [2010-04-18](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). ("*RKL4*")

Basically, I'm reimplementing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult). I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](http://nshipster.com/nsregularexpression/)
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The low-level *RKL4* C code accessing the [ICU](http://site.icu-project.org/) regex engine is starting to spit out deprecation warnings on macOS 10.12 Sierra
    - Right now, this looks like it's limited to the `OSSpinLock/Unlock` family of locking functions
- The annoyance of having to always remember to **ALWAYS link to the ICU library** on every project

My concern is that no amount of work-arounds or modifications to all the low-level *RKL4* magic code will save it from being unbuildable in the near-future. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of `NSRegularExpression`, I'm choosing to do this.

I've also added documentation that is option-click-able for all the *RKL5* category methods.

## A few caveats:

1. Any *RKL4*-based PCRE-like regex nuances that differ from ICU-compatible regexes are fully deprecated because of the conversion to `NSRegularExpression`. This codebase is 100%-pure ICU regex syntax. For the vast majority of regexes, there should be no issues. **HOWEVER**, if your regex relied on non-ICU nuances that worked in *RKL4*, you'll likely need to modify the regex to be ICU-compliant and/or update your code.
    - For example, @johnezang chose to go with the Perl-compatible implementation rather than the ICU implemenation when separating strings using the word boundary `\b` metacharacter in a regex. *RKL5* follows the ICU convention of placing empty string as the starting and ending 'boundaries' of a match when using the `\b` metacharacter. You can see the not-exactly failed test case at `-testLegacyICUtoPerlOperationalFix` in RegexKitLite5Tests.m.
1. `RKLRegexEnumerationOptions` is deprecated.
1. The `RKLICURegex...Error` keys are deprecated in exchange for the `NSRegularExpression` instantiation errors.
1. I'm exposing the `NSMatchingOptions` options flag set as an explicit argument set on the most argument-rich API call in each "method cluster". However, I'm not forcing anyone to call that API.
1. For some of the block methods, I'm exposing `NSEnumerationOptions` to provide an option for directional control of the enumeration. As usual, `NSEnumerationConcurrent` behavior is undefined.
1. `NSRegularExpression` and `NSTextCheckingResult` use `NSUInteger` as a return type (especially for capture indexes and capture counts) and *RKL5* follows that convention. The various method clusters reflect the type change. This should be fine for all 64-bit apps going forward, which is what I chose to focus on. I have replaced the `-1` error return code with `NSNotFound` in case of failure.

## Tests

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. There's a whole set of test cases in the original [RegexKit 0.6.0](https://sourceforge.net/projects/regexkit/files/regexkit/RegexKit_0.6.0/) sources. ~~that I have yet to vet, port, and integrate.~~ (UPDATE: After looking through the RegexKit 0.6 tests, I've decided to take a pass on the vast majority of them. They are for PCRE-consumable regular expressions, which are a distinctly different dialect than the ICU regular expressions.)
1. I am also taking a pass on most of the RegexKit 0.6 tests because they are:
    - Low-level
    - Have interactions with the long-since deprecated Garbage Collector from 10-ish years ago
    - Have a different API modality paradigm than the *RKL4* APIs
1. @johnezang also included a few test executables in his *RKL4* sources, which are now ported and exist as test cases.

Additional test cases and pull requests are welcome.
