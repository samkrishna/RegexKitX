//
//  RegexKitLite5.h
//  RegexKitLite5
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

/*
  License
  Copyright © 2007-2008, John Engelhart

  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  Neither the name of the Zang Industries nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, RKLRegexOptions) {
    /** No regular expression options specified. */
    RKLNoOptions                = 0,
    /** Match letters in the pattern independent of case. */
    RKLCaseless                 = NSRegularExpressionCaseInsensitive,
    /** Ignore whitespace and #-prefixed comments in the pattern. */
    RKLComments                 = NSRegularExpressionAllowCommentsAndWhitespace,
    /** Treat the entire pattern as a literal string. */
    RKLIgnoreMetacharacters     = NSRegularExpressionIgnoreMetacharacters,
    /** Allow . to match any character, including line separators. */
    RKLDotAll                   = NSRegularExpressionDotMatchesLineSeparators,
    /** Allow ^ and $ to match the start and end of lines. */
    RKLMultiline                = NSRegularExpressionAnchorsMatchLines,
    /** Treat only \n as a line separator (otherwise, all standard line separators are used). */
    RKLUseUnixLineSeparators    = NSRegularExpressionUseUnixLineSeparators,
    /** Use Unicode TR#29 to specify word boundaries (otherwise, traditional regular expression word boundaries are used). */
    RKLUnicodeWordBoundaries    = NSRegularExpressionUseUnicodeWordBoundaries
};

@interface NSString (EntireRange)
- (NSRange)stringRange;
- (NSRange)rangeFromLocation:(NSUInteger)location;
- (NSRange)rangeToLocation:(NSUInteger)location;
@end

@interface NSString (RegexKitLite5)

#pragma mark - componentsSeparatedByRegex:

/**
 Returns an array containing substrings within the receiver that have been divided by the regular expression @c regexPattern.
 
 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSArray object containing the substrings from the receiver that have been divided by @c regexPattern.
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern;

/**
 Returns an array containing substrings within @c range of the receiver that have been divided by the regular expression @c regexPattern.
 
 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @return A @c NSArray object containing the substrings from the receiver that have been divided by @c regexPattern.
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern range:(NSRange)range;

/**
 Returns an array containing substrings within @c range of the receiver that have been divided by the regular expression @c regexPattern using @c options.
 
 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing the substrings from the receiver that have been divided by @c regexPattern.
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error;

/**
 Returns an array containing substrings within @c range of the receiver that have been divided by the regular expression @c regexPattern using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing the substrings from the receiver that have been divided by @c regexPattern.
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error;

#pragma mark - isMatchedByRegex:

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c regexPattern.

 @param regexPattern A @c NSString containing a regular expression.
 @return A BOOL value indicating whether or not the regexPattern has been matched in the receiver.
 */
- (BOOL)isMatchedByRegex:(NSString *)regexPattern;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c regexPattern within @c range.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @return A BOOL value indicating whether or not the regexPattern has been matched in the receiver.
 */
- (BOOL)isMatchedByRegex:(NSString *)regexPattern inRange:(NSRange)range;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c regexPattern within @c range using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A BOOL value indicating whether or not the regexPattern has been matched in the receiver.
 */
- (BOOL)isMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error;

/**
 Returns a Boolean value that indicates whether the receiver is matched by @c regexPattern within @c range using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A BOOL value indicating whether or not the regexPattern has been matched in the receiver.
 */
- (BOOL)isMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error;

#pragma mark - rangeOfRegex:

/**
 Returns the range for the first match of @c regexPattern.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSRange structure giving the location and length of the first match of regexPattern within @c range of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c regexPattern.
 */
- (NSRange)rangeOfRegex:(NSString *)regexPattern;

/**
 Returns the range of capture number @c capture for the first match of @c regexPattern in the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param capture The matching range of the capture number from regexPattern to return. Use 0 for the entire range that @c regexPattern matched.
 @return A NSRange structure giving the location and length of the first match of regexPattern within @c range of the receiver. Returns {NSNotFound, 0} if the receiver is not matched by @c regexPattern within @c range or an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)regexPattern capture:(NSUInteger)capture;

/**
 Returns the range for the first match of @c regexPattern within @c range of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c regexPattern. Returns @c {NSNotFound, 0} if the receiver is not matched by @c regexPattern.
 */
- (NSRange)rangeOfRegex:(NSString *)regexPattern inRange:(NSRange)range;

/**
 Returns the range of capture number @c capture for the first match of @c regexPattern within @c range of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param capture The matching range of the capture number from regexPattern to return. Use 0 for the entire range that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c regexPattern within @c range of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c regexPattern within @c range or an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range capture:(NSUInteger)capture error:(NSError **)error;

/**
 Returns the range of capture number @c capture for the first match of @c regexPattern within @c range of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param capture The matching range of the capture number from regexPattern to return. Use 0 for the entire range that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSRange structure giving the location and length of capture number @c capture for the first match of @c regexPattern within @c range of the receiver. Returns @c {NSNotFound, 0} if the receiver is not matched by @c regexPattern within @c range or an error occurs.
 */
- (NSRange)rangeOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range capture:(NSUInteger)capture error:(NSError **)error;

#pragma mark - rangesOfRegex:

/**
 Returns an NSArray of NSValue-wrapped NSRanges of all captures of regexPattern matched in the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSArray of NSValue-wrapped NSRanges of all captures matched by @c regexPattern.
 */
- (NSArray *)rangesOfRegex:(NSString *)regexPattern;

/**
 Returns an NSArray of NSValue-wrapped NSRanges of all captures of regexPattern for all matches within @c searchRange of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSArray of NSValue-wrapped NSRanges of all captures matched by @c regexPattern in @c searchRange.
 */
- (NSArray *)rangesOfRegex:(NSString *)regexPattern inRange:(NSRange)searchRange;

/**
 Returns an NSArray of NSValue-wrapped NSRanges of all captures of regexPattern for all matches within @c searchRange of the receiver using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray of NSValue-wrapped NSRanges of all captures matched by @c regexPattern in @c searchRange.
 */
- (NSArray *)rangesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)searchRange error:(NSError **)error;

/**
 Returns an NSArray of NSValue-wrapped NSRanges of all captures of regexPattern for all matches within @c searchRange of the receiver using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray of NSValue-wrapped NSRanges of all captures matched by @c regexPattern in @c searchRange.
 */
- (NSArray *)rangesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange error:(NSError **)error;

#pragma mark - stringByMatching:

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of @c regexPattern.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSString containing the substring of the receiver matched by @c regexPattern. Returns @c nil if the receiver is not matched by @c regexPattern or an error occurs.
 */
- (NSString *)stringByMatching:(NSString *)regexPattern;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of regexPattern using @c options and @c matchingOptions within @c searchRange of the receiver for capture.

 @param regexPattern A @c NSString containing a regular expression.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @return A @c NSString containing the substring of the receiver matched by capture number capture of @c regexPattern. Returns @c nil if the receiver is not matched by @c regexPattern or an error occurs.
 */
- (NSString *)stringByMatching:(NSString *)regexPattern capture:(NSUInteger)capture;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of regexPattern using @c options and @c matchingOptions within @c searchRange of the receiver for capture.

 @param regexPattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSString containing the substring of the receiver matched by capture number capture of regexPattern within the searchRange of the receiver. Returns @c nil if the receiver is not matched by @c regexPattern or an error occurs.
 */
- (NSString *)stringByMatching:(NSString *)regexPattern inRange:(NSRange)searchRange;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of regexPattern using @c options and @c matchingOptions within @c searchRange of the receiver for capture.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param searchRange The range of the receiver to search.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString containing the substring of the receiver matched by capture number capture of regexPattern within @c searchRange of the receiver. Returns @c nil if the receiver is not matched by @c regexPattern within @c searchRange or an error occurs.
 */
- (NSString *)stringByMatching:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error;

/**
 Returns a string created from the characters of the receiver that are in the range of the first match of regexPattern using @c options and @c matchingOptions within @c searchRange of the receiver for capture.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param searchRange The range of the receiver to search.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString containing the substring of the receiver matched by capture number capture of regexPattern within @c searchRange of the receiver. Returns @c nil if the receiver is not matched by @c regexPattern within @c searchRange or an error occurs.
 */
- (NSString *)stringByMatching:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)searchRange capture:(NSUInteger)capture error:(NSError **)error;

#pragma mark - stringByReplacincOccurrencesOfRegex:withString:

/**
 Returns a string created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options and @c matchingOptions are replaced with the contents of the @c replacement string after performing capture group substitutions.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSString created from the characters of the receiver in which all matches of the regular expression @c regexPattern are replaced with the contents of the @c replacement string after performing capture group substitutions. If the receiver is not matched by @c regexPattern then the string that is returned is a copy of the receiver as if @c stringWithString: had been sent to it.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement;

/**
 Returns a string created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options and @c matchingOptions are replaced with the contents of the @c replacement string after performing capture group substitutions.

 @param regexPattern A @c NSString containing a regular expression.
 @param searchRange The range of the receiver to search.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c regexPattern are replaced with the contents of the @c replacement string after performing capture group substitutions. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c regexPattern.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement range:(NSRange)searchRange;

/**
 Returns a string created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options are replaced with the contents of the @c replacement string after performing capture group substitutions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c regexPattern using @c options and @c matchingOptions are replaced with the contents of the @c replacement string after performing capture group substitutions. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c regexPattern.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error;


/**
 Returns a string created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options and @c matchingOptions are replaced with the contents of the @c replacement string after performing capture group substitutions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSString created from the characters within @c searchRange of the receiver in which all matches of the regular expression @c regexPattern using @c options and @c matchingOptions are replaced with the contents of the @c replacement string after performing capture group substitutions. Returns the characters within @c searchRange as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c regexPattern.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error;

#pragma mark - captureCount:

/**
 Returns the number of captures that the regex contains.

 @return Returns @c NSNotFound if an error occurs. Otherwise the number of captures in the regex is returned, or @c 0 if the regex does not contain any captures.
 */
- (NSUInteger)captureCount;

/**
 Returns the number of captures that the regex contains.

 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param error The optional error parameter, if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns @c NSNotFound if an error occurs. Otherwise the number of captures in the regex is returned, or @c 0 if the regex does not contain any captures.
 */
- (NSUInteger)captureCountWithOptions:(RKLRegexOptions)options error:(NSError **)error;

#pragma mark - isRegexValid

/**
 Returns a BOOL value that indicates whether the regular expression contained in the receiver.
 @return Returns a @c YES if the regex is valid; @c NO otherwise.
 */
- (BOOL)isRegexValid;

/**
 Returns a BOOL value that indicates whether the regular expression contained in the receiver is valid using @c options.

 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param error The optional error parameter, if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns a @c YES if the regex is valid; @c NO otherwise.
 */
- (BOOL)isRegexValidWithOptions:(RKLRegexOptions)options error:(NSError **)error;

#pragma mark - componentsMatchedByRegex:

- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number capture from the regular expression @c regexPattern.

 @param regexPattern A @c NSString containing a regular expression.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @return A @c NSArray object containing all the substrings for capture group capture from the receiver that were matched by @c regexPattern.
 */
- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern capture:(NSUInteger)capture;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number capture from the regular expression @c regexPattern within @c range using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSArray object containing all the substrings from the receiver that were matched by @c regexPattern within @c range.
 */
- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)range;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number capture from the regular expression @c regexPattern within @c range using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing all the substrings from the receiver that were matched by capture number capture from regexPattern within @c range using @c options and @c matchingOptions.
 */
- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range capture:(NSUInteger)capture error:(NSError **)error;

/**
 Returns an array containing all the substrings from the receiver that were matched by capture number capture from the regular expression @c regexPattern within @c range using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param capture The string matched by capture from regexPattern to return. Use 0 for the entire string that @c regexPattern matched.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing all the substrings from the receiver that were matched by capture number capture from regexPattern within @c range using @c options and @c matchingOptions.
 */
- (NSArray *)componentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range capture:(NSUInteger)capture error:(NSError **)error;

#pragma mark - captureComponentsMatchedByRegex:

/**
 Returns an array containing the substrings matched by each capture group present in @c regexPattern for the first match of @c regexPattern.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSArray containing the substrings matched by each capture group present in regexPattern for the first match of regexPattern within @c range of the receiver using @c options. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern;

/**
 Returns an array containing the substrings matched by each capture group present in @c regexPattern for the first match of @c regexPattern within @c range of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @return A @c NSArray containing the substrings matched by each capture group present in regexPattern for the first match of regexPattern within @c range of the receiver using @c options. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)range;

/**
 Returns an array containing the substrings matched by each capture group present in @c regexPattern for the first match of @c regexPattern within @c range of the receiver using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings matched by each capture group present in regexPattern for the first match of regexPattern within @c range of the receiver using @c options. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error;


/**
 Returns an array containing the substrings matched by each capture group present in @c regexPattern for the first match of @c regexPattern within @c range of the receiver using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray containing the substrings matched by each capture group present in regexPattern for the first match of regexPattern within @c range of the receiver using @c options. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)captureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error;

#pragma mark - arrayOfCaptureComponentsMatchedByRegex:

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c regexPattern. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param regexPattern A @c NSString containing a regular expression.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a NSArray which contains all the capture groups present in @c regexPattern. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c regexPattern within @c range. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a NSArray which contains all the capture groups present in @c regexPattern. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern range:(NSRange)range;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c regexPattern within @c range using @c options. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a NSArray which contains all the capture groups present in @c regexPattern. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error;

/**
 Returns an array containing all the matches from the receiver that were matched by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a NSArray which contains all the capture groups present in @c regexPattern. Array index @c 0 represents all of the text matched by @c regexPattern and subsequent array indexes contain the text matched by their respective capture group.
 */
- (NSArray *)arrayOfCaptureComponentsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error;

#pragma mark - arrayOfDictionariesByMatchingRegex:

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern within @c range. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern range:(NSRange)range withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern within @c range. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern within @c range using @c options. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param keys A @c NSArray object of NSString keys for the dictionaries.
 @param captures A @c NSArray object of NSNumber capture group values for the dictionaries.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures;

/**
 Returns an array containing all the matches in the receiver that were matched by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param keys A @c NSArray object of NSString keys for the dictionaries.
 @param captures A @c NSArray object of NSNumber capture group values for the dictionaries.
 @return A @c NSArray object containing all the matches from the receiver by @c regexPattern. Each match result consists of a @c NSDictionary containing that matches substrings constructed from the specified set of keys and captures.
 */
- (NSArray *)arrayOfDictionariesByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures;

#pragma mark - dictionaryByMatchingRegex:

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern in the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern within @c range of the receiver.

 @param regexPattern A @c NSString containing a regular expression.
 @param range The range of the receiver to search.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern range:(NSRange)range withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern within @c range of the receiver using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern within @c range of the receiver using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param firstKey The first key to add to the new dictionary.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern within @c range of the receiver using @c options.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param keys A @c NSArray object of NSString keys for the dictionaries.
 @param captures A @c NSArray object of NSNumber capture group values for the dictionaries.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures;

/**
 Creates and returns a dictionary containing the matches constructed from the specified set of keys and captures for the first match of regexPattern within @c range of the receiver using @c options and @c matchingOptions.

 @param regexPattern A @c NSString containing a regular expression.
 @param options A mask of options specified by combining @c RKLRegexOptions or @c NSRegularExpressionOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions The matching options to use. See @c NSMatchingOptions for possible values.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param keys A @c NSArray object of NSString keys for the dictionaries.
 @param captures A @c NSArray object of NSNumber capture group values for the dictionaries.
 @return A @c NSDictionary containing the matched substrings constructed from the specified set of keys and captures.
 */
- (NSDictionary *)dictionaryByMatchingRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)range error:(NSError **)error withKeys:(NSArray *)keys forCaptures:(NSArray *)captures;

#pragma mark - enumerateStringsMatchedByRegex:usingBlock:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern and executes the block serially from left-to-right for each match found.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions and executes the block using enumerationOptions for each match found.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if error is not @c NULL.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions and executes the block using @c enumOpts for each match found.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions A mask of options specified by combining NSMatchingOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param enumOpts Options for block enumeration operations. Use 0 for serial forward operations (best with left-to-right languages). Use @c NSEnumerationReverse for right-to-left languages. Behavior is undefined for @c NSEnumerationConcurrent.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if error is not @c NULL.
 */
- (BOOL)enumerateStringsMatchedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

#pragma mark - enumerateStringsSeparatedByRegex:usingBlock:

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c regexPattern within @c range using @c options and executes @c block for each divided string. The enumeration occurrs serially from left-to-right.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c regexPattern within @c range using @c options and executes @c block for each divided string. The enumeration occurrs serially from left-to-right.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if error is not @c NULL.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the strings of the receiver that have been divided by the regular expression @c regexPattern within @c range using @c options and and @c matchingOptions and executes @c block for each divided string. The enumeration is set by @c enumOpts.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions A mask of options specified by combining NSMatchingOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param enumOpts Options for block enumeration operations. Use 0 for serial forward operations (best with left-to-right languages). Use @c NSEnumerationReverse for right-to-left languages. Behavior is undefined for @c NSEnumerationConcurrent.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c YES if there was no error, otherwise returns @c NO and indirectly returns a @c NSError object if error is not @c NULL.
 */
- (BOOL)enumerateStringsSeparatedByRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error enumerationOptions:(NSEnumerationOptions)enumOpts usingBlock:(void (^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

#pragma mark - stringByReplacingOccurrencesOfRegex:usingBlock:

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return A @c NSString created from the characters of the receiver in which all matches of the regular expression @c regexPattern are replaced with the contents of the @c NSString returned by @c block. If the receiver is not matched by @c regexPattern then the string that is returned is a copy of the receiver as if @c stringWithString: had been sent to it.

 @return Returns @c nil if there was an error.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return A @c NSString created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options are replaced with the contents of the @c NSString returned by @c block. Returns the characters within @c range as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c regexPattern.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions and executes @c block for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of the string returned by @c block.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions A mask of options specified by combining NSMatchingOptions flags with the C bitwise @c OR operator. 0 may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return A @c NSString created from the characters within @c range of the receiver in which all matches of the regular expression @c regexPattern using @c options are replaced with the contents of the @c NSString returned by @c block. Returns the characters within @c range as if @c substringWithRange: had been sent to the receiver if the substring is not matched by @c regexPattern.
 */
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
#pragma clang diagnostic pop

@end

#pragma mark -

@interface NSMutableString (RegexKitLite5)

#pragma mark - replaceOccurrencesOfRegex:withString:

/**
 Replaces all occurrences of the regular expression @c regexPattern using @c options and @c matchingOptions within @c searchRange with the contents of @c replacement string after performing capture group substitutions, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param replacement The string to use as the replacement text for matches by @c regexPattern. See ICU Replacement Text Syntax for more information.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement;

/**
 Replaces all occurrences of the regular expression @c regexPattern using @c options and @c matchingOptions within @c searchRange with the contents of @c replacement string after performing capture group substitutions, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param replacement The string to use as the replacement text for matches by @c regexPattern. See ICU Replacement Text Syntax for more information.
 @param searchRange The range of the receiver to search.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement range:(NSRange)searchRange;

/**
 Replaces all occurrences of the regular expression @c regexPattern using @c options and @c matchingOptions within @c searchRange with the contents of @c replacement string after performing capture group substitutions, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param replacement The string to use as the replacement text for matches by @c regexPattern. See ICU Replacement Text Syntax for more information.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error;

/**
 Replaces all occurrences of the regular expression @c regexPattern using @c options and @c matchingOptions within @c searchRange with the contents of @c replacement string after performing capture group substitutions, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param replacement The string to use as the replacement text for matches by @c regexPattern. See ICU Replacement Text Syntax for more information.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions A mask of options specified by combining NSMatchingOptions flags with the C bitwise @c OR operator. @c 0 may be used if no options are required.
 @param searchRange The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern withString:(NSString *)replacement options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions range:(NSRange)searchRange error:(NSError **)error;

#pragma mark - replaceOccurrencesOfRegex:usingBlock:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

/**
 Enumerates the matches in the receiver by the regular expression @c regexPattern within @c range using @c options and @c matchingOptions and executes @c block for each match found. Replaces the characters that were matched with the contents of the string returned by @c block, returning the number of replacements made.

 @param regexPattern A @c NSString containing a valid regular expression.
 @param options A mask of options specified by combining RKLRegexOptions flags with the C bitwise @c OR operator. Either @c 0 or @c RKLNoOptions may be used if no options are required.
 @param matchingOptions A mask of options specified by combining NSMatchingOptions flags with the C bitwise @c OR operator. @c 0 may be used if no options are required.
 @param range The range of the receiver to search.
 @param error An optional parameter that if set and an error occurs, will contain a @c NSError object that describes the problem. This may be set to @c NULL if information about any errors is not required.
 @param block The block that is executed for each match of regexPattern in the receiver. The block takes four arguments:
 @param &nbsp;&nbsp;captureCount The number of strings that @c regexPattern captured. @c captureCount is always at least 1.
 @param &nbsp;&nbsp;capturedStrings An array containing the substrings matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a pointer to a string that is equal to @"".
 @param &nbsp;&nbsp;capturedRanges An array containing the ranges matched by each capture group present in @c regexPattern. The size of the array is @c captureCount. If a capture group did not match anything, it will contain a @c NSRange equal to @c {NSNotFound, 0}.
 @param &nbsp;&nbsp;stop A reference to a Boolean value. The block can set the value to @c YES to stop further enumeration of the array. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to @c YES within the block.
 @return Returns @c NSNotFound if there was an error and indirectly returns a @c NSError object if error is not @c NULL, otherwise returns the number of replacements performed.
 */
- (NSUInteger)replaceOccurrencesOfRegex:(NSString *)regexPattern options:(RKLRegexOptions)options matchingOptions:(NSMatchingOptions)matchingOptions inRange:(NSRange)range error:(NSError **)error usingBlock:(NSString *(^)(NSUInteger captureCount, NSArray *capturedStrings, const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
#pragma clang diagnostic pop

@end
