//
//  RegexKitX.m
//  RegexKitX
//
//  Created by Sam Krishna on 6/12/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RegexKitX.h"

#define RKX_EXPECTED(cond, expect)       __builtin_expect((long)(cond), (expect))

static NSRange NSNotFoundRange = ((NSRange){.location = (NSUInteger)NSNotFound, .length = 0UL});
static NSRange NSTerminationRange = ((NSRange){.location = (NSUInteger)NSNotFound, .length = NSUIntegerMax});

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

+ (NSString *)cacheKeyForRegex:(NSString *)regexPattern options:(RKXRegexOptions)options
{
    NSString *key = [NSString stringWithFormat:@"%@_%lu", regexPattern, options];
    return key;
}

+ (NSRegularExpression *)cachedRegexForPattern:(NSString *)patten options:(RKXRegexOptions)options error:(NSError **)error
{
    NSString *regexKey = [NSString cacheKeyForRegex:patten options:options];
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSRegularExpression *regex = dictionary[regexKey];
    
    if (!regex) {
        NSRegularExpressionOptions regexOptions = (NSRegularExpressionOptions)options;
        regex = [NSRegularExpression regularExpressionWithPattern:patten options:regexOptions error:error];
        if (!regex) return nil;
        dictionary[regexKey] = regex;
    }
    
    return regex;
}

#pragma mark - componentsSeparatedByRegex:

- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern
{
    return [self componentsSeparatedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern range:(NSRange)searchRange
{
    return [self componentsSeparatedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self componentsSeparatedByRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error];
}

- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    // Repurposed from https://stackoverflow.com/a/9185677
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
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

#pragma mark - isMatchedByRegex:

- (BOOL)isMatchedByRegex:(NSString *)regexPattern
{
    return [self isMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL];
}

- (BOOL)isMatchedByRegex:(NSString *)regexPattern inRange:(NSRange)searchRange
{
    return [self isMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:searchRange error:NULL];
}

- (BOOL)isMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error
{
    return [self isMatchedByRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error];
}

- (BOOL)isMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return NO;
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:self options:matchingOptions range:searchRange];

    return (firstMatch != nil);
}

#pragma mark - rangeOfRegex:

- (NSRange)rangeOfRegex:(NSString *)regexPattern
{
    return [self rangeOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] capture:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)regexPattern capture:(NSUInteger)capture
{
    return [self rangeOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] capture:capture error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)regexPattern inRange:(NSRange)searchRange
{
    return [self rangeOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:searchRange capture:0 error:NULL];
}

- (NSRange)rangeOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    return [self rangeOfRegex:regexPattern options:options matchingOptions:0 inRange:searchRange capture:capture error:error];
}

- (NSRange)rangeOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return NSNotFoundRange;
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:self options:matchingOptions range:searchRange];
    if (!firstMatch) return NSNotFoundRange;

    return [firstMatch rangeAtIndex:capture];
}

#pragma mark - rangesOfRegex:

- (NSArray *)rangesOfRegex:(NSString *)regexPattern
{
    return [self rangesOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)regexPattern inRange:(NSRange)searchRange
{
    return [self rangesOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:searchRange error:NULL];
}

- (NSArray *)rangesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error
{
    return [self rangesOfRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error];
}

- (NSArray *)rangesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return @[];
    NSMutableArray *ranges = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        for (NSUInteger i = 0; i < match.numberOfRanges; i++) {
            NSRange matchRange = [match rangeAtIndex:i];
            [ranges addObject:[NSValue valueWithRange:matchRange]];
        }
    }

    return [ranges copy];
}

#pragma mark - stringByMatching:

- (NSString *)stringByMatching:(NSString *)regexPattern
{
    return [self stringByMatching:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] capture:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)regexPattern capture:(NSUInteger)capture
{
    return [self stringByMatching:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] capture:capture error:NULL];
}

- (NSString *)stringByMatching:(NSString *)regexPattern inRange:(NSRange)searchRange
{
    return [self stringByMatching:regexPattern options:RKXNoOptions matchingOptions:0 inRange:searchRange capture:0 error:NULL];
}

- (NSString *)stringByMatching:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    return [self stringByMatching:regexPattern options:options matchingOptions:0 inRange:searchRange capture:capture error:error];
}

- (NSString *)stringByMatching:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    NSRange range = [self rangeOfRegex:regexPattern options:options matchingOptions:matchingOptions inRange:searchRange capture:capture error:error];
    if (NSEqualRanges(range, NSNotFoundRange)) return nil;
    NSString *result = [self substringWithRange:range];

    return result;
}

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement
{
    return [self stringByReplacingOccurrencesOfRegex:regexPattern withString:replacement options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement range:(NSRange)searchRange
{
    return [self stringByReplacingOccurrencesOfRegex:regexPattern withString:replacement options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self stringByReplacingOccurrencesOfRegex:regexPattern withString:replacement options:options matchingOptions:0 range:searchRange error:error];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return [self substringWithRange:searchRange];
    NSMutableString *target = [self mutableCopy];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [target replaceCharactersInRange:match.range withString:replacement];
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

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern
{
    return [self componentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] capture:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern capture:(NSUInteger)capture
{
    return [self componentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] capture:capture error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)searchRange
{
    return [self componentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange capture:0 error:NULL];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    return [self componentsMatchedByRegex:regexPattern options:options matchingOptions:0 range:searchRange capture:capture error:error];
}

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
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

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern
{
    return [self captureComponentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)searchRange
{
    return [self captureComponentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self captureComponentsMatchedByRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error];
}

- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
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

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern
{
    return [self arrayOfCaptureComponentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)searchRange
{
    return [self arrayOfCaptureComponentsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self arrayOfCaptureComponentsMatchedByRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error];
}

- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
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

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    
    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSArray *dictArray = [self arrayOfDictionariesByMatchingRegex:regexPattern options:options matchingOptions:matchingOptions range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);

    return dictArray;
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    return [self arrayOfDictionariesByMatchingRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error withKeys:keys forCaptures:captures];
}

- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError * __autoreleasing *)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSMutableArray *dictArray = [NSMutableArray array];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [self enumerateStringsMatchedByRegex:regexPattern options:options matchingOptions:matchingOptions inRange:searchRange error:error enumerationOptions:0 usingBlock:^(NSUInteger captureCount, NSArray *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString *mainString = capturedStrings[0];
        NSDictionary *dict = [mainString dictionaryByMatchingRegex:regexPattern options:options matchingOptions:matchingOptions range:[mainString stringRange] error:error withKeys:keys forCaptures:captures];
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

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *keys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:regexPattern options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL withKeys:keys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list varArgsList;
    va_start(varArgsList, firstKey);
    NSArray *captureKeyIndexes;
    NSArray *captureKeys = [self _keysForVarArgsList:varArgsList withFirstKey:firstKey indexes:&captureKeyIndexes];
    NSDictionary *dict = [self dictionaryByMatchingRegex:regexPattern options:options matchingOptions:matchingOptions range:searchRange error:error withKeys:captureKeys forCaptures:captureKeyIndexes];
    va_end(varArgsList);
    return dict;
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    return [self dictionaryByMatchingRegex:regexPattern options:options matchingOptions:0 range:searchRange error:error withKeys:keys forCaptures:captures];
}

- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return nil;
    NSUInteger count = [keys count];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];

    for (NSUInteger i = 0; i < count; i++) {
        id key = keys[i];
        NSUInteger capture = [captures[i] unsignedIntegerValue];
        NSRange captureRange = [self rangeOfRegex:regexPattern options:options matchingOptions:matchingOptions inRange:searchRange capture:capture error:error];
        dict[key] = (captureRange.length > 0) ? [self substringWithRange:captureRange] : @"";
    }
    
    return [dict copy];
}

#pragma mark - enumerateStringsMatchedByRegex:usingBlock:

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsMatchedByRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
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

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self enumerateStringsSeparatedByRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error enumerationOptions:0 usingBlock:block];
}

- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return NO;
    NSString *target = [self substringWithRange:searchRange];
    NSRange targetRange = [target stringRange];
    NSArray *matches = [regex matchesInString:target options:matchingOptions range:targetRange];
    if (![matches count]) return NO;
    NSArray *strings = [target componentsSeparatedByRegex:regexPattern options:options matchingOptions:matchingOptions range:targetRange error:error];
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

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self stringByReplacingOccurrencesOfRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error usingBlock:block];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
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

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement
{
    return [self replaceOccurrencesOfRegex:regexPattern withString:replacement options:RKXNoOptions matchingOptions:0 range:[self stringRange] error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement range:(NSRange)searchRange
{
    return [self replaceOccurrencesOfRegex:regexPattern withString:replacement options:RKXNoOptions matchingOptions:0 range:searchRange error:NULL];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKXRegexOptions)options range:(NSRange)searchRange error:(NSError **)error
{
    return [self replaceOccurrencesOfRegex:regexPattern withString:replacement options:options matchingOptions:0 range:searchRange error:error];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
    if (!regex) return NSNotFound;
    NSArray *matches = [regex matchesInString:self options:matchingOptions range:searchRange];
    if (![matches count]) return NSNotFound;
    NSUInteger count = 0;
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [self replaceCharactersInRange:match.range withString:replacement];
        count++;
    }
    
    return count;
}

#pragma mark - replaceOccurrencesOfRegex:usingBlock:

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:regexPattern options:RKXNoOptions matchingOptions:0 inRange:[self stringRange] error:NULL usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    return [self replaceOccurrencesOfRegex:regexPattern options:options matchingOptions:0 inRange:searchRange error:error usingBlock:block];
}

- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern options:(RKXRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block
{
    NSRegularExpression *regex = [NSString cachedRegexForPattern:regexPattern options:options error:error];
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