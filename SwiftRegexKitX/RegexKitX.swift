//
//  RegexKitX.swift
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

enum DictionaryError: Error {
    case tooManyKeysAndCaptures
    case unpairedKeysAndCaptures
}

public extension NSTextCheckingResult {
    var captureRanges: [NSRange] {
        var _ranges = [NSRange]()

        for i in 0...(self.numberOfRanges - 1) {
            let captureRange = self.range(at: i)
            _ranges.append(captureRange)
        }

        return _ranges
    }
}

public extension String {
    var stringRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    struct RKX {
        static let NSNotFoundRange = NSRange(location: NSNotFound, length: 0)
    }

    func rangeFrom(location: Int)
        -> NSRange {
            let deltaLength = (self as NSString).length - location
            return NSRange(location: location, length: deltaLength)
    }

    private func utf16Range(from range: NSRange) -> Range<String.UTF16Index>? {
        return Range(range, in: self)
    }

    fileprivate static func cacheKeyFor(_ pattern: String, options: RKXRegexOptions)
        -> String {
            let key = String("\(pattern)_\(options.rawValue)")
            return key
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

    func matches(_ pattern: String,
                 in searchRange: NSRange? = nil,
                 options: RKXRegexOptions = [],
                 matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Bool {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return match != nil
    }

    func rangeOf(_ pattern: String,
                 in searchRange: NSRange? = nil,
                 for capture: Int = 0,
                 options: RKXRegexOptions = [],
                 matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> NSRange {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return match?.range(at: capture) ?? RKX.NSNotFoundRange
    }

    func stringByMatching(_ pattern: String,
                          in searchRange: NSRange? = nil,
                          for capture: Int = 0,
                          options: RKXRegexOptions = [],
                          matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String? {
            let range = try rangeOf(pattern, in: searchRange, for: capture, options: options, matchingOptions: matchingOptions)
            if NSEqualRanges(range, RKX.NSNotFoundRange) { return nil }
            let substring = (self as NSString).substring(with: range)
            return substring
    }

    func stringByReplacingOccurrencesOf(_ pattern: String,
                                        with template: String,
                                        in searchRange: NSRange? = nil,
                                        options: RKXRegexOptions = [],
                                        matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return (self as NSString).substring(with: searchRange ?? stringRange) }
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
                             matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }
            let captures: [String] = matches.map({
                $0.range(at: capture).location != NSNotFound ? (self as NSString).substring(with: $0.range(at: capture)) : ""
            })

            return captures
    }

    func captureComponentsMatchedBy(_ pattern: String,
                                    in searchRange: NSRange? = nil,
                                    options: RKXRegexOptions = [],
                                    matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(pattern, options: options)
            guard let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange) else { return [] }

            let captures = match.captureRanges.map({
                $0.location != NSNotFound ? (self as NSString).substring(with: $0) : ""
            })

            return captures
    }

    func arrayOfCaptureComponentsMatchedBy(_ pattern: String,
                                           in searchRange: NSRange? = nil,
                                           options: RKXRegexOptions = [],
                                           matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [[String]] {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let arrayOfCaptures: [[String]] = matches.map({
                $0.captureRanges.map({
                    $0.location != NSNotFound ? (self as NSString).substring(with: $0) : ""
                })
            })

            return arrayOfCaptures
    }

    fileprivate func dictionaryByMatching(_ pattern: String,
                                          in searchRange: NSRange? = nil,
                                          for keyAndCapturePairs: [(key: String, capture: Int)],
                                          options: RKXRegexOptions = [],
                                          matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Dictionary<String, String> {
            var results = [String: String]()
            try keyAndCapturePairs.forEach { pair in
                let captureRange = try rangeOf(pattern, in: searchRange, for: pair.capture, options: options, matchingOptions: matchingOptions)
                results[pair.key] = (captureRange.length > 0) ? (self as NSString).substring(with: captureRange) : ""
            }

            return results
    }


    func dictionaryByMatching(_ pattern: String,
                              in searchRange: NSRange? = nil,
                              options: RKXRegexOptions = [],
                              matchingOptions: NSRegularExpression.MatchingOptions = [],
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
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if (keysAndCaptures.count % 2) > 0 { throw DictionaryError.unpairedKeysAndCaptures }

            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }

            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let dictArray: [Dictionary<String, String>] = try matches.map {
                let range = $0.range(at: 0)
                let subtring = (self as NSString).substring(with: range)
                let dict = try subtring.dictionaryByMatching(pattern, in: subtring.stringRange, for: pairs, options: options, matchingOptions: matchingOptions)
                return dict
            }

            return dictArray
    }

    func enumerateStringsMatchedBy(_ pattern: String,
                                   in searchRange: NSRange? = nil,
                                   options: RKXRegexOptions = [],
                                   matchingOptions: NSRegularExpression.MatchingOptions = [],
                                   _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return false }

            matches.forEach { match in
                let substrings = match.captureRanges.map({ ($0.location != NSNotFound) ? (self as NSString).substring(with: $0) : "" })
                closure(substrings, match.captureRanges)
            }

            return true
    }

    func componentsSeparatedBy(_ pattern: String,
                               in searchRange: NSRange? = nil,
                               options: RKXRegexOptions = [],
                               matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let range = searchRange ?? stringRange
            let matches = regex.matches(in: self, options: matchingOptions, range: range)
            if matches.isEmpty { return [ self ] }
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
                                     matchingOptions: NSRegularExpression.MatchingOptions = [],
                                     _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = target.stringRange
            let matches = regex.matches(in: target, options: matchingOptions, range: targetRange)
            if matches.isEmpty { return false }
            let strings = try target.componentsSeparatedBy(pattern, in: targetRange, options: options, matchingOptions: matchingOptions)
            var remainderRange = targetRange

            for (index, string0) in strings.enumerated() {
                let range0 = (target as NSString).range(of: string0, options: .backwards, range: remainderRange)
                let match = (index < strings.endIndex - 1) ? matches[index] : nil
                var rangeCaptures = Array([range0])

                if match != nil {
                    rangeCaptures.append(contentsOf: match!.captureRanges)
                    let substrings = rangeCaptures.map {
                        $0.location != NSNotFound ? (target as NSString).substring(with: $0) : ""
                    }

                    remainderRange = target.rangeFrom(location: rangeCaptures.last!.location)
                    closure(substrings, rangeCaptures)
                }
                else {
                    let lastRange = (target as NSString).range(of: string0, options: .backwards, range: remainderRange)
                    closure( [ string0 ], [ lastRange ])
                }
            }

            return true
    }

    func stringByReplacingOccurencesOf(_ pattern: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> String {
            let regex = try String.cachedRegexFor(pattern, options: options)
            var target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = (target as String).stringRange
            let matches = regex.matches(in: (target as String), options: matchingOptions, range: targetRange)
            if matches.isEmpty { return self }

            matches.reversed().forEach { match in
                let substrings = match.captureRanges.map( { $0.location != NSNotFound ? (self as NSString).substring(with: $0) : "" })
                let replacement = closure( substrings, match.captureRanges )
                let range = utf16Range(from: match.range)!
                target.replaceSubrange(range, with: replacement)
            }

            return target as String
    }

    mutating func replaceOccurrencesOf(_ pattern: String,
                                       with template: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Int {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: (self as String), options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return NSNotFound }
            var count = 0

            matches.reversed().forEach { match in
                let range = utf16Range(from: match.range)!
                let swap = regex.replacementString(for: match, in: self, offset: 0, template: template)
                self.replaceSubrange(range, with: swap)
                count += 1
            }

            return count
    }

    mutating func replaceOccurrencesOf(_ pattern: String,
                                       in searchRange: NSRange? = nil,
                                       options: RKXRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> Int {
            let regex = try String.cachedRegexFor(pattern, options: options)
            let matches = regex.matches(in: (self as String), options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return NSNotFound }
            var count = 0

            matches.reversed().forEach { match in
                let captures = match.captureRanges.map({ $0.location != NSNotFound ? (self as NSString).substring(with: $0) : "" })
                let swap = closure(captures, match.captureRanges)
                let range = utf16Range(from: match.range)!
                self.replaceSubrange(range, with: swap)
                count += 1
            }

            return count
    }
}
