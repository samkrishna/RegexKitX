//
//  RegexKitLite5.swift
//  RegexKitLite5
//
//  Created by Sam Krishna on 8/27/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

import Foundation

infix operator =~

public func =~ (string: String, regex: String) -> Bool {
    do {
        let result = try string.isMatchedBy(regex)
        return result
    } catch {
        return false
    }
}

public func ~= (regex: String, string: String) -> Bool {
    do {
        let result = try string.isMatchedBy(regex)
        return result
    } catch {
        return false
    }
}

public struct RKLRegexOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let RKLCaseless              = RKLRegexOptions(rawValue: 1 << 0)
    public static let RKLComments              = RKLRegexOptions(rawValue: 1 << 1)
    public static let RKLIgnoreMetacharacters  = RKLRegexOptions(rawValue: 1 << 2)
    public static let RKLDotAll                = RKLRegexOptions(rawValue: 1 << 3)
    public static let RKLMultiline             = RKLRegexOptions(rawValue: 1 << 4)
    public static let RKLUseUnixLineSeparators = RKLRegexOptions(rawValue: 1 << 5)
    public static let RKLUnicodeWordBoundaries = RKLRegexOptions(rawValue: 1 << 6)

    fileprivate func coerceToNSRegularExpressionOptions() -> NSRegularExpression.Options {
        var options = NSRegularExpression.Options()
        if contains(.RKLCaseless) { options.insert(.caseInsensitive) }
        if contains(.RKLComments) { options.insert(.allowCommentsAndWhitespace) }
        if contains(.RKLIgnoreMetacharacters) { options.insert(.ignoreMetacharacters) }
        if contains(.RKLDotAll) { options.insert(.dotMatchesLineSeparators) }
        if contains(.RKLMultiline) { options.insert(.anchorsMatchLines) }
        if contains(.RKLUseUnixLineSeparators) { options.insert(.useUnixLineSeparators) }
        if contains(.RKLUnicodeWordBoundaries) { options.insert(.useUnicodeWordBoundaries) }
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

    struct RegexKitLite5 {
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

    fileprivate static func cacheKeyFor(_ regexPattern: String, options: RKLRegexOptions)
        -> String {
            let key = String("\(regexPattern)_\(options.rawValue)")
            return key
    }

    fileprivate static func cachedRegexFor(_ regexPattern: String, options: RKLRegexOptions)
        throws -> NSRegularExpression {
            let key = cacheKeyFor(regexPattern, options: options)
            var regex = Thread.current.threadDictionary[key] as? NSRegularExpression

            if regex == nil {
                let nsregexopts = options.coerceToNSRegularExpressionOptions()
                regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
                Thread.current.threadDictionary[key] = regex
            }

            return regex!
    }

    func isMatchedBy(_ regexPattern: String,
                     searchRange: NSRange? = nil,
                     options: RKLRegexOptions = [],
                     matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Bool {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return match != nil
    }

    func rangeOf(_ regexPattern: String,
                 searchRange: NSRange? = nil,
                 capture: Int = 0,
                 options: RKLRegexOptions = [],
                 matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> NSRange {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return match?.range(at: capture) ?? RegexKitLite5.NSNotFoundRange
    }

    func stringByMatching(_ regexPattern: String,
                          searchRange: NSRange? = nil,
                          capture: Int = 0,
                          options: RKLRegexOptions = [],
                          matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String? {
            let range = try rangeOf(regexPattern, searchRange: searchRange, capture: capture, options: options, matchingOptions: matchingOptions)
            if NSEqualRanges(range, RegexKitLite5.NSNotFoundRange) { return nil }
            let substring = (self as NSString).substring(with: range)
            return substring
    }

    func stringByReplacingOccurrencesOf(_ regexPattern: String,
                                        replacement: String,
                                        searchRange: NSRange? = nil,
                                        options: RKLRegexOptions = [],
                                        matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return (self as NSString).substring(with: searchRange ?? stringRange) }
            var target = String(self)

            matches.reversed().forEach { match in
                let range = utf16Range(from: match.range)!
                target.replaceSubrange(range, with: replacement)
            }

            return target
    }

    func captureCount(options: RKLRegexOptions = [])
        throws -> Int {
            let regex = try String.cachedRegexFor(self, options: options)
            return regex.numberOfCaptureGroups
    }

    func isRegexValid(options: RKLRegexOptions = [])
        throws -> Bool {
            let _ = try String.cachedRegexFor(self, options: options)
            return true
    }

    func componentsMatchedBy(_ regexPattern: String,
                             searchRange: NSRange? = nil,
                             capture: Int = 0,
                             options: RKLRegexOptions = [],
                             matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }
            let captures: [String] = matches.map({
                $0.range(at: capture).location != NSNotFound ? (self as NSString).substring(with: $0.range(at: capture)) : ""
            })

            return captures
    }

    func captureComponentsMatchedBy(_ regexPattern: String,
                                    searchRange: NSRange? = nil,
                                    options: RKLRegexOptions = [],
                                    matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            guard let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange) else { return [] }

            let captures = match.captureRanges.map({
                $0.location != NSNotFound ? (self as NSString).substring(with: $0) : ""
            })

            return captures
    }

    func arrayOfCaptureComponentsMatchedBy(_ regexPattern: String,
                                           searchRange: NSRange? = nil,
                                           options: RKLRegexOptions = [],
                                           matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [[String]] {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let arrayOfCaptures: [[String]] = matches.map({
                $0.captureRanges.map({
                    $0.location != NSNotFound ? (self as NSString).substring(with: $0) : ""
                })
            })

            return arrayOfCaptures
    }

    fileprivate func _dictionaryByMatching(_ regexPattern: String,
                                           searchRange: NSRange? = nil,
                                           options: RKLRegexOptions = [],
                                           matchingOptions: NSRegularExpression.MatchingOptions = [],
                                           keysAndCapturePairs: [(key: String, capture: Int)])
        throws -> Dictionary<String, String> {
            var results = [String: String]()
            try keysAndCapturePairs.forEach { pair in
                let captureRange = try rangeOf(regexPattern,
                                               searchRange: searchRange,
                                               capture: pair.capture,
                                               options: options,
                                               matchingOptions: matchingOptions)
                results[pair.key] = (captureRange.length > 0) ? (self as NSString).substring(with: captureRange) : ""
            }

            return results
    }


    func dictionaryByMatching(_ regexPattern: String,
                              searchRange: NSRange? = nil,
                              options: RKLRegexOptions = [],
                              matchingOptions: NSRegularExpression.MatchingOptions = [],
                              keysAndCaptures: Any...)
        throws -> Dictionary<String, String> {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if (keysAndCaptures.count % 2) > 0 { throw DictionaryError.unpairedKeysAndCaptures }

            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }

            let dict = try _dictionaryByMatching(regexPattern, searchRange: searchRange, options: options, matchingOptions: matchingOptions, keysAndCapturePairs: pairs)
            return dict
    }

    func arrayOfDictionariesByMatching(_ regexPattern: String,
                                       searchRange: NSRange? = nil,
                                       options: RKLRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       keysAndCaptures: Any...)
        throws -> [Dictionary<String, String>] {
            assert(keysAndCaptures.count > 0)
            if keysAndCaptures.count > 64 { throw DictionaryError.tooManyKeysAndCaptures }
            if (keysAndCaptures.count % 2) > 0 { throw DictionaryError.unpairedKeysAndCaptures }

            let pairs = stride(from: 0, to: keysAndCaptures.count, by: 2).map {
                (key: keysAndCaptures[$0] as! String, capture: keysAndCaptures[$0.advanced(by: 1)] as! Int)
            }

            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let dictArray: [Dictionary<String, String>] = try matches.map {
                let range = $0.range(at: 0)
                let subtring = (self as NSString).substring(with: range)
                let dict = try subtring._dictionaryByMatching(regexPattern, searchRange: subtring.stringRange, options: options, matchingOptions: matchingOptions, keysAndCapturePairs: pairs)
                return dict
            }

            return dictArray
    }

    func enumerateStringsMatchedBy(_ regexPattern: String,
                                   searchRange: NSRange? = nil,
                                   options: RKLRegexOptions = [],
                                   matchingOptions: NSRegularExpression.MatchingOptions = [],
                                   _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return false }

            matches.forEach { match in
                let substrings = match.captureRanges.map({ ($0.location != NSNotFound) ? (self as NSString).substring(with: $0) : "" })
                closure(substrings, match.captureRanges)
            }

            return true
    }

    func componentsSeparatedBy(_ regexPattern: String,
                               searchRange: NSRange? = nil,
                               options: RKLRegexOptions = [],
                               matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
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

    func enumerateStringsSeparatedBy(_ regexPattern: String,
                                     searchRange: NSRange? = nil,
                                     options: RKLRegexOptions = [],
                                     matchingOptions: NSRegularExpression.MatchingOptions = [],
                                     _ closure: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let target = (self as NSString).substring(with: searchRange ?? stringRange)
            let targetRange = target.stringRange
            let matches = regex.matches(in: target, options: matchingOptions, range: targetRange)
            if matches.isEmpty { return false }
            let strings = try target.componentsSeparatedBy(regexPattern, searchRange: targetRange, options: options, matchingOptions: matchingOptions)
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

    func stringByReplacingOccurencesOf(_ regexPattern: String,
                                       searchRange: NSRange? = nil,
                                       options: RKLRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> String {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
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

    mutating func replaceOccurrencesOf(_ regexPattern: String,
                                       replacement: String,
                                       searchRange: NSRange? = nil,
                                       options: RKLRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Int {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: (self as String), options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return NSNotFound }
            var count = 0

            matches.reversed().forEach { match in
                let range = utf16Range(from: match.range)!
                self.replaceSubrange(range, with: replacement)
                count += 1
            }

            return count
    }

    mutating func replaceOccurrencesOf(_ regexPattern: String,
                                       searchRange: NSRange? = nil,
                                       options: RKLRegexOptions = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = [],
                                       _ closure: (_ strings: [String], _ ranges: [NSRange]) -> String)
        throws -> Int {
            let regex = try String.cachedRegexFor(regexPattern, options: options)
            let matches = regex.matches(in: (self as String), options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return NSNotFound }
            var count = 0

            matches.reversed().forEach { match in
                let captures = match.captureRanges.map({ $0.location != NSNotFound ? (self as NSString).substring(with: $0) : "" })
                let replacement = closure(captures, match.captureRanges)
                let range = utf16Range(from: match.range)!
                self.replaceSubrange(range, with: replacement)
                count += 1
            }

            return count
    }
}
