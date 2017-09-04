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
                if match.range.location != NSNotFound {
                    let range = match.range.range(for: self)
                    target.replaceSubrange(range!, with: replacement)
                }
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
                let matchRange = $0.range(at: capture)
                let matchString = matchRange.location != NSNotFound ? (self as NSString).substring(with: matchRange) : ""
                return matchString
            })

            return captures
    }
}
