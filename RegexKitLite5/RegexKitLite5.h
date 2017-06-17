//
//  RegexKitLite5.h
//  RegexKitLite5
//
//  Created by Sam Krishna on 6/12/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, RKLRegexOptions) {
    RKLNoOptions                = 0,
    RKLCaseless                 = NSRegularExpressionCaseInsensitive,
    RKLComments                 = NSRegularExpressionAllowCommentsAndWhitespace,
    RKLIgnoreMetacharacters     = NSRegularExpressionIgnoreMetacharacters,
    RKLDotAll                   = NSRegularExpressionDotMatchesLineSeparators,
    RKLMultiline                = NSRegularExpressionAnchorsMatchLines,
    RKLUseUnixLineSeparators    = NSRegularExpressionUseUnixLineSeparators,
    RKLUnicodeWordBoundaries    = NSRegularExpressionUseUnicodeWordBoundaries
};

// NSException exception name.
extern NSString * const RKLICURegexException;

// NSError error domains and user info keys.
extern NSString * const RKLICURegexErrorDomain;

extern NSString * const RKLICURegexEnumerationOptionsErrorKey;
extern NSString * const RKLICURegexErrorCodeErrorKey;
extern NSString * const RKLICURegexErrorNameErrorKey;
extern NSString * const RKLICURegexLineErrorKey;
extern NSString * const RKLICURegexOffsetErrorKey;
extern NSString * const RKLICURegexPreContextErrorKey;
extern NSString * const RKLICURegexPostContextErrorKey;
extern NSString * const RKLICURegexRegexErrorKey;
extern NSString * const RKLICURegexRegexOptionsErrorKey;
extern NSString * const RKLICURegexReplacedCountErrorKey;
extern NSString * const RKLICURegexReplacedStringErrorKey;
extern NSString * const RKLICURegexReplacementStringErrorKey;
extern NSString * const RKLICURegexSubjectRangeErrorKey;
extern NSString * const RKLICURegexSubjectStringErrorKey;

#ifndef REGEXKITLITE_VERSION_MAJOR
@interface NSString (EntireRange)
- (NSRange)stringRange;
@end
#endif

@interface NSString (RegexKitLite5)

#pragma mark - componentsSeparatedByRegex:

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern;
- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern range:(NSRange)range;
- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error;
- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error;

#pragma mark - isMatchedByRegex:

- (BOOL)isMatchedByRegex:(NSString *)pattern;
- (BOOL)isMatchedByRegex:(NSString *)pattern inRange:(NSRange)range;
- (BOOL)isMatchedByRegex:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error;
- (BOOL)isMatchedByRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error;

#pragma mark - rangeOfRegex:

- (NSRange)rangeOfRegex:(NSString *)pattern;
- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSInteger)capture;
- (NSRange)rangeOfRegex:(NSString *)pattern inRange:(NSRange)range;
- (NSRange)rangeOfRegex:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;
- (NSRange)rangeOfRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;


#pragma mark - stringByMatching:

- (NSString *)stringByMatching:(NSString *)pattern;
- (NSString *)stringByMatching:(NSString *)pattern capture:(NSInteger)capture;
- (NSString *)stringByMatching:(NSString *)pattern inRange:(NSRange)range;
- (NSString *)stringByMatching:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;
- (NSString *)stringByMatching:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement;
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement range:(NSRange)searchRange;
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement options:(RKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error;
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error;

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regex usingBlock:(NSString *(^)(NSInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regex options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

#pragma mark - captureCount:

#pragma mark - isRegexValid

#pragma mark - componentsMatchedByRegex:

#pragma mark - captureComponentsMatchedByRegex:

#pragma mark - arrayOfCaptureComponentsMatchedByRegex:

#pragma mark - arrayOfDictionariesByMatchingRegex:

#pragma mark - dictionaryByMatchingRegex:

#pragma mark - enumerateStringsByMatchingRegex:usingBlock:

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

@end

@interface NSMutableString (RegexKitLite5)

#pragma mark - replaceOccurrencesOfRegex:withString:

#pragma mark - replaceOccurrencesOfRegex:usingBlock:

@end
