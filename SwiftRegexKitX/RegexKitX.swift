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
    func legacyNSRange(from range: Range<String.UTF16Index>?)
        -> NSRange {
        guard range != nil else { return NSMakeRange(NSNotFound, 0) }
        return NSRange(range!, in: self)
    }

    func sausageMakingLegacyNSRange(from range: Range<String.UTF16Index>?)
        -> NSRange {
            guard range != nil else { return NSMakeRange(NSNotFound, 0) }
            let lowerBound = range?.lowerBound.samePosition(in: utf16)
            let upperBound = range?.upperBound.samePosition(in: utf16)
            let location = utf16.distance(from: utf16.startIndex, to: lowerBound!)
            let length = utf16.distance(from: lowerBound!, to: upperBound!)
            return NSMakeRange(location, length)
    }

    fileprivate static func cacheKeyFor(_ pattern: String, options: RKXRegexOptions)
        -> String {
            let key = String("\(pattern)_\(options.rawValue)")
            return key
    }

    fileprivate func matchesFor(_ pattern: String,
                                in range: NSRange? = nil,
                                options: RKXRegexOptions = [],
                                matchOptions: RKXMatchOptions = [])
        throws -> [NSTextCheckingResult] {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matchingOpts = matchOptions.coerceToNSMatchingOptions()
            let matches = regex.matches(in: self, options: matchingOpts, range: range ?? stringRange)
            return matches
    }

    fileprivate static func cachedRegexFor(_ pattern: String, options: RKXRegexOptions)
        throws -> NSRegularExpression {
            let key = cacheKeyFor(pattern, options: options)
            var regex = Thread.current.threadDictionary[key] as? NSRegularExpression

            if regex == nil {
                let nsregexopts = options.coerceToNSRegularExpressionOptions()
                regex = try NSRegularExpression(pattern: pattern, options: nsregexopts)
                Thread.current.threadDictionary[key] = regex
            }

            return regex!
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
                 in searchRange: NSRange? = nil,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Bool {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            return true
    }

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
    func rangeOf(_ pattern: String,
                 in searchRange: NSRange? = nil,
                 for capture: Int = 0,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Range<String.UTF16Index>? {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard let match = matches.first else { return nil }
            let range = utf16Range(from: match.range(at: capture))
            return range
    }

    /// Returns a string created from the characters of the receiver that are in the range of the first match of `pattern` using `options` and `matchOptions` within `searchRange` of the receiver for `capture`.
    ///
    /// - Parameters:
    ///   - pattern: A @c NSString containing a regular expression.
    ///   - searchRange: The range of the receiver to search.
    ///   - capture: The string matched by capture from @c pattern to return. Use @c 0 for the entire string that @c pattern matched.
    ///   - options: An OptionSet specified by combining various `RKXRegexOptions`. If no options are required, ignore this parameter.
    ///   - matchingOptions: An OptionSet specified by combining various `RKXMatchOptions`. If no options are required, ignore this parameter.
    /// - Returns: A @c NSString containing the substring of the receiver matched by capture number capture of @c pattern within @c searchRange of the receiver.
    /// - Throws: A NSError object for any issue that came up during initialization of the regular expression.
    func stringByMatching(_ pattern: String,
                          in searchRange: NSRange? = nil,
                          for capture: Int = 0,
                          options: RKXRegexOptions = [],
                          matchingOptions: RKXMatchOptions = [])
        throws -> String? {
            let range = try rangeOf(pattern, in: searchRange, for: capture, options: options, matchingOptions: matchingOptions)
            guard range != nil else { return nil }
            let substring = self[range!]
            return String(substring)
    }

    func stringByReplacingOccurrencesOf(_ pattern: String,
                                        with template: String,
                                        in searchRange: NSRange? = nil,
                                        options: RKXRegexOptions = [],
                                        matchingOptions: RKXMatchOptions = [])
        throws -> String {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return (self as NSString).substring(with: searchRange ?? stringRange) }
            var target = String(self)

            matches.reversed().forEach { match in
                let range = utf16Range(from: match.range)!
                let swap = regex.replacementString(for: match, in: self, offset: 0, template: template)
                target.replaceSubrange(range, with: swap)
            }

            return target
    }

    func captureCount(options: RKXRegexOptions = [])
        throws -> Int {
            let regex = try String.cachedRegexFor(self, options: options)
            return regex.numberOfCaptureGroups
    }

    func isRegexValid(options: RKXRegexOptions = [])
        -> Bool {
            do {
                let _ = try String.cachedRegexFor(self, options: options)
            } catch {
                return false
            }
            
            return true
    }

    func componentsMatchedBy(_ pattern: String,
                             in searchRange: NSRange? = nil,
                             for capture: Int = 0,
                             options: RKXRegexOptions = [],
                             matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }
            let captures: [String] = matches.map({
                $0.range(at: capture).location != NSNotFound ? (self as NSString).substring(with: $0.range(at: capture)) : ""
            })

            return captures
    }

    func captureComponentsMatchedBy(_ pattern: String,
                                    in searchRange: NSRange? = nil,
                                    options: RKXRegexOptions = [],
                                    matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard let match = matches.first else { return [] }
            return match.substrings(from: self)
    }

    func arrayOfCaptureComponentsMatchedBy(_ pattern: String,
                                           in searchRange: NSRange? = nil,
                                           options: RKXRegexOptions = [],
                                           matchingOptions: RKXMatchOptions = [])
        throws -> [[String]] {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }
            let arrayOfCaptures: [[String]] = matches.map({
                $0.substrings(from: self)
            })

            return arrayOfCaptures
    }

    fileprivate func dictionaryByMatching(_ pattern: String,
                                          in searchRange: NSRange? = nil,
                                          for keyAndCapturePairs: [(key: String, capture: Int)],
                                          options: RKXRegexOptions = [],
                                          matchingOptions: RKXMatchOptions = [])
        throws -> Dictionary<String, String> {
            var results = [String: String]()
            try keyAndCapturePairs.forEach { pair in
                let captureRange = try rangeOf(pattern, in: searchRange, for: pair.capture, options: options, matchingOptions: matchingOptions)
                let substring = captureRange!.isEmpty ? "" : self[captureRange!]
                results[pair.key] = String(substring)
            }

            return results
    }

    func dictionaryByMatching(_ pattern: String,
                              in searchRange: NSRange? = nil,
                              options: RKXRegexOptions = [],
                              matchingOptions: RKXMatchOptions = [],
                              keysAndCaptures: Any...)
        throws -> Dictionary<String, String> {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if (keysAndCaptures.count % 2) > 0 { throw DictionaryError.unpairedKeysAndCaptures }

            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }

            let dict = try dictionaryByMatching(pattern, in: searchRange, for: pairs, options: options, matchingOptions: matchingOptions)
            return dict
    }

    func arrayOfDictionariesByMatching(_ pattern: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [],
                                       keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if (keysAndCaptures.count % 2) > 0 { throw DictionaryError.unpairedKeysAndCaptures }
            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [] }

            let dictArray: [Dictionary<String, String>] = try matches.map {
                let range = $0.range(at: 0)
                let substring = (self as NSString).substring(with: range)
                let dict = try substring.dictionaryByMatching(pattern, in: substring.stringRange, for: pairs, options: options, matchingOptions: matchingOptions)
                return dict
            }

            return dictArray
    }

    // enumerateStringsMatchedBy() will take a little work. Needs to be thoughtful about
    // passing Range<String.UTF16Index> in both searchRange: and ranges: paramaters

    func enumerateStringsMatchedBy(_ pattern: String,
                                   in searchRange: NSRange? = nil,
                                   options: RKXRegexOptions = [],
                                   matchingOptions: RKXMatchOptions = [],
                                   _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            matches.forEach { match in
                closure(match.substrings(from: self), match.ranges)
            }

            return true
    }

    func componentsSeparatedBy(_ pattern: String,
                               in searchRange: NSRange? = nil,
                               options: RKXRegexOptions = [],
                               matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return [ self ] }
            let range = searchRange ?? stringRange
            var pos: Int = 0

            var substrings: [String] = matches.map {
                let subrange = NSMakeRange(pos, $0.range.location - pos)
                pos = $0.range.location + $0.range.length
                return (self as NSString).substring(with: subrange)
            }

            if pos < range.length {
                let finalSubstring = String(characters.suffix(range.length - pos))
                substrings.append(finalSubstring)
            }

            return substrings
    }

    func enumerateStringsSeparatedBy(_ pattern: String,
                                     in searchRange: NSRange? = nil,
                                     options: RKXRegexOptions = [],
                                     matchingOptions: RKXMatchOptions = [],
                                     _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = target.stringRange
            let matches = try target.matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return false }
            let strings = try target.componentsSeparatedBy(pattern, in: targetRange, options: options, matchingOptions: matchingOptions)
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
                    closure(substrings, rangeCaptures)
                }
                else {
                    let lastRange = (target as NSString).range(of: string, options: .backwards, range: remainderRange)
                    closure( [ string ], [ lastRange ])
                }
            }

            return true
    }

    func stringByReplacingOccurencesOf(_ pattern: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> String {
            var target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = (target as String).stringRange
            let matches = try target.matchesFor(pattern, in: targetRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return self }

            matches.reversed().forEach { match in
                let swap = closure( match.substrings(from: self), match.ranges )
                target.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return target as String
    }

    mutating func replaceOccurrencesOf(_ pattern: String,
                                       with template: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [])
        throws -> Int {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return NSNotFound }

            matches.reversed().forEach { match in
                let swap = regex.replacementString(for: match, in: self, offset: 0, template: template)
                self.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return matches.count
    }

    mutating func replaceOccurrencesOf(_ pattern: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> Int {
            let matches = try matchesFor(pattern, in: searchRange, options: options, matchOptions: matchingOptions)
            guard !matches.isEmpty else { return NSNotFound }

            matches.reversed().forEach { match in
                let swap = closure(match.substrings(from: self), match.ranges)
                self.replaceSubrange(utf16Range(from: match.range)!, with: swap)
            }

            return matches.count
    }

    // MARK: Required use of searchRange: as Range<String.UTF16Index> type
    func arrayOfCaptureComponentsMatchedBy(_ pattern: String,
                                           in searchRange: Range<String.UTF16Index>,
                                           options: RKXRegexOptions = [],
                                           matchingOptions: RKXMatchOptions = [])
        throws -> [[String]] {
            let legacyRange = legacyNSRange(from: searchRange)
            return try arrayOfCaptureComponentsMatchedBy(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    func arrayOfDictionariesByMatching(_ pattern: String,
                                       in searchRange: Range<String.UTF16Index>,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [],
                                       keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            let legacyRange = legacyNSRange(from: searchRange)
            return try arrayOfDictionariesByMatching(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions, keysAndCaptures: keysAndCaptures)
    }

    func captureComponentsMatchedBy(_ pattern: String,
                                    in searchRange: Range<String.UTF16Index>,
                                    options: RKXRegexOptions = [],
                                    matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = legacyNSRange(from: searchRange)
            return try captureComponentsMatchedBy(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    func componentsMatchedBy(_ pattern: String,
                             in searchRange: Range<String.UTF16Index>,
                             for capture: Int = 0,
                             options: RKXRegexOptions = [],
                             matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = legacyNSRange(from: searchRange)
            return try componentsMatchedBy(pattern, in: legacyRange, for: capture, options: options, matchingOptions: matchingOptions)
    }

    func componentsSeparatedBy(_ pattern: String,
                               in searchRange: Range<String.UTF16Index>,
                               options: RKXRegexOptions = [],
                               matchingOptions: RKXMatchOptions = [])
        throws -> [String] {
            let legacyRange = legacyNSRange(from: searchRange)
            return try componentsSeparatedBy(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    func dictionaryByMatching(_ pattern: String,
                              in searchRange: Range<String.UTF16Index>,
                              options: RKXRegexOptions = [],
                              matchingOptions: RKXMatchOptions = [],
                              keysAndCaptures: Any...)
        throws -> Dictionary<String, String> {
            let legacyRange = legacyNSRange(from: searchRange)
            return try dictionaryByMatching(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions, keysAndCaptures: keysAndCaptures)
    }

    func matches(_ pattern: String,
                 in searchRange: Range<String.UTF16Index>,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Bool {
            let legacyRange = legacyNSRange(from: searchRange)
            return try matches(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    func rangeOf(_ pattern: String,
                 in searchRange: Range<String.UTF16Index>,
                 for capture: Int = 0,
                 options: RKXRegexOptions = [],
                 matchingOptions: RKXMatchOptions = [])
        throws -> Range<String.UTF16Index>? {
            let legacyRange = legacyNSRange(from: searchRange)
            return try rangeOf(pattern, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    func stringByMatching(_ pattern: String,
                          in searchRange: Range<String.UTF16Index>,
                          for capture: Int = 0,
                          options: RKXRegexOptions = [],
                          matchingOptions: RKXMatchOptions = [])
        throws -> String? {
            let legacyRange = legacyNSRange(from: searchRange)
            return try stringByMatching(pattern, in: legacyRange, for: capture, options: options, matchingOptions: matchingOptions)
    }

    func stringByReplacingOccurrencesOf(_ pattern: String,
                                        with template: String,
                                        in searchRange: Range<String.UTF16Index>,
                                        options: RKXRegexOptions = [],
                                        matchingOptions: RKXMatchOptions = [])
        throws -> String {
            let legacyRange = legacyNSRange(from: searchRange)
            return try stringByReplacingOccurrencesOf(pattern, with: template, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

    mutating func replaceOccurrencesOf(_ pattern: String,
                                       with template: String,
                                       in searchRange: Range<String.UTF16Index>,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: RKXMatchOptions = [])
        throws -> Int {
            let legacyRange = legacyNSRange(from: searchRange)
            return try replaceOccurrencesOf(pattern, with: template, in: legacyRange, options: options, matchingOptions: matchingOptions)
    }

}
