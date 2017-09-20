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
 * Neither the name of the Sam Krishna nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "RegexKitX.h"

#define RKX_EXPECTED(cond, expect)       __builtin_expect((long)(cond), (expect))

static NSRange NSNotFoundRange = ((NSRange){.location = (NSUInteger)NSNotFound, .length = 0UL});

@interface NSMutableArray (RangeMechanics)
- (void)addRange:(NSRange)range;
@end

@implementation NSMutableArray (RangeMechanics)
- (void)addRange:(NSRange)range
{
    [self addObject:[NSValue valueWithRange:range]];
}
@end


@implementation NSArray (RangeMechanics)
- (NSRange)rangeAtIndex:(NSUInteger)index
{
    return [self[index] rangeValue];
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
        if (!regex) return nil;
        dictionary[patternKey] = regex;
    }
    
    return regex;
}

#pragma mark - componentsSeparatedByRegex:

- (NSArray *)componentsSeparatedByRegex:(NSString *)pattern
{
    return [self componentsSeparatedByRegex:pattern range:[self stringRange] options:RKXNoOptions matchOptions:0 error:NULL];
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
    // Repurposed from https://stackoverflow.com/a/9185677
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    if (![matches count]) return @[ self ];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:matches.count];
    NSUInteger pos = 0;

    for (NSTextCheckingResult *match in matches) {
        NSRange subrange = NSMakeRange(pos, match.range.location - pos);
        [returnArray addObject:[self substringWithRange:subrange]];
        pos = match.range.location + match.range.length;
    }

    if (pos < searchRange.length) {
        [returnArray addObject:[self substringFromIndex:pos]];
    }
    
    return [returnArray copy];
}

#pragma mark - matchesRegex:

- (BOOL)matchesRegex:(NSString *)pattern
{
    return [self matchesRegex:pattern inRange:[self stringRange] options:RKXNoOptions matchOptions:0 error:NULL];
}

- (BOOL)matchesRegex:(NSString *)pattern inRange:(NSRange)searchRange
{
    return [self matchesRegex:pattern inRange:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (BOOL)matchesRegex:(NSString *)pattern inRange:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self matchesRegex:pattern inRange:searchRange options:options matchOptions:0 error:error];
}

- (BOOL)matchesRegex:(NSString *)pattern inRange:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NO;
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:self options:(NSMatchingOptions)matchOptions range:searchRange];

    return (firstMatch != nil);
}

#pragma mark - rangeOfRegex:

- (NSRange)rangeOfRegex:(NSString *)pattern
{
    return [self rangeOfRegex:pattern inRange:[self stringRange] capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self rangeOfRegex:pattern inRange:[self stringRange] capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern inRange:(NSRange)searchRange
{
    return [self rangeOfRegex:pattern inRange:searchRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)pattern inRange:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self rangeOfRegex:pattern inRange:searchRange capture:capture options:options matchOptions:0 error:error];
}

- (NSRange)rangeOfRegex:(NSString *)pattern inRange:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NSNotFoundRange;
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSTextCheckingResult *match = [regex firstMatchInString:self options:matchOpts range:searchRange];
    if (!match) return NSNotFoundRange;

    return [match rangeAtIndex:capture];
}

#pragma mark - rangesOfRegex:

- (NSArray *)rangesOfRegex:(NSString *)pattern
{
    return [self rangesOfRegex:pattern inRange:[self stringRange] options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern inRange:(NSRange)searchRange
{
    return [self rangesOfRegex:pattern inRange:searchRange options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern inRange:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self rangesOfRegex:pattern inRange:searchRange options:options matchOptions:0 error:error];
}

- (NSArray *)rangesOfRegex:(NSString *)pattern inRange:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    if (![matches count]) return @[];
    NSMutableArray *ranges = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        for (NSUInteger i = 0; i < match.numberOfRanges; i++) {
            NSRange matchRange = [match rangeAtIndex:i];
            [ranges addRange:matchRange];
        }
    }

    return [ranges copy];
}

#pragma mark - stringByMatching:

- (NSString *)stringByMatching:(NSString *)pattern
{
    return [self stringByMatching:pattern inRange:[self stringRange] capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self stringByMatching:pattern inRange:[self stringRange] capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern inRange:(NSRange)searchRange
{
    return [self stringByMatching:pattern inRange:searchRange capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)pattern inRange:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error
{
    return [self stringByMatching:pattern inRange:searchRange capture:capture options:options matchOptions:0 error:error];
}

- (NSString *)stringByMatching:(NSString *)pattern inRange:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error
{
    NSRange range = [self rangeOfRegex:pattern inRange:searchRange capture:capture options:options matchOptions:matchOptions error:error];
    if (NSEqualRanges(range, NSNotFoundRange)) return nil;
    NSString *result = [self substringWithRange:range];

    return result;
}

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template
{
    return [self stringByReplacingOccurrencesOfRegex:pattern withTemplate:template range:[self stringRange] options:RKXNoOptions matchOptions:0 error:NULL];
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
    if (!regex) return nil;
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    if (![matches count]) return [self substringWithRange:searchRange];
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
    if (!regex) return NSNotFound;

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
    if (!regex) return NO;

    return YES;
}

#pragma mark - componentsMatchedByRegex:

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern
{
    return [self componentsMatchedByRegex:pattern range:[self stringRange] capture:0 options:RKXNoOptions matchOptions:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture
{
    return [self componentsMatchedByRegex:pattern range:[self stringRange] capture:capture options:RKXNoOptions matchOptions:0 error:NULL];
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
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSMatchingOptions matchOpts = (NSMatchingOptions)matchOptions;
    NSArray *matches = [regex matchesInString:self options:matchOpts range:searchRange];
    if (![matches count]) return @[];
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
    return [self captureComponentsMatchedByRegex:pattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self captureComponentsMatchedByRegex:pattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self captureComponentsMatchedByRegex:pattern options:options matchingOptions:0 range:searchRange error:error];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:self options:matchingOptions range:searchRange];
    if (!firstMatch) return @[];
    NSMutableArray *captureArray = [NSMutableArray arrayWithCapacity:firstMatch.numberOfRanges];
    
    for (NSUInteger i = 0; i < firstMatch.numberOfRanges; i++) {
        NSRange matchRange = [firstMatch rangeAtIndex:i];
        NSString *matchString = (matchRange.location != NSNotFound) ? [self substringWithRange:matchRange] : @"";
        [captureArray addObject:matchString];
    }
    
    return [captureArray copy];
}

#pragma mark - arrayOfCaptureComponentsMatchedByRegex:

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self arrayOfCaptureComponentsMatchedByRegex:pattern options:options matchingOptions:0 range:searchRange error:error];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return @[];
    NSMutableArray *matchCaptures = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        NSMutableArray *captureArray = [NSMutableArray arrayWithCapacity:match.numberOfRanges];
        
        for (NSUInteger i = 0; i < match.numberOfRanges; i++) {
            NSRange matchRange = [match rangeAtIndex:i];
            NSString *matchString = (matchRange.location != NSNotFound) ? [self substringWithRange:matchRange] : @"";
            [captureArray addObject:matchString];
        }
        
        [matchCaptures addObject:[captureArray copy]];
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
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern options:options matchingOptions:0 range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:pattern options:options matchingOptions:matchingOptions range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);

    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    return [self arrayOfDictionariesByMatchingRegex:pattern options:options matchingOptions:0 range:searchRange error:error withKeys:keys forCaptures:captures];
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError * __autoreleasing *)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSMutableArray *dictArray = [NSMutableArray array];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [self enumerateStringsMatchedByRegex:pattern options:options matchingOptions:matchingOptions inRange:searchRange error:error enumerationOptions:0 usingBlock:^(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *mainString = capturedStrings[0];
        NSDictionary *dict = [mainString dictionaryByMatchingRegex:pattern options:options matchingOptions:matchingOptions range:[mainString stringRange] error:error withKeys:keys forCaptures:captures];
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
        while (captureKeysCount < 62UL) {
            id  thisCaptureKey = (captureKeysCount == 0) ? firstKey : va_arg(varArgsList, id);
            if (RKX_EXPECTED(thisCaptureKey == NULL, 0L)) break;
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
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *keys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL withKeys:keys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern options:options matchingOptions:0 range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:pattern options:options matchingOptions:matchingOptions range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    return [self dictionaryByMatchingRegex:pattern options:options matchingOptions:0 range:searchRange error:error withKeys:keys forCaptures:captures];
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSUInteger count = [keys count];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];

    for (NSUInteger i = 0; i < count; i++) {
        id key = keys[i];
        NSUInteger capture = [captures[i] unsignedIntegerValue];
        NSRange captureRange = [self rangeOfRegex:pattern options:options matchingOptions:matchingOptions inRange:searchRange capture:capture error:error];
        dict[key] = (captureRange.length > 0) ? [self substringWithRange:captureRange] : @"";
    }
    
    return [dict copy];
}

#pragma mark - enumerateStringsMatchedByRegex:usingBlock:

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:pattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:pattern options:options matchingOptions:0 inRange:searchRange error:error enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NO;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return NO;
    __block BOOL blockStop = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [matches enumerateObjectsWithOptions:enumOpts usingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger captureCount = match.numberOfRanges;
        NSMutableArray *captures = [NSMutableArray array];
        NSRange rangeCaptures[captureCount];
        
        for (NSUInteger rangeIndex = 0; rangeIndex < captureCount; rangeIndex++) {
            NSRange subrange = [match rangeAtIndex:rangeIndex];
            rangeCaptures[rangeIndex] = subrange;
            NSString *substring = (subrange.location != NSNotFound) ? [self substringWithRange:subrange] : @"";
            [captures addObject:substring];
        }
        
        rangeCaptures[captureCount] = NSTerminationRange;
        block(captureCount, [captures copy], rangeCaptures, &blockStop);
        *stop = blockStop;
    }];
#pragma clang diagnostic pop

    return YES;
}

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:pattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:pattern options:options matchingOptions:0 inRange:searchRange error:error enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NO;
    NSString *target = [self substringWithRange:searchRange];
    NSRange targetRange = [target stringRange];
    NSArray *matches = [regex matchesInString:target options:matchingOptions range:targetRange];
    if (![matches count]) return NO;
    NSArray *strings = [target componentsSeparatedByRegex:pattern options:options matchingOptions:matchingOptions range:targetRange error:error];
    NSUInteger lastStringIndex = [strings indexOfObject:[strings lastObject]];
    __block NSRange remainderRange = targetRange;
    __block BOOL blockStop = NO;

    [strings enumerateObjectsWithOptions:enumOpts usingBlock:^(NSString *topString, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange topStringRange = [target rangeOfString:topString options:NSBackwardsSearch range:remainderRange];
        NSTextCheckingResult *match = (idx < lastStringIndex) ? matches[idx] : nil;

        if (match) {
            NSUInteger captureCount = match.numberOfRanges;
            NSMutableArray *captures = [NSMutableArray array];
            NSRange rangeCaptures[captureCount + 1];
            rangeCaptures[0] = topStringRange;
            [captures addObject:topString];

            for (NSUInteger rangeIndex = 0; rangeIndex < captureCount; rangeIndex++) {
                NSRange subrange = [match rangeAtIndex:rangeIndex];
                rangeCaptures[rangeIndex + 1] = subrange;
                NSString *substring = (subrange.location != NSNotFound) ? [target substringWithRange:subrange] : @"";
                [captures addObject:substring];
            }

            remainderRange = rangeCaptures[captureCount];
            remainderRange = (enumOpts == 0) ? [target rangeFromLocation:remainderRange.location] : [target rangeToLocation:remainderRange.location];
            rangeCaptures[captureCount + 1] = NSTerminationRange;
            block(captureCount + 1, [captures copy], rangeCaptures, &blockStop);
        }
        else {
            NSRange lastRange = [target rangeOfString:topString options:NSBackwardsSearch range:remainderRange];
            NSRange rangeCaptures[2] = { lastRange, NSTerminationRange };
            block(1, @[ topString ], rangeCaptures, &blockStop);
        }

        if (blockStop == YES) *stop = YES;
    }];

    return YES;
}

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:pattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:pattern options:options matchingOptions:0 inRange:searchRange error:error usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return [self substringWithRange:searchRange];
    NSMutableString *target = [NSMutableString stringWithString:self];
    BOOL stop = NO;
    
    if (![matches count]) {
        return [NSString stringWithString:self];
    }
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSUInteger captureCount = match.numberOfRanges;
        NSMutableArray *captures = [NSMutableArray array];
        NSRange rangeCaptures[captureCount];
        
        for (NSUInteger rangeIndex = 0; rangeIndex < captureCount; rangeIndex++) {
            NSRange subrange = [match rangeAtIndex:rangeIndex];
            rangeCaptures[rangeIndex] = subrange;
            NSString *substring = (subrange.location != NSNotFound) ? [self substringWithRange:subrange] : @"";
            [captures addObject:substring];
        }
        
        rangeCaptures[captureCount] = NSTerminationRange;
        NSString *replacement = block(captureCount, [captures copy], rangeCaptures, &stop);
        [target replaceCharactersInRange:match.range withString:replacement];
        if (stop == YES) break;
    }
    
    return [target copy];
}

@end

@implementation NSMutableString (RegexKitX)

#pragma mark - replaceOccurrencesOfRegex:withString:

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template range:(NSRange)searchRange
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self replaceOccurrencesOfRegex:pattern withTemplate:template options:options matchingOptions:0 range:searchRange error:error];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)template options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NSNotFound;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return NSNotFound;
    NSUInteger count = 0;
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSString *swap = [regex replacementStringForResult:match inString:self offset:0 template:template];
        [self replaceCharactersInRange:match.range withString:swap];
        count++;
    }
    
    return count;
}

#pragma mark - replaceOccurrencesOfRegex:usingBlock:

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:pattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:pattern options:options matchingOptions:0 inRange:searchRange error:error usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:pattern options:options error:error];
    if (!regex) return NSNotFound;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return NSNotFound;
    NSUInteger count = 0;
    BOOL stop = NO;
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSUInteger captureCount = match.numberOfRanges;
        NSMutableArray *captures = [NSMutableArray array];
        NSRange rangeCaptures[captureCount];
        
        for (NSUInteger rangeIndex = 0; rangeIndex < captureCount; rangeIndex++) {
            NSRange subrange = [match rangeAtIndex:rangeIndex];
            rangeCaptures[rangeIndex] = subrange;
            NSString *substring = (subrange.location != NSNotFound) ? [self substringWithRange:subrange] : @"";
            [captures addObject:substring];
        }
        
        rangeCaptures[captureCount] = NSTerminationRange;
        NSString *replacement = block(captureCount, [captures copy], rangeCaptures, &stop);
        [self replaceCharactersInRange:match.range withString:replacement];
        count++;
        if (stop == YES) break;
    }
    
    return count;
}

@end
