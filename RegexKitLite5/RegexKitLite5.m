//
//  RegexKitLite5.m
//  RegexKitLite5
//
//  Created by Sam Krishna on 6/12/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

#import "RegexKitLite5.h"

#pragma mark - Exported NSString symbols for exception names, error domains, error keys, etc -

NSString * const RKLICURegexException                  = @"RKLICURegexException";

NSString * const RKLICURegexErrorDomain                = @"RKLICURegexErrorDomain";

NSString * const RKLICURegexEnumerationOptionsErrorKey = @"RKLICURegexEnumerationOptions";
NSString * const RKLICURegexErrorCodeErrorKey          = @"RKLICURegexErrorCode";
NSString * const RKLICURegexErrorNameErrorKey          = @"RKLICURegexErrorName";
NSString * const RKLICURegexLineErrorKey               = @"RKLICURegexLine";
NSString * const RKLICURegexOffsetErrorKey             = @"RKLICURegexOffset";
NSString * const RKLICURegexPreContextErrorKey         = @"RKLICURegexPreContext";
NSString * const RKLICURegexPostContextErrorKey        = @"RKLICURegexPostContext";
NSString * const RKLICURegexRegexErrorKey              = @"RKLICURegexRegex";
NSString * const RKLICURegexRegexOptionsErrorKey       = @"RKLICURegexRegexOptions";
NSString * const RKLICURegexReplacedCountErrorKey      = @"RKLICURegexReplacedCount";
NSString * const RKLICURegexReplacedStringErrorKey     = @"RKLICURegexReplacedString";
NSString * const RKLICURegexReplacementStringErrorKey  = @"RKLICURegexReplacementString";
NSString * const RKLICURegexSubjectRangeErrorKey       = @"RKLICURegexSubjectRange";
NSString * const RKLICURegexSubjectStringErrorKey      = @"RKLICURegexSubjectString";

#ifndef REGEXKITLITE_VERSION_MAJOR
@implementation NSString (EntireRange)

- (NSRange)stringRange
{
    return NSMakeRange(0, [self length]);
}

@end
#endif

@implementation NSString (RegexKitLite5)

#pragma mark - componentsSeparatedByRegex:

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern
{
    return [self componentsSeparatedByRegex:pattern options:RKLNoOptions matchingOptions:0 range:NSMakeRange(0, [self length]) error:nil];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern range:(NSRange)range
{
    return [self componentsSeparatedByRegex:pattern options:RKLNoOptions matchingOptions:0 range:range error:nil];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error
{
    return [self componentsSeparatedByRegex:pattern options:options matchingOptions:0 range:range error:nil];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error
{
    // Repurposed from https://stackoverflow.com/a/9185677
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    NSArray *matchResults = [regex matchesInString:self options:matchingOptions range:range];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:matchResults.count];
    __block NSUInteger pos = 0;

    [regex enumerateMatchesInString:self options:matchingOptions range:range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange substrRange = NSMakeRange(pos, [result range].location - pos);
        [returnArray addObject:[self substringWithRange:substrRange]];
        pos = [result range].location + [result range].length;
    }];
    
    if (pos < range.length) {
        [returnArray addObject:[self substringFromIndex:pos]];
    }
    
    return returnArray;
}

#pragma mark - isMatchedByRegex:

- (BOOL)isMatchedByRegex:(NSString *)pattern
{
    return [self isMatchedByRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:NSMakeRange(0, [self length]) error:nil];
}

- (BOOL)isMatchedByRegex:(NSString *)pattern inRange:(NSRange)range
{
    return [self isMatchedByRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:range error:nil];
}

- (BOOL)isMatchedByRegex:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error
{
    return [self isMatchedByRegex:pattern options:options matchingOptions:0 inRange:range error:error];
}

- (BOOL)isMatchedByRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error;
{
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    __block NSUInteger numberOfMatches = 0;
    [regex enumerateMatchesInString:self options:matchingOptions range:range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        numberOfMatches++;
    }];

    return (numberOfMatches > 0);
}

#pragma mark - rangeOfRegex:

- (NSRange)rangeOfRegex:(NSString *)pattern
{
    return [self rangeOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:NSMakeRange(0, [self length]) capture:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSInteger)capture
{
    return [self rangeOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:NSMakeRange(0, [self length]) capture:capture error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern inRange:(NSRange)range
{
    return [self rangeOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:range capture:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error
{
    return [self rangeOfRegex:pattern options:options matchingOptions:0 inRange:range capture:capture error:error];
}

- (NSRange)rangeOfRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error
{
    NSCParameterAssert(capture >= 0);
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    NSMutableArray *matches = [NSMutableArray array];
    
    if ([self isMatchedByRegex:pattern options:options matchingOptions:matchingOptions inRange:range error:error]) {
        [regex enumerateMatchesInString:self options:matchingOptions range:range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [matches addObject:result];
        }];

        NSTextCheckingResult *firstResult = matches[0];
        return [firstResult rangeAtIndex:capture];
    }

    return NSMakeRange(NSNotFound, 0);
}

#pragma mark - stringByMatching:

- (NSString *)stringByMatching:(NSString *)pattern
{
    return [self stringByMatching:pattern options:RKLNoOptions matchingOptions:0 inRange:NSMakeRange(0, [self length]) capture:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern capture:(NSInteger)capture
{
    return [self stringByMatching:pattern options:RKLNoOptions matchingOptions:0 inRange:NSMakeRange(0, [self length]) capture:capture error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern inRange:(NSRange)range
{
    return [self stringByMatching:pattern options:RKLNoOptions matchingOptions:0 inRange:range capture:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern options:(RKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error
{
    return [self stringByMatching:pattern options:options matchingOptions:0 inRange:range capture:capture error:error];
}

- (NSString *)stringByMatching:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error
{
    NSCParameterAssert(capture >= 0);
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    __block NSTextCheckingResult *firstMatch = nil;
    
    [regex enumerateMatchesInString:self options:matchingOptions range:range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        firstMatch = result;
        *stop = YES;
    }];
    
    if (firstMatch) {
        NSString *result = [self substringWithRange:[firstMatch rangeAtIndex:capture]];
        return result;
    }
    
    return nil;
}

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:


- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withString:replacement options:RKLNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement range:(NSRange)searchRange
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withString:replacement options:RKLNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement options:(RKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withString:replacement options:options matchingOptions:0 range:searchRange error:error];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withString:(NSString *)replacement options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    NSMutableString *target = [self mutableCopy];
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.range.location != NSNotFound) {
            [target replaceCharactersInRange:match.range withString:replacement];
        }
    }
    
    return [target copy];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(^)(NSInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:pattern options:RKLNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:error];
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:range];
    NSMutableString *target = [NSMutableString stringWithString:self];
    BOOL stop = NO;
    
    if (![matches count]) {
        return [NSString stringWithString:self];
    }
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSInteger captureCount = (NSInteger)match.numberOfRanges;
        NSMutableArray *captures = [NSMutableArray array];
        NSRange rangeCaptures[captureCount];
        
        for (NSUInteger rangeIndex = 0; rangeIndex < captureCount; rangeIndex++) {
            NSRange subrange = [match rangeAtIndex:rangeIndex];
            rangeCaptures[rangeIndex] = subrange;

            if (subrange.location != NSNotFound) {
                [captures addObject:[self substringWithRange:subrange]];
            }
            else {
                [captures addObject:@""];
            }
        }
        
        rangeCaptures[captureCount] = NSMakeRange(NSNotFound, NSIntegerMax);
        NSString *replacement = block(captureCount, [captures copy], rangeCaptures, &stop);
        [target replaceCharactersInRange:match.range withString:replacement];
        
        if (stop == YES) {
            break;
        }
    }

    return [target copy];
}

#pragma mark - captureCount:

#pragma mark - isRegexValid

#pragma mark - componentsMatchedByRegex:

#pragma mark - captureComponentsMatchedByRegex:

#pragma mark - arrayOfCaptureComponentsMatchedByRegex:
// Eventually use this: https://gist.github.com/kamiro/3902122

#pragma mark - arrayOfDictionariesByMatchingRegex:

#pragma mark - dictionaryByMatchingRegex:

#pragma mark - enumerateStringsByMatchingRegex:usingBlock:

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

@end
