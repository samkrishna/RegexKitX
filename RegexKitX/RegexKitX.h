//
//  RegexKitX.h
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

@import Foundation;

/** The constants that define the regular expression options. */
typedef NS_OPTIONS(NSUInteger, RKXRegexOptions) {
    /** No regular expression options specified. */
    RKXNoOptions                = 0,
    /** Match letters in the pattern independent of case. */
    RKXCaseless                 = NSRegularExpressionCaseInsensitive,
    /** Ignore whitespace and #-prefixed comments in the pattern. */
    RKXIgnoreWhitespace         = NSRegularExpressionAllowCommentsAndWhitespace,
    /** Treat the entire pattern as a literal string. */
    RKXIgnoreMetacharacters     = NSRegularExpressionIgnoreMetacharacters,
    /** Allow . to match any character, including line separators. */
    RKXDotAll                   = NSRegularExpressionDotMatchesLineSeparators,
    /** Allow ^ and $ to match the start and end of lines. */
    RKXMultiline                = NSRegularExpressionAnchorsMatchLines,
    /** Treat only \n as a line separator (otherwise, all standard line separators are used). */
    RKXUseUnixLineSeparators    = NSRegularExpressionUseUnixLineSeparators,
    /** Use Unicode TR#29 to specify word boundaries (otherwise, traditional regular expression word boundaries are used). */
    RKXUnicodeWordBoundaries    = NSRegularExpressionUseUnicodeWordBoundaries
};

/**
 The matching options constants specify the reporting, completion and matching rules to the expression matching methods. These constants are used by all methods that search for, or replace values, using a regular expression.
 */
typedef NS_OPTIONS(NSUInteger, RKXMatchOptions) {
    /** Call the block periodically during long-running match operations. */
    RKXReportProgress          = NSMatchingReportProgress,
    /** Call the block once after the completion of any matching. */
    RKXReportCompletion        = NSMatchingReportCompletion,
    /** Limit matches to those at the start of the search range. */
    RKXAnchored                = NSMatchingAnchored,
    /** Allow matching to look beyond the bounds of the search range. */
    RKXWithTransparentBounds   = NSMatchingWithTransparentBounds,
    /** Prevent ^ and $ from automatically matching the beginning and end of the search range. */
    RKXWithoutAnchoringBounds  = NSMatchingWithoutAnchoringBounds
};

@interface NSString (RangeMechanics)

/**
 Returns the full NSRange of the receiver. Equivalent to @c NSMakeRange(0, self.length).
 */
@property (nonatomic, readonly) NSRange stringRange;

/**
 Returns the @c NSRange from @c location to the end of the receiver, in UTF-16 code units.
 */
- (NSRange)rangeFromLocation:(NSUInteger)location;

/**
 Returns the @c NSRange from @c 0 to the @c location, in UTF-16 code units.
 */
- (NSRange)rangeToLocation:(NSUInteger)location;
@end

#pragma mark -

@interface NSString (RegexKitX)

#pragma mark - arrayOfCaptureSubstringsMatchedByRegex:

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c pattern. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSArray which contains all the capture groups present in @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group. Will return an empty array if @c pattern fails to match.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSArray *> *)arrayOfCaptureSubstringsMatchedByRegex:(NSString *)pattern;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c pattern within @c searchRange. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSArray which contains all the capture groups present in @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group. Will return an empty array if @c pattern fails to match in @c searchRange.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSArray *> *)arrayOfCaptureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c pattern using @c options. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSArray which contains all the capture groups present in @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSArray *> *)arrayOfCaptureSubstringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSArray which contains all the capture groups present in @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSArray *> *)arrayOfCaptureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSArray which contains all the capture groups present in @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSArray *> *)arrayOfCaptureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - arrayOfDictionariesMatchedByRegex:

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of keys and captures.

 @param pattern A @c NSString containing a regular expression.
 @param firstKey The first key to add to each new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Will return an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern within @c searchRange. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of keys and captures.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param firstKey The first key to add to each new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Will return an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of keys and captures.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to each new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of keys and captures.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to each new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of @c keys and @c captures.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param keys A @c NSArray of @c NSString keys for the dictionaries.
 @param captures A @c NSArray of @c NSNumber capture group values for the dictionaries.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions. Each match result consists of a dictionary containing the matched substrings constructed from the specified set of @c keys and @c captures.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param keys A @c NSArray of @c NSString keys for the dictionaries.
 @param captures A @c NSArray of @c NSNumber capture group values for the dictionaries.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the matches from the receiver by @c pattern. Each match result consists of a @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSDictionary *> *)arrayOfDictionariesMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - captureCount:

/**
 Returns the number of captures that the regex receiver contains.

 @return The number of captures in the regex is returned, or @c 0 if the regex does not contain any captures.
 @return Returns @c NSNotFound if an error occurs.
 */
- (NSUInteger)captureCount;

/**
 Returns the number of captures that the regex receiver contains with @c options.

 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error The optional error parameter, if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return The number of captures in the regex is returned, or @c 0 if the regex does not contain any captures.
 @return Returns @c NSNotFound if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)captureCountWithOptions:(RKXRegexOptions)options error:(NSError **)error;

#pragma mark - captureSubstringsMatchedByRegex:

/**
 Returns an array containing the substrings matched by each capture group present in @c pattern for the first match of @c pattern in the receiver.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray containing the substrings matched by each capture group present in pattern for the first match of @c pattern. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Will return an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)captureSubstringsMatchedByRegex:(NSString *)pattern;

/**
 Returns an array containing the substrings matched by each capture group present in @c pattern for the first match of @c pattern within @c searchRange of the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSArray containing the substrings matched by each capture group present in pattern for the first match of @c pattern within @c searchRange of the receiver. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)captureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns an array containing the substrings matched by each capture group present in @c pattern for the first match of @c pattern within the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSArray containing the substrings matched by each capture group present in pattern for the first match of @c pattern within the receiver using @c options. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)captureSubstringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns an array containing the substrings matched by each capture group present in @c pattern for the first match of @c pattern within @c searchRange of the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings matched by each capture group present in pattern for the first match of @c pattern within @c searchRange of the receiver using @c options. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)captureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns an array containing the substrings matched by each capture group present in @c pattern for the first match of @c pattern within @c searchRange of the receiver using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings matched by each capture group present in pattern for the first match of @c pattern within @c searchRange of the receiver using @c options. Array index @c 0 represents all of the text matched by @c pattern and subsequent array indexes contain the text matched by their respective capture group.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)captureSubstringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - dictionaryMatchedByRegex:

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of @c pattern in the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param firstKey The first key to add to the new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Will return @c nil if an error occurs.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of @c pattern within @c searchRange of the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param firstKey The first key to add to the new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Will return @c nil if an error occurs.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of @c pattern within @c searchRange of the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty dictionary if @c pattern fails to match withing @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a NSDictionary containing the matches constructed from the specified set of keys and captures for the first match of @c pattern within @c searchRange of the receiver using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary, followed with the @c capture for @c firstKey, then a @c nil-terminated list of alternating keys and captures. Captures are specified using @c NSUInteger values.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty dictionary if @c pattern fails to match withing @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of @c keys and @c captures for the first match of @c pattern within @c searchRange of the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param keys A @c NSArray of @c NSString keys for the dictionary.
 @param captures A @c NSArray of @c NSNumber capture group values for the dictionary.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty dictionary if @c pattern fails to match withing @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of @c keys and @c captures for the first match of @c pattern within @c searchRange of the receiver using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param keys A @c NSArray of @c NSString keys for the dictionary.
 @param captures A @c NSArray of @c NSNumber capture group values for the dictionary.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 @return Returns an empty dictionary if @c pattern fails to match withing @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSDictionary<NSString *, NSString *> *)dictionaryMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange withKeys:(NSArray *)keys forCaptures:(NSArray *)captures options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - isMatchedByRegex:

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c pattern.

 @param pattern A @c NSString containing a regular expression.
 @return A @c BOOL value indicating whether or not the pattern has been matched in the receiver.
 @return Will return @c NO if @c pattern is invalid.
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c pattern within @c searchRange.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c BOOL value indicating whether or not the pattern has been matched in the receiver.
 @return Will return @c NO if @c pattern is invalid.
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c pattern using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c BOOL value indicating whether or not the @c pattern has been matched in the receiver.
 @return Will return @c NO if @c pattern is invalid.
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c pattern within @c searchRange using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c BOOL value indicating whether or not the @c pattern has been matched in the receiver.
 @return Will return @c NO if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c pattern within @c searchRange using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c BOOL value indicating whether or not the pattern has been matched in the receiver.
 @return Will return @c NO if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)isMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - isRegexValid

/**
 Returns a @c BOOL value that indicates whether the regular expression contained in the receiver is valid.
 @return Returns a @c YES if the regex is valid; @c NO otherwise.
 */
- (BOOL)isRegexValid;

/**
 Returns a @c BOOL value that indicates whether the regular expression contained in the receiver is valid using @c options.

 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error The optional error parameter, if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns a @c YES if the regex is valid; @c NO otherwise and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)isRegexValidWithOptions:(RKXRegexOptions)options error:(NSError **)error;

#pragma mark - rangeOfRegex:

/**
 Returns the range for the first match of @c pattern.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSRange structure giving the location and length of the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern;

/**
 Returns the range of capture number @c capture for the first match of @c pattern in the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param capture The matching range of the capture number from @c pattern to return. Use @c 0 for the entire range that @c pattern matched.
 @return A @c NSRange structure giving the location and length of the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSUInteger)capture;

/**
 Returns the range of capture number @c capture for the first match of @c pattern in the receiver.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored or return an @c NSRange of @c { NSNotFound, 0 },

 @param pattern A @c NSString containing a regular expression.
 @param captureName The matching range of the named capture group @c captureName in @c pattern. Use @c nil for the entire range that @c pattern matched or if @c capture is not @c NSNotFound.
 @return A @c NSRange structure giving the location and length of the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern namedCapture:(NSString *)captureName;

/**
 Returns the earliest range of either @c capture or @c captureName for the first match of @c pattern in the receiver.

 NOTE: If *BOTH* @c capture and @c captureName are used to find the first occurring range, the returned range will be the first range at the earliest starting location. In the event of a location tie, the returned range will be the range that has the LONGEST length.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored or return an @c NSRange of @c { NSNotFound, 0 },

 @param pattern A @c NSString containing a regular expression.
 @param capture The matching range of the capture number from @c pattern to return. Use @c 0 for the entire range that @c pattern matched.
 @param captureName The matching range of the named capture group @c captureName in @c pattern. Use @c nil for the entire range that @c pattern matched or if @c capture is not @c NSNotFound.
 @return A @c NSRange structure giving the location and length of the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern capture:(NSUInteger)capture namedCapture:(NSString *)captureName;

/**
 Returns the range for the first match of @c pattern within @c searchRange of the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c pattern. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns the range for the first match of @c pattern within the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSRange structure giving the location and length for the first match of @c pattern within the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern.
 @return Returns @c {NSNotFound, 0} if an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns the range of capture number @c capture for the first match of @c pattern within @c searchRange of the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The matching range of the capture number from @c pattern to return. Use @c 0 for the entire range that @c pattern matched.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern within @c searchRange.
 @return Returns @c {NSNotFound, 0} if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns the range of capture number @c capture or named capture group @c captureName for the first match of @c pattern within @c searchRange of the receiver using @c options and @c matchOptions.

 NOTE: If *BOTH* @c capture and @c captureName are used to find the first occurring range, the returned range will be the first range at the earliest starting location from the beginning of @c searchRange. In the event of a location tie, the returned range will be the range that has the LONGEST length.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored or return an @c NSRange of @c { NSNotFound, 0 },

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The matching range of the capture number from @c pattern to return. Use @c 0 for the entire range that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @param captureName The matching range of the named capture group @c captureName in @c pattern. Use @c nil for the entire range that @c pattern matched or if there are no named capture groups in @c pattern.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c pattern within @c searchRange of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c pattern within @c searchRange.
 @return Returns @c {NSNotFound, 0} if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSRange)rangeOfRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture namedCapture:(NSString *)captureName options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - rangesOfRegex:

/**
 Returns an @c NSArray of @c NSValue-wrapped @c NSRanges of all captures of @c pattern matched in the receiver.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray of @c NSValue-wrapped NSRanges of all captures matched by @c pattern.
 @return Will return @c nil if @c pattern is invalid.
 */
- (NSArray<NSValue *> *)rangesOfRegex:(NSString *)pattern;

/**
 Returns an @c NSArray of @c NSValue-wrapped @c NSRanges of all captures of @c pattern for all matches within @c searchRange of the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSArray of @c NSValue-wrapped @c NSRanges of all captures matched by @c pattern in @c searchRange.
 @return Will return @c nil if @c pattern is invalid.
 */
- (NSArray<NSValue *> *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns an @c NSArray of @c NSValue-wrapped @c NSRanges of all captures of @c pattern for all matches within the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSArray of @c NSValue-wrapped @c NSRanges of all captures matched by @c pattern in @c searchRange.
 @return Will return @c nil if @c pattern is invalid.
 */
- (NSArray<NSValue *> *)rangesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns a @c NSArray of @c NSValue-wrapped @c NSRanges of all captures of @c pattern for all matches within @c searchRange of the receiver using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray of @c NSValue-wrapped @c NSRanges of all captures matched by @c pattern in @c searchRange. Returns an empty array if there are no matches in the receiver for @c searchRange.
 @return Will return @c nil if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSValue *> *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns a @c NSArray of @c NSValue-wrapped @c NSRanges of all captures of @c pattern for all matches within @c searchRange of the receiver using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray of NSValue-wrapped NSRanges of all captures matched by @c pattern in @c searchRange. Returns an empty array if there are no matches in the receiver for @c searchRange.
 @return Will return @c nil if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSValue *> *)rangesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - stringByReplacingOccurrencesOfRegex:withTemplate:

/**
 Returns a string in which all matches of the regular expression @c pattern are replaced with the contents of @c templ after performing capture group substitutions.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @return A @c NSString created from the characters of the receiver in which all matches of the regular expression @c pattern are replaced with the contents of the @c templ string after performing capture group substitutions.
 @return If the receiver is not matched by @c pattern then the string that is returned is a copy of the receiver as if @c stringWithString: had been sent to it.
 @return Will return @c nil if an error occurs.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ;

/**
 Returns a string created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern are replaced with the contents of @c templ after performing capture group substitutions.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern are replaced with the contents of the @c templ string after performing capture group substitutions.
 @return Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Will return @c nil if an error occurs.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange;

/**
 Returns a string created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the of @c templ after performing capture group substitutions.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSString created from the characters within the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the @c templ string after performing capture group substitutions. Returns the characters as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Will return @c nil if an error occurs.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ options:(RKXRegexOptions)options;

/**
 Returns a string created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the of @c templ after performing capture group substitutions.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the @c templ string after performing capture group substitutions. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;


/**
 Returns a string created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options and @c matchOptions are replaced with the contents of @c templ after performing capture group substitutions.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options and @c matchOptions are replaced with the contents of the @c templ string after performing capture group substitutions. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - stringMatchedByRegex:

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSString containing the substring of the receiver matched by @c pattern.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern for @c capture.

 @param pattern A @c NSString containing a regular expression.
 @param capture The string matched by @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched.
 @return A @c NSString containing the substring of the receiver matched by @c capture of @c pattern.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern for @c captureName.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored or return an @c NSRange of @c { NSNotFound, 0 },

 @param pattern A @c NSString containing a regular expression.
 @param captureName The string matched by @c captureName from @c pattern to return. Use @c nil for the entire string that @c pattern matched.
 @return A @c NSString containing the substring of the receiver matched by @c captureName of @c pattern.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern namedCapture:(NSString *)captureName;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern for @c capture or @c captureName.

 NOTE: If *BOTH* @c capture and @c captureName are used to find the first occurring string, the returned string will be the substring conforming to the first matched range. In the event of a location tie, the returned substring will be of the captured range that has the LONGEST length.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param capture The string matched by @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered group captures.
 @param captureName The string matched by @c captureName from @c pattern to return. Use @c nil for the entire string that @c pattern matched.
 @return A @c NSString containing the substring of the receiver matched by @c captureName of @c pattern.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture namedCapture:(NSString *)captureName;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern for @c capture or @c captureName using @c options.

 NOTE: If *BOTH* @c capture and @c captureName are used to find the first occurring string, the returned string will be the substring conforming to the first matched range. In the event of a location tie, the returned substring will be of the captured range that has the LONGEST length.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param capture The string matched by @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered group captures.
 @param captureName The string matched by @c captureName from @c pattern to return. Use @c nil for the entire string that @c pattern matched.
 @return A @c NSString containing the substring of the receiver matched by @c captureName of @c pattern.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture namedCapture:(NSString *)captureName options:(RKXRegexOptions)options;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern within @c searchRange of the receiver.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSString containing the substring of the receiver matched by @c pattern within @c searchRange of the receiver.
 @return Returns @c nil if the receiver is not matched by @c pattern or an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSString containing the substring of the receiver matched by @c pattern within the receiver. Returns @c nil if the receiver is not matched by @c pattern.
 @return Will return @c nil if an error occurs.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern using @c options within @c searchRange of the receiver for @c capture.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The string matched by @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString containing the substring of the receiver matched by @c capture of @c pattern within @c searchRange of the receiver. Returns @c nil if the receiver is not matched by @c pattern within @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c pattern using @c options and @c matchOptions within @c searchRange of the receiver for @c capture or @c captureName.

 NOTE: If *BOTH* @c capture and @c captureName are used to find the first occurring string, the returned string will be the substring conforming to the first matched range within @c searchRange. In the event of a location tie, the returned substring will be conform to the matched range that has the LONGEST length.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The string matched by @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @param captureName The string matched by named capture group @c captureName from @c pattern to return. Use @c nil for the entire string that @c pattern matched.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString containing the substring of the receiver matched by @c capture or @c captureName of @c pattern within @c searchRange of the receiver.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture namedCapture:(NSString *)captureName options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - substringsMatchedByRegex:

/**
 Returns an array containing all the substrings from the receiver that were matched by the regular expression @c pattern.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c pattern.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number @c capture from the regular expression @c pattern.

 @param pattern A @c NSString containing a regular expression.
 @param capture The capture group number @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c capture from @c pattern.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture;

/**
 Returns an array containing all the substrings from the receiver that were matched by named capture group @c captureName from the regular expression @c pattern.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param captureName The string matched by the named capture group from @c pattern to return. Use @c nil if there are no named groups in @c pattern.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c namedCapture from @c pattern.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern namedCapture:(NSString *)captureName;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number @c capture and named capture group @c captureName from the regular expression @c pattern.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param capture The capture group number @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @param captureName The string matched by the named capture group from @c pattern to return. Use @c nil if there are no named groups in @c pattern.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c capture and @c namedCapture from @c pattern.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern capture:(NSUInteger)capture namedCapture:(NSString *)captureName;

/**
 Returns an array containing all the substrings from the receiver that were matched by the regular expression @c pattern within @c searchRange.

 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c pattern within @c searchRange.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns an array containing all the substrings from the receiver that were matched by the regular expression @c pattern using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSArray containing all the substrings from the receiver that were matched by the @c pattern using @c options.
 @return Returns an empty array if @c pattern fails to match.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number @c capture from the regular expression @c pattern within @c searchRange using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The capture group number @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c capture from @c pattern within @c searchRange using @c options.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number @c capture and named capture group @c captureName from the regular expression @c pattern within @c searchRange using @c options and @c matchOptions.

 NOTE: @c captureName will only work on macOS 10.13+. Otherwise it will be ignored.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param capture The capture group number @c capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched. Use @c NSNotFound to exclude all numbered captures.
 @param captureName The string matched by the named capture group from @c pattern to return. Use @c nil if there are no named groups in @c pattern.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing all the substrings from the receiver that were matched by @c capture and @c namedCapture from @c pattern within @c searchRange using @c options and @c matchOptions.
 @return Returns an empty array if @c pattern fails to match in @c searchRange.
 @return Will return @c nil if an error occurs and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)substringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange capture:(NSUInteger)capture namedCapture:(NSString *)captureName options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - substringsSeparatedByRegex:

/**
 Returns an array containing substrings within the receiver that have been divided by the regular expression @c pattern.
 
 @param pattern A @c NSString containing a regular expression.
 @return A @c NSArray containing the substrings from the receiver that have been divided by @c pattern.
 */
- (NSArray<NSString *> *)substringsSeparatedByRegex:(NSString *)pattern;

/**
 Returns an array containing substrings within @c searchRange of the receiver that have been divided by the regular expression @c pattern.
 
 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSArray containing the substrings from the receiver that have been divided by @c pattern.
 @return Returns @c nil if @c pattern is invalid.
 */
- (NSArray<NSString *> *)substringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange;

/**
 Returns an array containing substrings within the receiver that have been divided by the regular expression @c pattern using @c options.

 @param pattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return A @c NSArray containing the substrings from the receiver that have been divided by @c pattern. If there is no match, returns an array with the receiver as the single element.
 @return Returns @c nil if @c pattern is invalid.
 */
- (NSArray<NSString *> *)substringsSeparatedByRegex:(NSString *)pattern options:(RKXRegexOptions)options;

/**
 Returns an array containing substrings within @c searchRange of the receiver that have been divided by the regular expression @c pattern using @c options.
 
 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings from the receiver that have been divided by @c pattern. If there is no match, returns an array with the receiver as the single element.
 @return Returns @c nil if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)substringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Returns an array containing substrings within @c searchRange of the receiver that have been divided by the regular expression @c pattern using @c options and @c matchOptions.

 @param pattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining @c RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions The matching options to use. See @c RKXMatchOptions for possible values.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings from the receiver that have been divided by @c pattern. If there is no match, returns an array with the receiver as the single element.
 @return Returns @c nil if @c pattern is invalid and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSArray<NSString *> *)substringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - Blocks-based API
#pragma mark - enumerateStringsMatchedByRegex:usingBlock:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

/**
 Enumerates the matches in the receiver by the regular expression @c pattern and executes the block serially from left-to-right for each match found.

 @param pattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern using @c options and executes the block for each match found.

 @param pattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern options:(RKXRegexOptions)options usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and executes the block for each match found.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions and executes the block using the enumeration direction defined by @c enumOpts for each match found.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions A mask of options specified by combining RKXMatchOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param enumOpts Options for block enumeration operations. Use @c 0 for serial forward operations (best with left-to-right languages). Use @c NSEnumerationReverse for right-to-left languages. Behavior is undefined for @c NSEnumerationConcurrent.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions enumerationOptions:(NSEnumerationOptions)enumOpts error:(NSError **)error usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c pattern and executes @c block for each divided string. The enumeration occurrs serially from left-to-right.

 @param pattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each divided string between the matches of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c pattern using @c options and executes @c block for each divided string. The enumeration occurrs serially from left-to-right.

 @param pattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param block The block that is executed for each divided string between the matches of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern options:(RKXRegexOptions)options usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c pattern within @c searchRange using @c options and executes @c block for each divided string. The enumeration occurrs serially from left-to-right.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each divided string between the matches of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c pattern within @c searchRange using @c options and and @c matchOptions and executes @c block for each divided string. The enumeration direction is set by @c enumOpts.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions A mask of options specified by combining RKXMatchOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param enumOpts Options for block enumeration operations. Use @c 0 for serial forward operations (best with left-to-right languages). Use @c NSEnumerationReverse for right-to-left languages. Behavior is undefined for @c NSEnumerationConcurrent.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each divided string between the matches of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the NSValue-wrapped NSRanges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions enumerationOptions:(NSEnumerationOptions)enumOpts error:(NSError **)error usingBlock:(void (NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

/**
 Enumerates the matches in the receiver by the regular expression @c pattern and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param pattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return A @c NSString created from the characters of the receiver in which all matches of the regular expression @c pattern are replaced with the contents of the @c NSString returned by @c block. If the receiver is not matched by @c pattern then the string that is returned is a copy of the receiver as if @c stringWithString: had been sent to it.
 @return Returns @c nil if there was an error.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern using @c options and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param pattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return A @c NSString created from the characters within the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the @c NSString returned by @c block. Returns the characters within the receiver as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Returns @c nil if there was an error.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the @c NSString returned by @c block. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Returns @c nil if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions A mask of options specified by combining RKXMatchOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block takes three arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c pattern using @c options are replaced with the contents of the @c NSString returned by @c block. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c pattern.
 @return Returns @c nil if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;
#pragma clang diagnostic pop

@end

#pragma mark -
@interface NSMutableString (RegexKitX)

#pragma mark - replaceOccurrencesOfRegex:withTemplate:

/**
 Replaces all occurrences of the regular expression @c pattern with the contents of @c templ after performing capture group substitutions, returning the number of replacements made.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a valid regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ;

/**
 Replaces all occurrences of the regular expression @c pattern within @c searchRange with the contents of @c templ after performing capture group substitutions, returning the number of replacements made.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a valid regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange;

/**
 Replaces all occurrences of the regular expression @c pattern using @c options with the contents of @c templ after performing capture group substitutions, returning the number of replacements made.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a valid regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ options:(RKXRegexOptions)options;

/**
 Replaces all occurrences of the regular expression @c pattern using @c options within @c searchRange with the contents of @c templ after performing capture group substitutions, returning the number of replacements made.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a valid regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error;

/**
 Replaces all occurrences of the regular expression @c pattern using @c options and @c matchOptions within @c searchRange with the contents of @c templ after performing capture group substitutions, returning the number of replacements made.

 NOTE: As of macOS 10.13, the template string can use both capture group numbered backreferences ("$1") and capture group named backreferences ("${name}"). If you attempt to use named backreferences prior to 10.13, the backreferenced variables will not be substituted.

 @param pattern A @c NSString containing a valid regular expression.
 @param templ A @c NSString containing a string template. Can use capture group variables.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions A mask of options specified by combining RKXMatchOptions flags with the C bitwise @c OR operator. @c 0 may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern withTemplate:(NSString *)templ range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error;

#pragma mark - Blocks-based API
#pragma mark - replaceOccurrencesOfRegex:usingBlock:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
/**
 Enumerates the matches in the receiver by the regular expression @c pattern and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param pattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern using @c options and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param pattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern options:(RKXRegexOptions)options usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options error:(NSError **)error usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c pattern within @c searchRange using @c options and @c matchOptions and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param pattern A @c NSString containing a valid regular expression.
 @param searchRange The range of the receiver to search.
 @param options A mask of options specified by combining RKXRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKXNoOptions may be used if no options are required.
 @param matchOptions A mask of options specified by combining RKXMatchOptions flags with the C bitwise @c OR operator. @c 0 may be used if no options are required.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of @c pattern in the receiver. The block returns a @c NSString and takes four arguments:
 @param &nbsp;&nbsp;capturedStrings A @c NSArray containing the substrings matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a pointer to a string that is equal to @c @@"".
 @param &nbsp;&nbsp;capturedRanges A @c NSArray containing the ranges matched by each capture group present in @c pattern. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. Setting the value to @c YES within the block stops further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished.
 @return Returns number of successful substitutions of the matched @c pattern.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if @c error is not @c NULL.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)pattern range:(NSRange)searchRange options:(RKXRegexOptions)options matchOptions:(RKXMatchOptions)matchOptions error:(NSError **)error usingBlock:(NSString *(NS_NOESCAPE ^)(NSArray<NSString *> *capturedStrings, NSArray<NSValue *> *capturedRanges, BOOL *stop))block;
#pragma clang diagnostic pop

@end
