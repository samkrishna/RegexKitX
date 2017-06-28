# RegexKitLite5

This is a API port of the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) NSString category that John Engelhart (@johnezang) shipped back on [2010-04-18](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). (hereon identified as *RKL4*)

Basically, I'm reimplementing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult). I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](http://nshipster.com/nsregularexpression/)
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The low-level C code to the ICU regex engine is starting to spit out deprecation warnings on macOS 10.12 Sierra
    - Right now, this looks like it's limited to the OSSpinLock/Unlock family of locking functions
- The annoyance of having to always remember to **ALWAYS link to the ICU library** on every project

My concern is that no amount of work-arounds or modifications to all the low-level magic will save *RKL4* from being unbuildable in the near-future. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of NSRegularExpression, I'm choosing to do this.

A few caveats:

1. This is a naive re-implementation. There's very little that's currently elegant and/or performant about the code.
1. I have not done **any** performance testing on this, but I am certain this API re-implementation is slower than the low-level magic code that @johnezang originally wrote.
1. `RKLRegexEnumerationOptions` is deprecated.
1. The `RKLICURegex...Error` keys are deprecated in exchange for the NSRegularExpression instantiation errors.
1. I'm exposing the `NSMatchingOptions` options flag set as an explicit argument set on the most argument-rich API call in each "method cluster". However, I'm not forcing anyone to call that API.
1. @johnezang chose to go with the Perl implementation rather than the ICU implemenation when separating strings using the word boundary `\b` metacharacter in a regex. As of right now, the code is following the ICU convention of placing empty string as the starting and ending 'boundaries' of a match. You can see the failed test case at `-testICUtoPerlOperationalFix` in RegexKitLite5Tests.m.

## Tests

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. There's a whole set of test cases in the original [RegexKit 0.6.0](https://sourceforge.net/projects/regexkit/files/regexkit/RegexKit_0.6.0/) sources that I have yet to vet, port, and integrate.
1. @johnezang also included a few test executables in his *RKL4* sources, but those have not been ported yet.



