# RegexKitLite5

This is a API port of the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) NSString category that John Engelhart (@johnezang) shipped back on [2010-04-18](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). ("*RKL4*")

Basically, I'm reimplementing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult). I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](http://nshipster.com/nsregularexpression/)
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The low-level C code to the ICU regex engine is starting to spit out deprecation warnings on macOS 10.12 Sierra
    - Right now, this looks like it's limited to the `OSSpinLock/Unlock` family of locking functions
- The annoyance of having to always remember to **ALWAYS link to the ICU library** on every project

My concern is that no amount of work-arounds or modifications to all the low-level magic will save *RKL4* from being unbuildable in the near-future. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of `NSRegularExpression`, I'm choosing to do this.

A few caveats:

1. `RKLRegexEnumerationOptions` is deprecated.
1. The `RKLICURegex...Error` keys are deprecated in exchange for the `NSRegularExpression` instantiation errors.
1. I'm exposing the `NSMatchingOptions` options flag set as an explicit argument set on the most argument-rich API call in each "method cluster". However, I'm not forcing anyone to call that API.
1. `NSRegularExpression` and `NSTextCheckingResult` are given to using `NSUInteger` as a return type (especially for capture indexes and capture counts). The various method clusters reflect the type change. This should be fine for all 64-bit apps going forward, which is what I chose to focus on.
1. @johnezang chose to go with the Perl implementation rather than the ICU implemenation when separating strings using the word boundary `\b` metacharacter in a regex. As of right now, the code is following the ICU convention of placing empty string as the starting and ending 'boundaries' of a match. You can see the not-exactly failed test case at `-testICUtoPerlOperationalFix` in RegexKitLite5Tests.m.

## Tests

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. There's a whole set of test cases in the original [RegexKit 0.6.0](https://sourceforge.net/projects/regexkit/files/regexkit/RegexKit_0.6.0/) sources. ~~that I have yet to vet, port, and integrate.~~ (UPDATE: After looking through the RegexKit 0.6 tests, I've decided to take a pass on the vast majority of them. They are for PCRE-consumable regular expressions, which are a distinctly different dialect than the ICU regular expressions.)
1. I am also taking a pass on most of the RegexKit 0.6 tests because they are:
    - Low-level
    - Have interactions with the long-since deprecated Garbage Collector from 10-ish years ago
    - Have a different API modality paradigm than the RKL4 APIs
1. @johnezang also included a few test executables in his *RKL4* sources, which are now ported and exist as test cases.

Additional test cases and pull requests are welcome.
