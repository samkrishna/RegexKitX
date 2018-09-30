//
//  RegexKitX.m
//  RegexKitX

/*
 Created by Sam Krishna on 6/12/17.
 Copyright © 2017 Sam Krishna. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Sam Krishna nor the names of RegexKitX's contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "RegexKitX.h"

#define RKX_EXPECTED(cond, expect) __builtin_expect((long)(cond), (expect))

static NSRange NSNotFoundRange = ((NSRange){.location = (NSUInteger)NSNotFound, .length = 0UL});

@implementation NSArray (RangeMechanics)
- (NSRange)rangeAtIndex:(NSUInteger)index
{
    return [self[index] rangeValue];
}
@end

@interface NSMutableArray (RangeMechanics)
- (void)addRange:(NSRange)range;
@end

@implementation NSMutableArray (RangeMechanics)
- (void)addRange:(NSRange)range
{
    [self addObject:[NSValue valueWithRange:range]];
}
@end

@interface NSTextCheckingResult (RangeMechanics)
@property (nonatomic, readonly, copy) NSArray<NSValue *> *ranges;
- (NSArray<NSString *> *)substringsFromString:(NSString *)string;
@end

@implementation NSTextCheckingResult (RangeMechanics)

- (NSArray<NSValue *> *)ranges
{
    NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:self.numberOfRanges];

    for (NSUInteger i = 0; i < self.numberOfRanges; i++) {
        [ranges addRange:[self rangeAtIndex:i]];
    }

    return [ranges copy];
}

- (NSArray<NSString *> *)substringsFromString:(NSString *)string
{
    NSMutableArray *substringArray = [NSMutableArray array];

    for (NSValue *subrange in self.ranges) {
        NSString *matchString = (subrange.rangeValue.location != NSNotFound) ? [string substringWithRange:subrange.rangeValue] : @"";
        [substringArray addObject:matchString];
    }

    return [substringArray copy];
}

@end

@implementation NSString (RangeMechanics)

- (NSRange)stringRange
{
    return ((NSRange){.location = 0UL, .length = self.length});
}

- (NSRange)rangeFromLocation:(NSUInteger)location
{
    NSUInteger deltaLength = self.length - location;
    return ((NSRange){.location = location, .length = deltaLength});
}

- (NSRange)rangeToLocation:(NSUInteger)location
{
    return ((NSRange){.location = 0UL, .length = location});
}

@end

@implementation NSString (RegexKitX)

#pragma mark - Caching Methods

+ (NSString *)cacheKeyForRegex:(NSString *)pattern options:(RKXRegexOptions)options
{
    NSString *key = [NSString stringWithFormat:@"%@_%lu", pattern, options];
    return key;
}

+ (NSRegularExpression *)cachedRegexForPattern:(NSString *)patten options:(RKXRegexOptions)options error:(NSError **)error
{
    NSString *patternKey = [NSString cacheKeyForRegex:patten options:options];
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSRegularExpression *regex = dictionary[patternKey];
    
    if (!regex) {
        NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
        regex = [NSRegularExpression regularExpressionWithPattern:patten options:regexOptions error:error];
        if (!regex) { return nil; }
        dictionary[patternKey] = regex;
    }
    
    return regex;
}

#pragma mark - DRY Utility Methods

- (NSArray *)_matchesForRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) { return nil; }
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    return matches;
}

#pragma mark - componentsSeparatedByRegex:

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern
{
    return [self componentsSeparatedByRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self componentsSeparatedByRegex:pattern range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self componentsSeparatedByRegex:pattern range:searchRange options:options matchOptions:0 error:error];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return @[ self ]; }
    NSMutableArray *components = [NSMutableArray array];
    NSUInteger pos = 0;

    for (NSTextCheckingResult *match in matches) {
        NSRange subrange = NSMakeRange(pos, match.range.location - pos);
        [components addObject:[self substringWithRange:subrange]];
        pos = match.range.location + match.range.length;
    }

    if (pos < searchRange.length) {
        [components addObject:[self substringFromIndex:pos]];
    }
    
    return [components copy];
}

#pragma mark - matchesRegex:

- (BOOL)matchesRegex:(NSString *)pattern
{
    return [self matchesRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (BOOL)matchesRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self matchesRegex:pattern range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (BOOL)matchesRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self matchesRegex:pattern range:searchRange options:options matchOptions:0 error:error];
}

- (BOOL)matchesRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NO; }
    return YES;
}

#pragma mark - rangeOfRegex:

- (NSRange)rangeOfRegex:(NSString *)pattern
{
    return [self rangeOfRegex:pattern range:self.stringRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self rangeOfRegex:pattern range:self.stringRange capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self rangeOfRegex:pattern range:searchRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self rangeOfRegex:pattern range:searchRange capture:capture options:options matchOptions:0 error:error];
}

- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NSNotFoundRange; }
    NSTextCheckingResult *match = [matches firstObject];
    return [match rangeAtIndex:capture];
}

#pragma mark - rangesOfRegex:

- (NSArray *)rangesOfRegex:(NSString *)pattern
{
    return [self rangesOfRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self rangesOfRegex:pattern range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self rangesOfRegex:pattern range:searchRange options:options matchOptions:0 error:error];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return @[]; }
    NSMutableArray *ranges = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        [ranges addObjectsFromArray:match.ranges];
    }

    return [ranges copy];
}

#pragma mark - stringByMatchingRegex:

- (NSString *)stringByMatchingRegex:(NSString *)pattern
{
    return [self stringByMatchingRegex:pattern range:self.stringRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatchingRegex:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self stringByMatchingRegex:pattern range:self.stringRange capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self stringByMatchingRegex:pattern range:searchRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self stringByMatchingRegex:pattern range:searchRange capture:capture options:options matchOptions:0 error:error];
}

- (NSString *)stringByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRange range = [self rangeOfRegex:pattern range:searchRange capture:capture options:options matchOptions:matchOptions error:error];
    if (NSEqualRanges(range, NSNotFoundRange)) { return nil; }
    NSString *result = [self substringWithRange:range];
    return result;
}

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withTemplate:template range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withTemplate:template range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withTemplate:template range:searchRange options:options matchOptions:0 error:error];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) { return nil; }
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    if (!matches.count) { return [self substringWithRange:searchRange]; }
    NSMutableString *target = [self mutableCopy];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *swap = [regex replacementStringForResult:match inString:self offset:0 template:template];
        [target replaceCharactersInRange:match.range withString:swap];
    }
    
    return [target copy];
}

#pragma mark - captureCount:

- (NSUInteger)captureCount
{
    NSError *error;
    return [self captureCountWithOptions:RKXNoOptions error:&error];
}

- (NSUInteger)captureCountWithOptions:(RKXRegexOptions)options error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:self options:options error:error];
    if (!regex) { return NSNotFound; }
    return regex.numberOfCaptureGroups;
}

#pragma mark - isRegexValid

- (BOOL)isRegexValid
{
    return [self isRegexValidWithOptions:RKXNoOptions error:NULL];
}

- (BOOL)isRegexValidWithOptions:(RKXRegexOptions)options error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:self options:options error:error];
    if (!regex) { return NO; }
    return YES;
}

#pragma mark - componentsMatchedByRegex:

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern
{
    return [self componentsMatchedByRegex:pattern range:self.stringRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self componentsMatchedByRegex:pattern range:self.stringRange capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self componentsMatchedByRegex:pattern range:searchRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self componentsMatchedByRegex:pattern range:searchRange capture:capture options:options matchOptions:0 error:error];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return @[]; }
    NSMutableArray *captures = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:capture];
        NSString *matchString = (matchRange.location != NSNotFound) ? [self substringWithRange:matchRange] : @"";
        [captures addObject:matchString];
    }

    return [captures copy];
}

#pragma mark - captureComponentsMatchedByRegex:

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern
{
    return [self captureComponentsMatchedByRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self captureComponentsMatchedByRegex:pattern range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self captureComponentsMatchedByRegex:pattern range:searchRange options:options matchOptions:0 error:error];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return @[]; }
    NSTextCheckingResult *firstMatch = [matches firstObject];
    return [firstMatch substringsFromString:self];
}

#pragma mark - arrayOfCaptureComponentsMatchedByRegex:

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern range:searchRange options:options matchOptions:0 error:error];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return @[]; }
    NSMutableArray *matchCaptures = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        [matchCaptures addObject:[match substringsFromString:self]];
    }
    
    return [matchCaptures copy];
}

#pragma mark - arrayOfDictionariesByMatchingRegex:

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern range:self.stringRange withKeys:captureKeys forCaptures:captureKeyIndexes options:0 matchOptions:0 error:NULL];
    va_end(varArgsList);
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern range:searchRange withKeys:captureKeys forCaptures:captureKeyIndexes options:0 matchOptions:0 error:NULL];
    va_end(varArgsList);
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern range:searchRange withKeys:captureKeys forCaptures:captureKeyIndexes options:options matchOptions:0 error:error];
    va_end(varArgsList);
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern range:searchRange withKeys:captureKeys forCaptures:captureKeyIndexes options:options matchOptions:matchOptions error:error];
    va_end(varArgsList);
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self arrayOfDictionariesByMatchingRegex:pattern range:searchRange withKeys:keys forCaptures:captures options:options matchOptions:0 error:error];
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError * __autoreleasing *)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) { return nil; }
    NSMutableArray *dictArray = [NSMutableArray array];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [self enumerateStringsMatchedByRegex:pattern range:searchRange options:options matchOptions:matchOptions enumerationOptions:0 error:error usingBlock:^(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL *const stop) {
        NSString *mainString = capturedStrings[0];
        NSDictionary *dict = [mainString dictionaryByMatchingRegex:pattern range:mainString.stringRange withKeys:keys forCaptures:captures options:options matchOptions:matchOptions error:error];
        [dictArray addObject:dict];
    }];
#pragma clang diagnostic pop

    return [dictArray copy];
}

#pragma mark - dictionaryByMatchingRegex:

- (NSArray *)_keysForVarArgsList:(va_list)varArgsList withFirstKey:(id)firstKey indexes:(NSArray **)captureIndexes
{
    NSMutableArray *captureKeys = [NSMutableArray arrayWithCapacity:64];
    NSMutableArray *captureKeyIndexes = [NSMutableArray arrayWithCapacity:64];
    NSUInteger captureKeysCount = 0UL;
    
    if (varArgsList != NULL) {
        while (captureKeysCount < 32UL) {
            id  thisCaptureKey = (captureKeysCount == 0) ? firstKey : va_arg(varArgsList, id);
            if (RKX_EXPECTED(thisCaptureKey == NULL, 0L)) { break; }
            int thisCaptureKeyIndex = va_arg(varArgsList, int);
            [captureKeys addObject:thisCaptureKey];
            [captureKeyIndexes addObject:@(thisCaptureKeyIndex)];
            captureKeysCount++;
        }
    }
    
    *captureIndexes = [captureKeyIndexes copy];
    return [captureKeys copy];
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern range:self.stringRange withKeys:captureKeys forCaptures:captureKeyIndexes options:RKXNoOptions matchOptions:0 error:NULL ];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *keys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern  range:searchRange withKeys:keys forCaptures:captureKeyIndexes options:RKXNoOptions matchOptions:0 error:NULL];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern range:searchRange withKeys:captureKeys forCaptures:captureKeyIndexes options:options matchOptions:0 error:error];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern range:searchRange withKeys:captureKeys forCaptures:captureKeyIndexes options:options matchOptions:matchOptions error:error];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self dictionaryByMatchingRegex:pattern range:searchRange withKeys:keys forCaptures:captures options:options matchOptions:0 error:error];
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray<NSNumber *> *)captures options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) { return nil; }
    NSUInteger count = keys.count;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (NSUInteger i = 0; i < count; i++) {
        id key = keys[i];
        NSUInteger capture = captures[i].unsignedIntegerValue;
        NSRange captureRange = [self rangeOfRegex:pattern range:searchRange capture:capture options:options matchOptions:matchOptions error:error];
        dict[key] = (captureRange.length > 0) ? [self substringWithRange:captureRange] : @"";
    }
    
    return [dict copy];
}

#pragma mark - enumerateStringsMatchedByRegex:usingBlock:

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 enumerationOptions:0 error:NULL usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:pattern range:searchRange options:options matchOptions:0 enumerationOptions:0 error:error usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions enumerationOptions:(NSEnumerationOptions)enumOpts error:(NSError **)error usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NO; }
    __block BOOL blockStop = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [matches enumerateObjectsWithOptions:enumOpts usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL * _Nonnull stop) {
        block([match substringsFromString:self], match.ranges, &blockStop);
        *stop = blockStop;
    }];
#pragma clang diagnostic pop

    return YES;
}

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 enumerationOptions:0 error:NULL usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:pattern range:searchRange options:options matchOptions:0 enumerationOptions:0 error:error usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions enumerationOptions:(NSEnumerationOptions)enumOpts error:(NSError **)error usingBlock:(void (^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    NSString *target = [self substringWithRange:searchRange];
    NSRange targetRange = target.stringRange;
    NSArray *matches = [target _matchesForRegex:pattern range:targetRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NO; }
    NSArray *strings = [target componentsSeparatedByRegex:pattern range:targetRange options:options matchOptions:matchOptions error:error];
    NSUInteger lastStringIndex = [strings indexOfObject:strings.lastObject];
    __block NSRange remainderRange = targetRange;
    __block BOOL blockStop = NO;

    [strings enumerateObjectsWithOptions:enumOpts usingBlock:^(NSString *topString, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange topStringRange = [target rangeOfString:topString options:NSBackwardsSearch range:remainderRange];
        NSTextCheckingResult *match = (idx < lastStringIndex) ? matches[idx] : nil;

        if (match) {
            NSMutableArray *captures = [NSMutableArray array];
            NSMutableArray<NSValue *> *rangeCaptures = [@[[NSValue valueWithRange:topStringRange]] mutableCopy];
            [captures addObject:topString];
            [rangeCaptures addObjectsFromArray:match.ranges];
            [captures addObjectsFromArray:[match substringsFromString:self]];
            remainderRange = rangeCaptures.lastObject.rangeValue;
            remainderRange = (enumOpts == 0) ? [target rangeFromLocation:remainderRange.location] : [target rangeToLocation:remainderRange.location];
            block([captures copy], [rangeCaptures copy], &blockStop);
        }
        else {
            NSRange lastRange = [target rangeOfString:topString options:NSBackwardsSearch range:remainderRange];
            block(@[ topString ], @[ [NSValue valueWithRange:lastRange] ], &blockStop);
        }

        if (blockStop) { *stop = YES; }
    }];

    return YES;
}

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:pattern range:searchRange options:options matchOptions:0 error:error usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches) { return nil; }
    if (!matches.count) { return [self substringWithRange:searchRange]; }
    NSMutableString *target = [self mutableCopy];
    BOOL stop = NO;
    
    if (!matches.count) {
        return [NSString stringWithString:self];
    }
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *swap = block([match substringsFromString:self], match.ranges, &stop);
        [target replaceCharactersInRange:match.range withString:swap];
        if (stop) { break; }
    }
    
    return [target copy];
}

@end

@implementation NSMutableString (RegexKitX)

#pragma mark - replaceOccurrencesOfRegex:withString:

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template range:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template range:searchRange options:options matchOptions:0 error:error];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) { return NSNotFound; }
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NSNotFound; }
    NSUInteger count = 0;
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *swap = [regex replacementStringForResult:match inString:self offset:0 template:template];
        [self replaceCharactersInRange:match.range withString:swap];
        count++;
    }
    
    return count;
}

#pragma mark - replaceOccurrencesOfRegex:usingBlock:

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:pattern range:self.stringRange options:RKXNoOptions matchOptions:0 error:NULL usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:pattern range:searchRange options:options matchOptions:0 error:error usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error usingBlock:(NSString *(^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, volatile BOOL * const stop))block
{
    NSArray *matches = [self _matchesForRegex:pattern range:searchRange options:options matchOptions:matchOptions error:error];
    if (!matches || matches.count == 0) { return NSNotFound; }
    NSUInteger count = 0;
    BOOL stop = NO;
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *replacement = block([match substringsFromString:self], match.ranges, &stop);
        [self replaceCharactersInRange:match.range withString:replacement];
        count++;
        if (stop) { break; }
    }
    
    return count;
}

@end
