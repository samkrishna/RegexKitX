# RegexKitX

Use the pattern-matching Force.

## Inspiration

I've loved regular expressions since the beginning of my programming career back when I worked at Apple. I learned (and continue to learn) A LOT from Jeffrey Friedl's book, [Mastering Regular Expression, 3rd. ed](http://shop.oreilly.com/product/9780596528126.do). I know they are [controversial](https://blog.codinghorror.com/regex-use-vs-regex-abuse/) in some circles but when crafted well, there's really nothing like them.

Here's some follow-up reading about regexes:

- [Jan Meppe: Regex for Noobs (like me)](https://www.janmeppe.com/blog/regex-for-noobs/)
- [Patrick Triest: You Should Learn Regex](https://blog.patricktriest.com/you-should-learn-regex/)
- [Regular Expression Matching Can Be Simple and Fast](https://swtch.com/~rsc/regexp/regexp1.html)
- [Why are regular expressions so controversial?](https://stackoverflow.com/q/764247)
- [Regular Expressions 101](https://regex101.com) (NOTE: This is a GREAT regex testing site!)
- [Regex Crossword](https://regexcrossword.com)

## Objective-C

This is a Regular Expression API inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API that John Engelhart (@johnezang) [shipped back in 2010](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). ("*RKL4*")

Basically, I'm modernizing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult).

I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](https://web.archive.org/web/20180102233205/http://nshipster.com/nsregularexpression/) 
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The fact that *RKL4* is **NOT** ARC-compliant
- The fact that the low-level *RKL4* C code accessing the [ICU regex engine](http://userguide.icu-project.org/strings/regexp) spits out `OSSpinLock`-based deprecation warnings on macOS 10.12 Sierra and above
- ~~How easy it is to forget to **ALWAYS link to the ICU library** on every project using *RKL4*~~ (Obviously CocoaPods solves this)
- I wanted to provide cover API for named captures and backreferences, which NSRegularExpression supports, and *RKL4* does not.

My concern is that no amount of work-arounds or modifications to all the low-level *RKL4* magic code will save it from being unbuildable or free of static analyzer warnings in a future appleOS. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of NSRegularExpression, I'm choosing to do RegexKitX ("*RKX*").

I've also added documentation that is option-clickable for all the *RKX* category methods.

**NOTE:** There's an almost-pure *RKL4* API re-implementation [here](https://github.com/samkrishna/RegexKitX/releases/tag/5.0). This version is intended to be a drop-in replacement (with possible block-based modifications) for the original  *RKL4* codebase.

## A few caveats:

1. I've re-ordered and modernized some of the argument and block parameters for a number of APIs.
1. I've renamed a few APIs as well to make them grammatically and contextually consistent and follow Apple naming conventions from NSString.
1. The regex syntax is [100%-pure ICU syntax](http://userguide.icu-project.org/strings/regexp) (the original *RKL4* diverged slightly away from ICU).
1. For some of the block methods, I'm exposing `NSEnumerationOptions` to provide an option for directional control of the enumeration. As usual, `NSEnumerationConcurrent` behavior is undefined.

## Swift

This is a Swift 5.x implementation inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API. It is:

- Yet another cover for `NSRegularExpression` and `NSTextCheckingResult`.
- 100% pure ICU regex syntax
- Allows the developer the ability to use either *NSRange* or *Range<String.UTF16View.Index>* to operate on portions of substrings.
- Not yet feature-complete *vis-a-vis* its Objective-C counterpart.

## Test Suite

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. @johnezang also included a few test executables in his *RKL4* sources, which are now ported and exist as test cases.
1. I've also started adding a few pedagogical examples that have helped me learn some of the more nuanced aspects of regexes.
1. I've included [a set of performance tests from Jon Clayden](https://rpubs.com/jonclayden/regex-performance) performing matches against a non-trivial size of text.
1. I've implemented the vast majority of examples and implemented AT LEAST one sample from ALL of the exercises from the [Regular Expressions Cookbook, 2nd Ed.](http://www.regular-expressions-cookbook.com) by Steven Levithan and Jan Goyvaerts.

Additional test cases and pull requests are welcome.
