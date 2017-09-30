# RegexKitX

Use the pattern-matching Force.

## Swift

This is a Swift 4 implementation inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API. It is:

- Yet another cover for `NSRegularExpression` and `NSTextCheckingResult`.
- 100% pure ICU regex syntax
- Allows the developer the ability to use either *NSRange* or *Range<String.UTF16Index>* to operate on portions of substrings.

## Objective-C

**NOTE:** There's an almost-pure RKL4-API re-implementation [here](https://github.com/samkrishna/RegexKitX/releases/tag/5.0-swap-fixed). This version is nearly a drop-in replacement for the original *RKL4* codebase.

This is a Regular Expression API inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API that John Engelhart (@johnezang) [shipped back in 2010](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). ("*RKL4*")

Basically, I'm modernizing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult). I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](http://nshipster.com/nsregularexpression/)
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The low-level *RKL4* C code accessing the [ICU](http://site.icu-project.org/) regex engine spits out deprecation warnings on macOS 10.12 Sierra
- The annoyance of having to always remember to **ALWAYS link to the ICU library** on every project

My concern is that no amount of work-arounds or modifications to all the low-level *RKL4* magic code will save it from being unbuildable in the near-future. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of `NSRegularExpression`, I'm choosing to do this.

I've also added documentation that is option-clickable for all the *RKX* category methods.

## A few caveats:

1. I've re-ordered and modernized some of the argument and block parameters for a number of APIs.
1. I've renamed a few APIs as well.
1. The regex syntax is 100%-pure ICU syntax.
1. `RKLRegexEnumerationOptions` is deprecated.
1. The `RKLICURegex...Error` keys are deprecated in exchange for the `NSRegularExpression` instantiation errors.
1. For some of the block methods, I'm exposing `NSEnumerationOptions` to provide an option for directional control of the enumeration. As usual, `NSEnumerationConcurrent` behavior is undefined.
1. `NSRegularExpression` and `NSTextCheckingResult` use `NSUInteger` as a return type (especially for capture indexes and capture counts) and *RKX* follows that convention. The various method clusters reflect the type change. This should be fine for all 64-bit apps going forward, which is what I chose to focus on. I have replaced the `-1` error return code with `NSNotFound` in case of failure.

## Tests

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. @johnezang also included a few test executables in his *RKL4* sources, which are now ported and exist as test cases.

Additional test cases and pull requests are welcome.
