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

extension NSRange {
    func indexingRange(for string: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        guard let fromUTFIndex = string.utf16.index(string.utf16.startIndex, offsetBy: location, limitedBy: string.utf16.endIndex) else { return nil }
        guard let toUTFIndex = string.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: string.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: string) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: string) else { return nil }
        return fromIndex ..< toIndex
    }
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
}

public extension String {
    var stringRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    struct CustomRange {
        static let NSNotFoundRange = NSRange(location: NSNotFound, length: 0)
        static let NSTerminationRange = NSRange(location: NSNotFound, length: LONG_MAX)
    }

    func isMatchedBy(_ regexPattern: String,
                     searchRange: NSRange? = nil,
                     options: RKLRegexOptions = [],
                     matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> Bool {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return (match != nil)
    }

    func rangeOf(_ regexPattern: String,
                 searchRange: NSRange? = nil,
                 capture: Int = 0,
                 options: RKLRegexOptions = [],
                 matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> NSRange {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            return match?.range(at: capture) ?? NSMakeRange(NSNotFound, 0)
    }

    func stringByMatching(_ regexPattern: String,
                          searchRange: NSRange? = nil,
                          capture: Int = 0,
                          options: RKLRegexOptions = [],
                          matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String? {
            let range = try rangeOf(regexPattern, searchRange: searchRange, capture: capture, options: options, matchingOptions: matchingOptions)
            if NSEqualRanges(range, CustomRange.NSNotFoundRange) { return nil }
            let substring = (self as NSString).substring(with: range)
            return substring
    }

    func stringByReplacingOccurrencesOf(_ regexPattern: String,
                                        replacement: String,
                                        searchRange: NSRange? = nil,
                                        options: RKLRegexOptions = [],
                                        matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> String {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return (self as NSString).substring(with: searchRange ?? stringRange) }
            var target = String(self)

            for match in matches.reversed() {
                let range = match.range.indexingRange(for: self)
                target.replaceSubrange(range!, with: replacement)
            }

            return target
    }

    func captureCount(options: RKLRegexOptions = [])
        throws -> Int {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: self, options: nsregexopts)
            return regex.numberOfCaptureGroups
    }

    func isRegexValid(options: RKLRegexOptions = [])
        throws -> Bool {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let _ = try NSRegularExpression(pattern: self, options: nsregexopts)
            return true
    }

    func componentsMatchedBy(_ regexPattern: String,
                             searchRange: NSRange? = nil,
                             capture: Int = 0,
                             options: RKLRegexOptions = [],
                             matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
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
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            guard let match = regex.firstMatch(in: self, options: matchingOptions, range: searchRange ?? stringRange) else { return [] }

            let captures = match.ranges.map({
                ($0.location != NSNotFound) ? (self as NSString).substring(with: $0) : ""
            })

            return captures
    }

    func arrayOfCaptureComponentsMatchedBy(_ regexPattern: String,
                                           searchRange: NSRange? = nil,
                                           options: RKLRegexOptions = [],
                                           matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [[String]] {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let arrayOfCaptures: [[String]] = matches.map({
                $0.ranges.map({ ($0.location != NSNotFound) ? (self as NSString).substring(with: $0) : "" })
            })

            return arrayOfCaptures
    }

    func dictionaryByMatching(_ regexPattern: String,
                              searchRange: NSRange? = nil,
                              options: RKLRegexOptions = [],
                              matchingOptions: NSRegularExpression.MatchingOptions = [],
                              keysAndCapturePairs: [(key: String, capture: Int)])
        throws -> Dictionary<String, String> {
            var results = [String: String]()
            for pair in keysAndCapturePairs {
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

            let dict = try dictionaryByMatching(regexPattern, searchRange: searchRange, options: options, matchingOptions: matchingOptions, keysAndCapturePairs: pairs)
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

            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return [] }

            let dictArray: [Dictionary<String, String>] = try matches.map {
                let range = $0.range(at: 0)
                let subtring = (self as NSString).substring(with: range)
                let dict = try subtring.dictionaryByMatching(regexPattern, searchRange: subtring.stringRange, options: options, matchingOptions: matchingOptions, keysAndCapturePairs: pairs)
                return dict
            }

            return dictArray
    }

    func enumerateStringsMatchedBy(_ regexPattern: String,
                                   searchRange: NSRange? = nil,
                                   options: RKLRegexOptions = [],
                                   matchingOptions: NSRegularExpression.MatchingOptions = [],
                                   _ block: (_ strings: [String], _ ranges: [NSRange]) -> Void)
        throws -> Bool {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
            let matches = regex.matches(in: self, options: matchingOptions, range: searchRange ?? stringRange)
            if matches.isEmpty { return false }

            for match in matches {
                let substrings = match.ranges.map({ ($0.location != NSNotFound) ? (self as NSString).substring(with: $0) : "" })
                block(substrings, match.ranges)
            }

            return true
    }

    func componentsSeparatedBy(_ regexPattern: String,
                               searchRange: NSRange? = nil,
                               options: RKLRegexOptions = [],
                               matchingOptions: NSRegularExpression.MatchingOptions = [])
        throws -> [String] {
            let nsregexopts = options.coerceToNSRegularExpressionOptions()
            let regex = try NSRegularExpression(pattern: regexPattern, options: nsregexopts)
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
}
