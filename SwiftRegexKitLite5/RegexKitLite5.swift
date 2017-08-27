//
//  RegexKitLite5.swift
//  RegexKitLite5
//
//  Created by Sam Krishna on 8/27/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

import Foundation

public extension String {
    var stringRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    func isMatchedBy(regexPattern: String,
                     options: NSRegularExpression.Options = [NSRegularExpression.Options(rawValue: 0)],
                     matchingOptions: NSRegularExpression.MatchingOptions = [NSRegularExpression.MatchingOptions(rawValue: 0)],
                     range: NSRange? = nil)
        throws -> Bool {
            let regex = try NSRegularExpression(pattern: regexPattern, options: options)
            let matchCount = regex.numberOfMatches(in: self, options: matchingOptions, range: range ?? stringRange)
            return (matchCount > 0)
    }
}
