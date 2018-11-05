# RegexKitX

Use the pattern-matching Force.

## Swift

This is a Swift 4 implementation inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API. It is:

- Yet another cover for `NSRegularExpression` and `NSTextCheckingResult`.
- 100% pure ICU regex syntax
- Allows the developer the ability to use either *NSRange* or *Range<String.UTF16Index>* to operate on portions of substrings.

## Objective-C

This is a Regular Expression API inspired by the [RegexKitLite 4.0](http://regexkit.sourceforge.net/#RegexKitLite) API that John Engelhart (@johnezang) [shipped back in 2010](http://regexkit.sourceforge.net/RegexKitLite/index.html#ReleaseInformation_40). ("*RKL4*")

Basically, I'm modernizing the API as a cover for [NSRegularExpression](https://developer.apple.com/documentation/foundation/nsregularexpression) and [NSTextCheckingResult](https://developer.apple.com/documentation/foundation/nstextcheckingresult).

I am doing this for several reasons:

- How [unwieldy NSRegularExpression naturally is](http://nshipster.com/nsregularexpression/)
- The false positives that the Clang Static Analyzer flagged in *RKL4*
- The fact that *RKL4* is **NOT** ARC-compliant
- The fact that the low-level *RKL4* C code accessing the [ICU](http://site.icu-project.org/) regex engine spits out `OSSpinLock`-based deprecation warnings on macOS 10.12 Sierra and above
- How easy it is to forget to **ALWAYS link to the ICU library** on every project using *RKL4*

My concern is that no amount of work-arounds or modifications to all the low-level *RKL4* magic code will save it from being unbuildable in the near-future. So rather than wait for that to happen or repeatedly deal directly with the awkwardness of `NSRegularExpression`, I'm choosing to do RegexKitX ("*RKX*").

I've also added documentation that is option-clickable for all the *RKX* category methods.

**NOTE:** There's an almost-pure *RKL4* API re-implementation [here](https://github.com/samkrishna/RegexKitX/releases/tag/5.0-swap-fixed). This version is intended to be a drop-in replacement for the original *RKL4* codebase. If you are using the original *RKL4* block-based API and choose to use*RKX* as a drop-in replacement, you'll need to do some modifications at the block signature level. Specifically, you'll need to convert *RKL4* API blocks from this kind of block signature:

```
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regex 
                            usingBlock:(void (^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
```
to this kind of block signature:

```
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern 
                            usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

```

It's a small conversion to `NSArray` for the `capturedStrings` block argument.

## A few caveats:

1. I've re-ordered and modernized some of the argument and block parameters for a number of APIs.
1. I've renamed a few APIs as well to make them grammatically consistent.
1. The regex syntax is 100%-pure ICU syntax.
1. For some of the block methods, I'm exposing `NSEnumerationOptions` to provide an option for directional control of the enumeration. As usual, `NSEnumerationConcurrent` behavior is undefined.

## Tests

1. I have started a Unit Test file that tests the baseline argument-rich methods for expected behavior.
1. @johnezang also included a few test executables in his *RKL4* sources, which are now ported and exist as test cases.
1. I've also started adding a few pedagogical examples that have helped me learn some of the more nuanced aspects of regexes.
1. I've included [a set of performance tests from Jon Clayden](https://rpubs.com/jonclayden/regex-performance) performing matches against a non-trivial size of text.

Additional test cases and pull requests are welcome.

## Inspiration

I've loved regular expressions since the beginning of my programming career back when I worked at Apple. I learned (and continue to learn) A LOT from Jeffrey Friedl's book, [Mastering Regular Expression, 3rd. ed](http://shop.oreilly.com/product/9780596528126.do). I know they are [controversial](https://blog.codinghorror.com/regex-use-vs-regex-abuse/) in some circles but when crafted well, there's really nothing like them.

Here's some follow-up reading about regexes:

- [Patrick Triest: You Should Learn Regex](https://blog.patricktriest.com/you-should-learn-regex/)
- [Regular Expression Matching Can Be Simple and Fast](https://swtch.com/~rsc/regexp/regexp1.html)
- [Why are regular expressions so controversial?](https://stackoverflow.com/q/764247)
