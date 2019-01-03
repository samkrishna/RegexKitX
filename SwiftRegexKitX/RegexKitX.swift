//
//  RegexKitX.swift
//  RegexKitX

/*
 Created by Sam Krishna on 8/27/17.
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

import Foundation

infix operator =~

public func =~ (string: String, regex: String) -> Bool {
    do {
        let result = try string.matches(regex)
        return result
    } catch {
        return false
    }
}

public func ~= (regex: String, string: String) -> Bool {
    do {
        let result = try string.matches(regex)
        return result
    } catch {
        return false
    }
}

public struct RKXRegexOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let RKXCaseless              = RKXRegexOptions(rawValue: 1 << 0)
    public static let RKXComments              = RKXRegexOptions(rawValue: 1 << 1)
    public static let RKXIgnoreMetacharacters  = RKXRegexOptions(rawValue: 1 << 2)
    public static let RKXDotAll                = RKXRegexOptions(rawValue: 1 << 3)
    public static let RKXMultiline             = RKXRegexOptions(rawValue: 1 << 4)
    public static let RKXUseUnixLineSeparators = RKXRegexOptions(rawValue: 1 << 5)
    public static let RKXUnicodeWordBoundaries = RKXRegexOptions(rawValue: 1 << 6)

    fileprivate func coerceToNSRegularExpressionOptions() -> NSRegularExpression.Options {
        var options = NSRegularExpression.Options()
        if contains(.RKXCaseless) { options.insert(.caseInsensitive) }
        if contains(.RKXComments) { options.insert(.allowCommentsAndWhitespace) }
        if contains(.RKXIgnoreMetacharacters) { options.insert(.ignoreMetacharacters) }
        if contains(.RKXDotAll) { options.insert(.dotMatchesLineSeparators) }
        if contains(.RKXMultiline) { options.insert(.anchorsMatchLines) }
        if contains(.RKXUseUnixLineSeparators) { options.insert(.useUnixLineSeparators) }
        if contains(.RKXUnicodeWordBoundaries) { options.insert(.useUnicodeWordBoundaries) }
        return options
    }
}

public struct RKXMatchOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let RKXReportProgress         = RKXMatchOptions(rawValue: 1 << 0)
    public static let RKXReportCompletion       = RKXMatchOptions(rawValue: 1 << 1)
    public static let RKXAnchored               = RKXMatchOptions(rawValue: 1 << 2)
    public static let RKXTransparentBounds      = RKXMatchOptions(rawValue: 1 << 3)
    public static let RKXAnchorlessBounds       = RKXMatchOptions(rawValue: 1 << 4)

    fileprivate func coerceToNSMatchingOptions() -> NSRegularExpression.MatchingOptions {
        var options = NSRegularExpression.MatchingOptions()
        if contains(.RKXReportProgress) { options.insert(.reportProgress) }
        if contains(.RKXReportCompletion) { options.insert(.reportCompletion) }
        if contains(.RKXAnchored) { options.insert(.anchored) }
        if contains(.RKXTransparentBounds) { options.insert(.withTransparentBounds) }
        if contains(.RKXAnchorlessBounds) { options.insert(.withoutAnchoringBounds) }
        return options
    }
}

enum DictionaryError: Error {
    case tooManyKeysAndCaptures
    case unpairedKeysAndCaptures
}

public extension NSTextCheckingResult {
    var ranges: [NSRange] {
        var _ranges = [NSRange]()

        for i in 0...(self.numberOfRanges - 1) {
            let captureRange = self.range(at: i)
            _ranges.append(captureRange)
        }

        return _ranges
    }

    fileprivate func substrings(from string: String)
        -> [String] {
            let substrings = ranges.map {
                $0.location != NSNotFound ? (string as NSString).substring(with: $0) : ""
            }

            return substrings
    }
}

public extension String {

    // MARK: CONVENIENCE

    /// The full range of the string as an `NSRange`, based on the UTF-16 length.
    var stringRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    /// Returns the `NSRange` from `location` to the end of the receiver, in UTF-16 code units.
    func rangeFrom(location: Int)
        -> NSRange {
            let deltaLength = (self as NSString).length - location
            return NSRange(location: location, length: deltaLength)
    }

    /// Converts `range` from a `NSRange` to a `String.UTF16Index Range`.
    func utf16Range(from range: NSRange)
        -> Range<String.UTF16Index>? {
        return Range(range, in: self)
    }

    /// Converts 'range' from a `Range<String.UTF16Index>` to a `NSRange`
    func nsrange(from range: Range<String.UTF16Index>?)
        -> NSRange {
        guard range != nil else { return NSMakeRange(NSNotFound, 0) }
        return NSRange(range!, in: self)
    }

    // MARK: Internal
    fileprivate static func cacheKey(for pattern: String, options: RKXRegexOptions)
        -> String {
            let key = String("\(pattern)_\(options.rawValue)")
            return key
    }

    fileprivate func regexMatches(for pattern: String,
                                  in range: NSRange? = nil,
                                  options: RKXRegexOptions = [],
                                  matchOptions: RKXMatchOptions = [])
        throws -> [NSTextCheckingResult] {
            let regex = try String.cachedRegex(for: pattern, options: options)
            let matchingOpts = matchOptions.coerceToNSMatchingOptions()
            let matches = regex.matches(in: self, options: matchingOpts, range: range ?? stringRange)
            return matches
    }

    fileprivate static func cachedRegex(for pattern: String, options: RKXRegexOptions)
        throws -> NSRegularExpression {
            let key = cacheKey(for: pattern, options: options)
            var regex = Thread.current.threadDictionary[key] as? NSRegularExpression

            if regex == nil {
                let nsregexopts = options.coerceToNSRegularExpressionOptions()
                regex = try NSRegularExpression(pattern: pattern, options: nsregexopts)
                Thread.current.threadDictionary[key] = regex
            }

            return regex!
    }

    // MARK: matches(pattern:...)

    /// Returns a `Bool` value that indicates whether the receiver is matched by `pattern` within `searchRange` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression pattern.
    ///   - searchRange: The range of the receiver to search. If no parameter is passed, the method will default to using the entire range of the receiver.
    ///   - options: An OptionSet of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An OptionSet of options specified by combining the RKXMatchOptions flaghs.
    /// - Returns: A Bool value indicating whether or not the pattern matches the receiver.
    /// - Throws: An error if the pattern is invalid.
    func matches(_ pattern: String,
                 in searchRange: NSRange? = nil,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Bool {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            return true
    }

    /// Returns a `Bool` value that indicates whether the receiver is matched by `pattern` within `searchRange` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression pattern.
    ///   - searchRange: The range of the receiver to search. If no parameter is passed, the method will default to using the entire range of the receiver.
    ///   - options: An OptionSet of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An OptionSet of options specified by combining the RKXMatchOptions flaghs.
    /// - Returns: A Bool value indicating whether or not the pattern matches the receiver.
    /// - Throws: An error if the pattern is invalid.
    func matches(_ pattern: String,
                 in searchRange: Range<String.UTF16Index>,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Bool {
            let legacyRange = nsrange(from: searchRange)
            return try matches(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: range(of:in:for:options:matchingOptions:)

    /// Returns the range of capture number `capture` for the first match of `pattern` within `searchRange` of the receiver.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search. The default value is the entire range of the receiver.
    ///   - capture: The matching range of the capture number from `pattern` to search. Use `0` for the entire range that `pattern` matched.
    ///   - options: An OptionSet specified by combining various `RKXRegexOptions`. If no options are required, ignore this parameter.
    ///   - matchingOptions: An OptionSet specified by combining various `RKXMatchOptions`. If no options are required, ignore this parameter.
    /// - Returns: A NSRange structure giving the location and length of capture number `capture` for the first match of `pattern` within `searchRange` of the receiver.
    /// - Throws: A NSError object for any issue that came up during initialization of the regular expression.
    func range(of pattern: String,
               in searchRange: NSRange? = nil,
               for capture: Int = 0,
               options: RKXRegexOptions = [],
               matchingOptions: RKXMatchOptions = [])
        throws -> Range<String.UTF16Index>? {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard let match = matches.first else { return nil }
            let range = utf16Range(from: match.range(at: capture))
            return range
    }

    /// Returns the range of capture number `capture` for the first match of `pattern` within `searchRange` of the receiver.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search. The default value is the entire range of the receiver.
    ///   - capture: The matching range of the capture number from `pattern` to search. Use `0` for the entire range that `pattern` matched.
    ///   - options: An OptionSet specified by combining various `RKXRegexOptions`. If no options are required, ignore this parameter.
    ///   - matchingOptions: An OptionSet specified by combining various `RKXMatchOptions`. If no options are required, ignore this parameter.
    /// - Returns: A Range<String.UTF16Index> giving the Range of capture number `capture` for the first match of `pattern` within `searchRange` of the receiver.
    /// - Throws: A NSError object for any issue that came up during initialization of the regular expression.
    func range(of pattern: String,
               in searchRange: Range<String.UTF16Index>,
               for capture: Int = 0,
               options: RKXRegexOptions = [],
               matchingOptions: RKXMatchOptions = [])
        throws -> Range<String.UTF16Index>? {
            let legacyRange = nsrange(from: searchRange)
            return try range(of: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: stringMatched(by:in:for:options:matchingOptions:)

    /// Returns a string created from the characters of the receiver that are in the range of the first match of `pattern` using `options` and `matchOptions` within `searchRange` of the receiver for `capture`.
    ///
    /// - Parameters:
    ///   - pattern: A NSString containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - capture: The string matched by capture from pattern to return. Use 0 for the entire string that pattern matched.
    ///   - options: An OptionSet specified by combining various `RKXRegexOptions`. If no options are required, ignore this parameter.
    ///   - matchingOptions: An OptionSet specified by combining various `RKXMatchOptions`. If no options are required, ignore this parameter.
    /// - Returns: A NSString containing the substring of the receiver matched by capture number capture of pattern within searchRange of the receiver.
    /// - Throws: A NSError object for any issue that came up during initialization of the regular expression.
    func stringMatched(by pattern: String,
                       in searchRange: NSRange? = nil,
                       for capture: Int = 0,
                       options: RKXRegexOptions = [],
                       matchingOptions: RKXMatchOptions = [])
        throws -> String? {
            let matchedRange = try range(of: pattern, in: searchRange, for: capture, options: options, matchingOptions: matchingOptions)
            guard matchedRange != nil else { return nil }
            let substring = self[matchedRange!]
            return String(substring)
    }

    /// Returns a string created from the characters of the receiver that are in the range of the first match of `pattern` using `options` and `matchOptions` within `searchRange` of the receiver for `capture`.
    ///
    /// - Parameters:
    ///   - pattern: A NSString containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - capture: The string matched by capture from pattern to return. Use 0 for the entire string that pattern matched.
    ///   - options: An OptionSet specified by combining various `RKXRegexOptions`. If no options are required, ignore this parameter.
    ///   - matchingOptions: An OptionSet specified by combining various `RKXMatchOptions`. If no options are required, ignore this parameter.
    /// - Returns: A NSString containing the substring of the receiver matched by capture number capture of pattern within searchRange of the receiver.
    /// - Throws: A NSError object for any issue that came up during initialization of the regular expression.
    func stringMatched(by pattern: String,
                       in searchRange: Range<String.UTF16Index>,
                       for capture: Int = 0,
                       options: RKXRegexOptions = [],
                       matchingOptions: RKXMatchOptions = [])
        throws -> String? {
            let legacyRange = nsrange(from: searchRange)
            return try stringMatched(by: pattern, in: legacyRange, for: capture, options: options, matchingOptions: matchingOptions)
    }

    // MARK: stringByReplacingOccurrences(of:with:in:options:matchingOptions:)

    /// Returns a string created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` and `matchingOptions` are replaced with the contents of `template` after performing capture group substitutions.
    ///
    /// - Parameters:
    ///   - pattern: A String containing a regular expression.
    ///   - template: A String containing a string template. Can use capture groups variables.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An OptionSet of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An OptionSet of options specified by combining RKXMatchOptions flags.
    /// - Returns: A String created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` and `matchOptions` are replaced with the contents of the `template` string after performing capture group substitutions. If the substring is not matched by `pattern`, returns the characters within `searchRange` as if `substring(with:)` had been sent to the receiver.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func stringByReplacingOccurrences(of pattern: String,
                                      with template: String,
                                      in searchRange: NSRange? = nil,
                                      options: RKXRegexOptions = [],
                                      matchingOptions: RKXMatchOptions = [])
        throws -> String {
            let regex = try String.cachedRegex(for: pattern, options: options)
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return (self as NSString).substring(with: searchRange ?? stringRange) }
            var target = String(self)

            matches.reversed().forEach { match in
                let range = utf16Range(from: match.range)!
                let swap = regex.replacementString(for: match, in: self, offset: 0, template: template)
                target.replaceSubrange(range, with: swap)
            }

            return target
    }

    /// Returns a string created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` and `matchingOptions` are replaced with the contents of `template` after performing capture group substitutions.
    ///
    /// - Parameters:
    ///   - pattern: A String containing a regular expression.
    ///   - template: A String containing a string template. Can use capture groups variables.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An OptionSet of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An OptionSet of options specified by combining RKXMatchOptions flags.
    /// - Returns: A String created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` and `matchOptions` are replaced with the contents of the `template` string after performing capture group substitutions. If the substring is not matched by `pattern`, returns the characters within `searchRange` as if `substring(with:)` had been sent to the receiver.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func stringByReplacingOccurrences(of pattern: String,
                                      with template: String,
                                      in searchRange: Range<String.UTF16Index>,
                                      options: RKXRegexOptions = [],
                                      matchingOptions: RKXMatchOptions = [])
        throws -> String {
            let legacyRange = nsrange(from: searchRange)
            return try stringByReplacingOccurrences(of: pattern, with: template, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: captureCount(options:)

    /// Returns the number of captures that the regex contains.
    ///
    /// - Parameter options: An OptionSet of options specified by combining RKXRegexOptions flags.
    /// - Returns: The number of captures in the regex is returned, or `0` if the regex does not contain any captures.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func captureCount(options: RKXRegexOptions = [])
        throws -> Int {
            let regex = try String.cachedRegex(for: self, options: options)
            return regex.numberOfCaptureGroups
    }

    // MARK: isRegexValid(options:)

    /// Returns a Bool value that indicates whether the regular expression contained in the receiver is valid using `options`.
    ///
    /// - Parameter options: An OptionSet of options specified by combining RKXRegexOptions flags.
    /// - Returns: Returns a `True` if the regex is valid; `NO` otherwise.
    func isRegexValid(options: RKXRegexOptions = [])
        -> Bool {
            do {
                let _ = try String.cachedRegex(for: self, options: options)
            } catch {
                return false
            }
            
            return true
    }

    // MARK: substringsMatched(by:in:for:options:matchingOptions:)

    /// Returns an array containing all the substrings from the receiver that were matched by capture number `capture` from the regular expression `pattern` within `searchRange` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - capture: The string matched by capture from `pattern` to return.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An `Array` containing all the substrings (as Strings) from the receiver that were matched by capture number `capture` from `pattern` within `searchRange` using `options` and `matchOptions`.
    /// - Returns: Returns an empty array if `pattern` fails to match in `searchRange`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func substringsMatched(by pattern: String,
                           in searchRange: NSRange? = nil,
                           for capture: Int = 0,
                           options: RKXRegexOptions = [],
                           matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }
            let captures: [String] = matches.map({
                $0.range(at: capture).location != NSNotFound ? (self as NSString).substring(with: $0.range(at: capture)) : ""
            })

            return captures
    }

    /// Returns an array containing all the substrings from the receiver that were matched by capture number `capture` from the regular expression `pattern` within `searchRange` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - capture: The string matched by capture from `pattern` to return.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An `Array` containing all the substrings (as Strings) from the receiver that were matched by capture number `capture` from `pattern` within `searchRange` using `options` and `matchOptions`.
    /// - Returns: Returns an empty array if `pattern` fails to match in `searchRange`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func substringsMatched(by pattern: String,
                           in searchRange: Range<String.UTF16Index>,
                           for capture: Int = 0,
                           options: RKXRegexOptions = [],
                           matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = nsrange(from: searchRange)
            return try substringsMatched(by: pattern, in: legacyRange, for: capture, options: options, matchingOptions: matchingOptions)
    }

    // MARK: captureSubstringsMatched(by:in:options:matchingOptions:)

    /// Returns an array containing the substrings matched by each capture group present in `pattern` for the first match of `pattern` within `searchRange` of the receiver using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An `Array` containing the substrings (as Strings) matched by each capture group present in `pattern` for the first match of `pattern` within `searchRange` of the receiver using `options`. Array index `0` represents all of the text matched by `pattern` and subsequent array indexes contain the text matched by their respective capture group.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func captureSubstringsMatched(by pattern: String,
                                  in searchRange: NSRange? = nil,
                                  options: RKXRegexOptions = [],
                                  matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard let match = matches.first else { return [] }
            return match.substrings(from: self)
    }

    /// Returns an array containing the substrings matched by each capture group present in `pattern` for the first match of `pattern` within `searchRange` of the receiver using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An `Array` containing the substrings (as Strings) matched by each capture group present in `pattern` for the first match of `pattern` within `searchRange` of the receiver using `options`. Array index `0` represents all of the text matched by `pattern` and subsequent array indexes contain the text matched by their respective capture group.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func captureSubstringsMatched(by pattern: String,
                                  in searchRange: Range<String.UTF16Index>,
                                  options: RKXRegexOptions = [],
                                  matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = nsrange(from: searchRange)
            return try captureSubstringsMatched(by: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: arrayOfCaptureSubstringsMatched(by:in:options:matchingOptions:)

    /// Returns an array containing all the matches from the receiver that were matched by the regular expression `pattern` within `searchRange` using `options` and `matchOptions`. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: A `Array` object containing all the matches from the receiver by `pattern`. Each match result consists of a `Array` which contains all the capture groups present in `pattern`. Array index `0` represents all of the text matched by `pattern` and subsequent array indexes contain the text matched by their respective capture group. Will return an empty array if `pattern` fails to match.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func arrayOfCaptureSubstringsMatched(by pattern: String,
                                         in searchRange: NSRange? = nil,
                                         options: RKXRegexOptions = [],
                                         matchingOptions: RKXMatchOptions = [])
        throws -> [[String]] {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }
            let arrayOfCaptures: [[String]] = matches.map({
                $0.substrings(from: self)
            })

            return arrayOfCaptures
    }

    /// Returns an array containing all the matches from the receiver that were matched by the regular expression `pattern` within `searchRange` using `options` and `matchOptions`. Each match result consists of an array of the substrings matched by all the capture groups present in the regular expression.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: A `Array` object containing all the matches from the receiver by `pattern`. Each match result consists of a `Array` which contains all the capture groups present in `pattern`. Array index `0` represents all of the text matched by `pattern` and subsequent array indexes contain the text matched by their respective capture group. Will return an empty array if `pattern` fails to match.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func arrayOfCaptureSubstringsMatched(by pattern: String,
                                         in searchRange: Range<String.UTF16Index>,
                                         options: RKXRegexOptions = [],
                                         matchingOptions: RKXMatchOptions = [])
        throws -> [[String]] {
            let legacyRange = nsrange(from: searchRange)
            return try arrayOfCaptureSubstringsMatched(by: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: dictionaryMatched(by:in:options:matchingOptions:keysAndCaptures:)

    /// Creates and returns a Dictionary containing the matches constructed from the specified set of keys and captures for the first match of `pattern` within `searchRange` of the receiver using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - keysAndCaptures: A variadic array taking alternating String keys and Int capture group numbers.
    /// - Returns: A `Dictionary` containing the matched substrings constructed from the specified set of keys and captures.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression. Will also throw a `DictionaryError` object if the number of key-and-capture elements is larger than 32 distinct pairs (or 64 elements) and will also throw if there is an odd number of elements passed (implying that there are unpaired keys or capture groups).
    func dictionaryMatched(by pattern: String,
                           in searchRange: NSRange? = nil,
                           options: RKXRegexOptions = [],
                           matchingOptions: RKXMatchOptions = [],
                           keysAndCaptures: Any...)
        throws -> Dictionary<String, String> {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if keysAndCaptures.count % 2 > 0 { throw DictionaryError.unpairedKeysAndCaptures }

            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }

            let dict = try dictionaryMatched(by: pattern, in: searchRange, for: pairs, options: options, matchingOptions: matchingOptions)
            return dict
    }

    /// Creates and returns a Dictionary containing the matches constructed from the specified set of keys and captures for the first match of `pattern` within `searchRange` of the receiver using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - keysAndCaptures: A variadic array taking alternating String keys and Int capture group numbers.
    /// - Returns: A `Dictionary` containing the matched substrings constructed from the specified set of keys and captures.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression. Will also throw a `DictionaryError` object if the number of key-and-capture elements is larger than 32 distinct pairs (or 64 elements) and will also throw if there is an odd number of elements passed (implying that there are unpaired keys or capture groups).
    func dictionaryMatched(by pattern: String,
                           in searchRange: Range<String.UTF16Index>,
                           options: RKXRegexOptions = [],
                           matchingOptions: RKXMatchOptions = [],
                           keysAndCaptures: Any...)
        throws -> Dictionary<String, String> {
            let legacyRange = nsrange(from: searchRange)
            return try dictionaryMatched(by: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions, keysAndCaptures: keysAndCaptures)
    }

    fileprivate func dictionaryMatched(by pattern: String,
                                       in searchRange: NSRange? = nil,
                                       for keyAndCapturePairs: [(key: String, capture: Int)],
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [])
        throws -> Dictionary<String, String> {
            var results = [String: String]()
            try keyAndCapturePairs.forEach { pair in
                let captureRange = try range(of: pattern, in: searchRange, for: pair.capture, options: options, matchingOptions: matchingOptions)
                let substring = captureRange!.isEmpty ? "" : self[captureRange!]
                results[pair.key] = String(substring)
            }

            return results
    }

    // MARK: arrayOfDictionariesMatched(by:in:options:matchingOptions:keysAndCaptures:)

    /// Returns an Array containing all the matches in the receiver that were matched by the regular expression `pattern` within `searchRange` using `options` and `matchOptions`. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - keysAndCaptures: A variadic array taking alternating String keys and Int capture group numbers.
    /// - Returns: A `Array` object containing all the matches from the receiver by `pattern`. Each match result consists of a `Dictionary` containing that matches substrings constructed from the specified set of keys and captures.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression. Will also throw a `DictionaryError` object if the number of key-and-capture elements is larger than 32 distinct pairs (or 64 elements) and will also throw if there is an odd number of elements passed (implying that there are unpaired keys or capture groups).
    func arrayOfDictionariesMatched(by pattern: String,
                                    in searchRange: NSRange? = nil,
                                    options: RKXRegexOptions = [],
                                    matchingOptions: RKXMatchOptions = [],
                                    keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if keysAndCaptures.count % 2 > 0 { throw DictionaryError.unpairedKeysAndCaptures }
            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }

            let dictArray: [Dictionary<String, String>] = try matches.map {
                let range = $0.range(at: 0)
                let substring = (self as NSString).substring(with: range)
                let dict = try substring.dictionaryMatched(by: pattern, in: substring.stringRange, for: pairs, options: options, matchingOptions: matchingOptions)
                return dict
            }

            return dictArray
    }

    /// Returns an Array containing all the matches in the receiver that were matched by the regular expression `pattern` within `searchRange` using `options` and `matchOptions`. Each match result consists of a dictionary containing that matches substrings constructed from the specified set of keys and captures.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - keysAndCaptures: A variadic array taking alternating String keys and Int capture group numbers.
    /// - Returns: A `Array` object containing all the matches from the receiver by `pattern`. Each match result consists of a `Dictionary` containing that matches substrings constructed from the specified set of keys and captures.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression. Will also throw a `DictionaryError` object if the number of key-and-capture elements is larger than 32 distinct pairs (or 64 elements) and will also throw if there is an odd number of elements passed (implying that there are unpaired keys or capture groups).
    func arrayOfDictionariesMatched(by pattern: String,
                                    in searchRange: Range<String.UTF16Index>,
                                    options: RKXRegexOptions = [],
                                    matchingOptions: RKXMatchOptions = [],
                                    keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            let legacyRange = nsrange(from: searchRange)
            return try arrayOfDictionariesMatched(by: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions, keysAndCaptures: keysAndCaptures)
    }

    // MARK: enumerateStringsMatched(by:in:options:matchingOptions:using block:)

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes the block for each match found.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of NSRanges containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a `NSRange` equal to `{NSNotFound, 0}`.
    /// - Returns: `True` if there was no error, otherwise `false` if there were no matches.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func enumerateStringsMatched(by pattern: String,
                                 in searchRange: NSRange? = nil,
                                 options: RKXRegexOptions = [],
                                 matchingOptions: RKXMatchOptions = [],
                                 using block: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            matches.forEach { match in
                block(match.substrings(from: self), match.ranges)
            }

            return true
    }

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes the block for each match found.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of type `Range<String.UTF16Index>` containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a nil.
    /// - Returns: `True` if there was no error, otherwise `false` if there were no matches.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func enumerateStringsMatched(by pattern: String,
                                 in searchRange: Range<String.UTF16Index>,
                                 options: RKXRegexOptions = [],
                                 matchingOptions: RKXMatchOptions = [],
                                 using block: (_ strings: [String], _ ranges: [Range<String.UTF16Index>]) -> Void)
        throws -> Bool {
            let legacyRange = nsrange(from: searchRange)
            let matches = try regexMatches(for: pattern, in: legacyRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            matches.forEach { match in
                block(match.substrings(from: self), match.ranges.map({ utf16Range(from: $0)! }))
            }

            return true
    }

    // MARK: substringsSeparated(by:in:options:matchingOptions:)

    /// Returns an array containing substrings (as Strings) within `searchRange` of the receiver that have been divided by the regular expression `pattern` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An Array containing the substrings from the receiver that have been divided by `pattern`. If there is no match, returns an Array with the receiver as the single element.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func substringsSeparated(by pattern: String,
                             in searchRange: NSRange? = nil,
                             options: RKXRegexOptions = [],
                             matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [ self ] }
            let range = searchRange ?? stringRange
            var pos: Int = 0

            var substrings: [String] = matches.map {
                let subrange = NSMakeRange(pos, $0.range.location - pos)
                pos = $0.range.location + $0.range.length
                return (self as NSString).substring(with: subrange)
            }

            if pos < range.length {
                let finalSubstring = String(suffix(range.length - pos))
                substrings.append(finalSubstring)
            }

            return substrings
    }

    /// Returns an array containing substrings (as Strings) within `searchRange` of the receiver that have been divided by the regular expression `pattern` using `options` and `matchOptions`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: An Array containing the substrings from the receiver that have been divided by `pattern`. If there is no match, returns an Array with the receiver as the single element.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func substringsSeparatedBy(_ pattern: String,
                               in searchRange: Range<String.UTF16Index>,
                               options: RKXRegexOptions = [],
                               matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = nsrange(from: searchRange)
            return try substringsSeparated(by: pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: enumerateStringsSeparated(by:in:options:matchingOptions:using block:)

    /// Enumerates the strings of the receiver that have been divided by the regular expression `pattern` within `searchRange` using `options` and and `matchOptions` and executes `block` for each divided string.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of NSRanges containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a `NSRange` equal to `{NSNotFound, 0}`.
    /// - Returns: `true` if there was no error, otherwise `false` if there were no matches.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func enumerateStringsSeparated(by pattern: String,
                                   in searchRange: NSRange? = nil,
                                   options: RKXRegexOptions = [],
                                   matchingOptions: RKXMatchOptions = [],
                                   using block: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = target.stringRange
            let matches = try target.regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            let strings = try target.substringsSeparated(by: pattern, in: targetRange, options: options, matchingOptions: matchingOptions)
            var remainderRange = targetRange

            for (index, string) in strings.enumerated() {
                let range0 = (target as NSString).range(of: string, options: .backwards, range: remainderRange)
                let match = (index < strings.endIndex - 1) ? matches[index] : nil
                var rangeCaptures = Array([range0])

                if match != nil {
                    rangeCaptures.append(contentsOf: match!.ranges)
                    let substrings = rangeCaptures.map {
                        $0.location != NSNotFound ? (target as NSString).substring(with: $0) : ""
                    }

                    remainderRange = target.rangeFrom(location: rangeCaptures.last!.location)
                    block(substrings, rangeCaptures)
                }
                else {
                    let lastRange = (target as NSString).range(of: string, options: .backwards, range: remainderRange)
                    block( [ string ], [ lastRange ])
                }
            }

            return true
    }

    /// Enumerates the strings of the receiver that have been divided by the regular expression `pattern` within `searchRange` using `options` and and `matchOptions` and executes `block` for each divided string.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of type `Range<String.UTF16Index>` containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a nil.
    /// - Returns: `true` if there was no error, otherwise `false` if there were no matches.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func enumerateStringsSeparated(by pattern: String,
                                   in searchRange: Range<String.UTF16Index>,
                                   options: RKXRegexOptions = [],
                                   matchingOptions: RKXMatchOptions = [],
                                   using block: (_ strings: [String], _ ranges: [Range<String.UTF16Index>]) -> Void)
        throws -> Bool {
            let target = String(self[searchRange])
            let targetRange = target.stringRange
            let matches = try target.regexMatches(for: pattern, in: targetRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            let strings = try target.substringsSeparated(by: pattern, in: targetRange, options: options, matchingOptions: matchingOptions)
            var remainderRange = targetRange

            for (index, string) in strings.enumerated() {
                let range0 = (target as NSString).range(of: string, options: .backwards, range: remainderRange)
                let match = (index < strings.endIndex - 1) ? matches[index] : nil
                var rangeCaptures = Array([range0])

                if match != nil {
                    rangeCaptures.append(contentsOf: match!.ranges)
                    let substrings = rangeCaptures.map {
                        $0.location != NSNotFound ? (target as NSString).substring(with: $0) : ""
                    }

                    remainderRange = target.rangeFrom(location: rangeCaptures.last!.location)
                    let utf16Ranges: [Range<String.UTF16Index>] = rangeCaptures.map({ utf16Range(from: $0)! })
                    block(substrings, utf16Ranges)
                }
                else {
                    let lastRange = (target as NSString).range(of: string, options: .backwards, range: remainderRange)
                    block( [ string ], [ utf16Range(from: lastRange)! ])
                }
            }

            return true
    }

    // MARK: stringByReplacingOccurrences(of:in:options:matchingOptions:using block:)

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes `block` for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of each string returned by `block`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver and returns a String. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of NSRanges containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a `NSRange` equal to `{NSNotFound, 0}`.
    /// - Returns: A `String` created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` are replaced with the contents of the `String` returned by `block`. Returns the characters within `searchRange` as if `substringWithRange`: had been sent to the receiver if the substring is not matched by `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func stringByReplacingOccurences(of pattern: String,
                                     in searchRange: NSRange? = nil,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [],
                                     using block: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> String {
            var target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = (target as String).stringRange
            let matches = try target.regexMatches(for: pattern, in: targetRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return self }

            matches.reversed().forEach { match in
                let swap = block( match.substrings(from: self), match.ranges )
                target.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return target as String
    }

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes `block` for each match found. Returns a string created by replacing the characters that were matched in the receiver with the contents of each string returned by `block`.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver and returns a String. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of type `Range<String.UTF16Index>` containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a nil.
    /// - Returns: A `String` created from the characters within `searchRange` of the receiver in which all matches of the regular expression `pattern` using `options` are replaced with the contents of the `String` returned by `block`. Returns the characters within `searchRange` as if `substringWithRange`: had been sent to the receiver if the substring is not matched by `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    func stringByReplacingOccurences(of pattern: String,
                                     in searchRange: Range<String.UTF16Index>,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [],
                                     using block: (_ strings: [String], _ ranges: [Range<String.UTF16Index>]) -> String)
        throws -> String {
            var target = String(self[searchRange])
            let targetRange = (target as String).stringRange
            let matches = try target.regexMatches(for: pattern, in: targetRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return self }

            matches.reversed().forEach { match in
                let swap = block( match.substrings(from: self), match.ranges.map({ utf16Range(from: $0)! }) )
                target.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return target as String
    }

    // MARK: replaceOccurrences(of:with:in:options:matchingOptions:)

    /// Replaces all occurrences of the regular expression `pattern` using `options` and `matchOptions` within `searchRange` of the receiver with the contents of `template` after performing capture group substitutions, returning the number of replacements made.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - template: A `NSString` containing a string template. Can use capture groups variables.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: Returns the number of successful substitutions of the matched `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    mutating func replaceOccurrences(of pattern: String,
                                     with template: String,
                                     in searchRange: NSRange? = nil,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [])
        throws -> Int {
            let regex = try String.cachedRegex(for: pattern, options: options)
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return NSNotFound }

            matches.reversed().forEach { match in
                let swap = regex.replacementString(for: match, in: self, offset: 0, template: template)
                self.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return matches.count
    }

    /// Replaces all occurrences of the regular expression `pattern` using `options` and `matchOptions` within `searchRange` of the receiver with the contents of `template` after performing capture group substitutions, returning the number of replacements made.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - template: A `NSString` containing a string template. Can use capture groups variables.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    /// - Returns: Returns the number of successful substitutions of the matched `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    mutating func replaceOccurrences(of pattern: String,
                                     with template: String,
                                     in searchRange: Range<String.UTF16Index>,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [])
        throws -> Int {
            let legacyRange = nsrange(from: searchRange)
            return try replaceOccurrences(of: pattern, with: template, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    // MARK: replaceOccurrences(of:in:options:matchingOptions:using block:)

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes `block` for each match found. Replaces the characters that were matched with the contents of the string returned by `block`, returning the number of replacements made.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver and returns a String. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of NSRanges containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a `NSRange` equal to `{NSNotFound, 0}`.
    /// - Returns: Returns the number of successful substitutions of the matched `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    mutating func replaceOccurrences(of pattern: String,
                                     in searchRange: NSRange? = nil,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [],
                                     using block: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> Int {
            let matches = try regexMatches(for: pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return NSNotFound }

            matches.reversed().forEach { match in
                let swap = block(match.substrings(from: self), match.ranges)
                self.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return matches.count
    }

    /// Enumerates the matches in the receiver by the regular expression `pattern` within `searchRange` using `options` and `matchOptions` and executes `block` for each match found. Replaces the characters that were matched with the contents of the string returned by `block`, returning the number of replacements made.
    ///
    /// - Parameters:
    ///   - pattern: A `String` containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - options: An `OptionSet` of options specified by combining RKXRegexOptions flags.
    ///   - matchingOptions: An `OptionSet` specified by combining various `RKXMatchOptions`.
    ///   - block: The closure that is executed for each match of `pattern` in the receiver and returns a String. It takes two arguments:
    ///   - strings: An array containing the substrings (as Strings) matched by each capture group present in `pattern`. If a capture group did not match anything, it will contain a reference to an empty String.
    ///   - ranges: An array of type `Range<String.UTF16Index>` containing the ranges of eatch capture group in a given match. If a capture group did not match anything, it will contain a nil.
    /// - Returns: Returns the number of successful substitutions of the matched `pattern`.
    /// - Throws: A `NSError` object for any issue that came up during initialization of the regular expression.
    mutating func replaceOccurrences(of pattern: String,
                                     in searchRange: Range<String.UTF16Index>,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [],
                                     using block: (_ strings: [String], _ ranges: [Range<String.UTF16Index>]) -> String)
        throws -> Int {
            let legacyRange = nsrange(from: searchRange)
            let matches = try regexMatches(for: pattern, in: legacyRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return NSNotFound }

            matches.reversed().forEach { match in
                let swap = block(match.substrings(from: self), match.ranges.map({ utf16Range(from: $0)! }))
                self.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return matches.count
    }
}
