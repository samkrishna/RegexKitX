//
//  RegexKitXTests.swift
//  SwiftRegexKitXTests

import XCTest
@testable import SwiftRegexKitX

class RegexKitXTests: XCTestCase {
    public let candidate = "2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU275587, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";

    var testCorpus: String {
        return type(of: self).corpus
    }

    static var corpus: String = {
        let corpusPath = Bundle(for: RegexKitXTests.self).path(forResource: "sherlock-utf-8", ofType: "txt")!
        let _corpus = try! String(contentsOfFile: corpusPath, encoding: String.Encoding.utf8)
        return _corpus
    }()

    func testMatchesRegex() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let result = try! candidate.matches(regex)
        XCTAssert(result)
    }

    func testMatchesRegexInSearchRange() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let resultWithFullRange = try! candidate.matches(regex, in: candidate.stringRange)
        XCTAssertTrue(resultWithFullRange)
        let resultWithHalfRange = try! candidate.matches(regex, in: NSMakeRange(0, (candidate.utf16.count / 2)))
        XCTAssertFalse(resultWithHalfRange)
    }

    func testMatchesRegexOptions() {
        let regex = "(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let result = try! candidate.matches(regex, options: .RKXCaseless)
        XCTAssertTrue(result)

        let failResult = try! candidate.matches(regex, options: [.RKXCaseless, .RKXIgnoreMetacharacters ])
        XCTAssertFalse(failResult)
    }

    func testCustomOperators() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        XCTAssertTrue(candidate =~ regex)
        XCTAssertTrue(regex ~= candidate)
    }

    func testRangeOfRegex() {
        let regex = "((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))"
        let captureRange = try! candidate.range(of: regex)
        let captureControl = candidate.utf16Range(from: NSMakeRange(0, 19))
        XCTAssert(captureRange == captureControl)

        let dateRange = try! candidate.range(of: regex, for: 1)
        let dateControl = candidate.utf16Range(from: NSMakeRange(0, 10))
        XCTAssert(dateRange == dateControl)

        let yearRange = try! candidate.range(of: regex, for: 2)
        let yearControl = candidate.utf16Range(from: NSMakeRange(0, 4))
        XCTAssert(yearRange == yearControl)

        let monthRange = try! candidate.range(of: regex, for: 3)
        let monthControl = candidate.utf16Range(from: NSMakeRange(5, 2))
        XCTAssert(monthRange == monthControl)

        let dayRange = try! candidate.range(of: regex, for: 4)
        let dayControl = candidate.utf16Range(from: NSMakeRange(8, 2))
        XCTAssert(dayRange == dayControl)

        let timeRange = try! candidate.range(of: regex, for: 5)
        let timeControl = candidate.utf16Range(from: NSMakeRange(11, 8))
        XCTAssert(timeRange == timeControl)

        let hourRange = try! candidate.range(of: regex, for: 6)
        let hourControl = candidate.utf16Range(from: NSMakeRange(11, 2))
        XCTAssert(hourRange == hourControl)

        let minuteRange = try! candidate.range(of: regex, for: 7)
        let minuteControl = candidate.utf16Range(from: NSMakeRange(14, 2))
        XCTAssert(minuteRange == minuteControl)

        let secondRange = try! candidate.range(of: regex, for: 8)
        let secondControl = candidate.utf16Range(from: NSMakeRange(17, 2))
        XCTAssert(secondRange == secondControl)

        let secondNSRange = candidate.nsrange(from: secondRange)
        let secondNSRangeControl = NSMakeRange(17, 2)
        XCTAssert(NSEqualRanges(secondNSRange, secondNSRangeControl))
    }

    func testFailedRangeOfRegex() {
        let failRange = try! candidate.range(of: "blah")
        XCTAssertNil(failRange)
    }

    func testStringMatchedByRegex() {
        // @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";

        let regex = "((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
        let timestamp = try! candidate.stringMatched(by: regex)
        XCTAssert(timestamp == "2014-05-06 17:03:17");
    }

    func testStringByReplacingOccurrencesOfRegex() {
        let failedPattern = "2014-05-06 17:03:17.967 EXECUTION_DINO"
        let failureControl = "2014-05-06 17:03:17.967 EXECUTION_DATA"
        let failureRange = NSMakeRange(0, 38);
        let failureResult = try! candidate.stringByReplacingOccurrences(of: failedPattern, with: "BARNEY RUBBLE", in: failureRange)
        XCTAssert(failureResult == failureControl)

        let successPattern = "2014-05-06 17:03:17.967 (EXECUTION_DATA)"
        let successResult = try! candidate.stringByReplacingOccurrences(of: successPattern, with: "BARNEY RUBBLE ~~~$1~~~ ", in: failureRange)
        XCTAssert(try! successResult.matches("BARNEY RUBBLE"))
        XCTAssert(try! successResult.matches("~~~EXECUTION_DATA~~~"))
    }

    func testComponentsMatchedByRegex() {
        let list = "$10.23, $1024.42, $3099"
        let listItems: [String] = try! list.componentsMatched(by: "\\$((\\d+)(?:\\.(\\d+)|\\.?))", for: 3)

        XCTAssert(listItems[0] == "23")
        XCTAssert(listItems[1] == "42")
        XCTAssert(listItems[2] == "")
    }

    func testCaptureComponentsMatcheByRegex() {
        let list = "$10.23, $1024.42, $3099"
        let listItems: [String] = try! list.captureComponentsMatched(by: "\\$((\\d+)(?:\\.(\\d+)|\\.?))")
        XCTAssert(listItems.count == 4)
        XCTAssert(listItems[0] == "$10.23")
        XCTAssert(listItems[1] == "10.23")
        XCTAssert(listItems[2] == "10")
        XCTAssert(listItems[3] == "23")
    }

    func testArrayOfCaptureComponentsMatchedByRegex() {
        let list = "$10.23, $1024.42, $3099"
        let listItems: [[String]] = try! list.arrayOfCaptureComponentsMatched(by: "\\$((\\d+)(?:\\.(\\d+)|\\.?))")
        XCTAssert(listItems.count == 3)

        let list0 = listItems[0]
        XCTAssert(list0 == [ "$10.23", "10.23", "10", "23" ]);
        let list1 = listItems[1];
        XCTAssert(list1 == [ "$1024.42", "1024.42", "1024", "42" ])
        let list2 = listItems[2];
        XCTAssert(list2 == [ "$3099", "3099", "3099", "" ])
    }

    func testDictionaryMatchedByRegex() {
        let name = "Name: Joe";
        let regex = "Name:\\s*(\\w*)\\s*(\\w*)";
        let firstKey = "first";
        let lastKey = "last";

        let dict = try! name.dictionaryMatched(by:regex, keysAndCaptures: firstKey, 1, lastKey, 2)
        XCTAssert(dict[firstKey] == "Joe")
        XCTAssert(dict[lastKey] == "")
        XCTAssertThrowsError(try name.dictionaryMatched(by:regex, keysAndCaptures: firstKey, 1, lastKey))

        let badRegex = "Name:\\s*(\\w*)\\s*(\\w*";
        XCTAssertThrowsError(try name.dictionaryMatched(by: badRegex, keysAndCaptures: firstKey, 1, lastKey, 2))

        let execRegex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), time:(\\d+\\s+\\d+:\\d+:\\d+), acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let executionDict = try! self.candidate.dictionaryMatched(by: execRegex, keysAndCaptures:
            "executionDate", 1,
            "currencyPair", 2,
            "orderID", 3,
            "clientID", 4,
            "executionID", 5,
            "canonicalExecutionDate", 6,
            "accountID", 7,
            "orderSide", 8,
            "orderVolume", 9,
            "executionPrice", 10,
            "permanentID", 11)

        XCTAssert(executionDict.count == 11);
        XCTAssert(executionDict["executionDate"] == "2014-05-06 17:03:17.967")
        XCTAssert(executionDict["currencyPair"] == "EUR.JPY")
        XCTAssert(executionDict["orderID"] == "439")
        XCTAssert(executionDict["clientID"] == "75018");
        XCTAssert(executionDict["executionID"] == "0001f4e8.536956da.01.01")
        XCTAssert(executionDict["canonicalExecutionDate"] == "20140506  17:03:18")
        XCTAssert(executionDict["accountID"] == "DU275587")
        XCTAssert(executionDict["orderSide"] == "SLD")
        XCTAssert(executionDict["orderVolume"] == "141500")
        XCTAssert(executionDict["executionPrice"] == "141.73")
        XCTAssert(executionDict["permanentID"] == "825657452")
    }

    func testArrayOfDictionariesByMatchingRegex() {
        let name = "Name: Bob\n" + "Name: John Smith"
        let regex = "(?m)^Name:\\s*(\\w*)\\s*(\\w*)$"
        let firstKey = "first"
        let lastKey = "last"

        let nameArray = try! name.arrayOfDictionariesMatched(by: regex, keysAndCaptures: firstKey, 1, lastKey, 2)

        let name0 = nameArray[0];
        XCTAssert(name0[firstKey] == "Bob");
        XCTAssert(name0[lastKey] == "");

        let name1 = nameArray[1];
        XCTAssert(name1[firstKey] == "John");
        XCTAssert(name1[lastKey] == "Smith");

        let failureResult = try! self.candidate.arrayOfDictionariesMatched(by: regex, keysAndCaptures: firstKey, 1, lastKey, 2)
        XCTAssertNotNil(failureResult)
        XCTAssert(failureResult.count == 0)
    }

    func testEnumerateStringMatchedByRegexUsingBlock() {
        let searchString = "Name: Bob\n" + "Name: John Smith"
        let regex = "(?m)^Name:\\s*(\\w*)\\s*(\\w*)$"
        var matchCount = 0

        let result = try! searchString.enumerateStringsMatched(by: regex, using: { (stringArray, ranges) in
            print("stringArray = \(stringArray)")
            print("ranges = \(ranges)")
            matchCount += 1
        })

        XCTAssert(result)
        XCTAssert(matchCount == 2)
    }

    func testComponentsSeparatedByRegex() {
        let regex = ", ";
        let captures = try! candidate.componentsSeparated(by: regex)
        XCTAssert(captures.count == 12);

        for substring in captures {
            XCTAssertFalse(substring =~ regex)
        }
    }

    func testEnumerateStringsSeparatedyByRegexUsingBlock() {
        let regexPattern = ",(\\s+)";
        let rangeValueChecks = [ NSMakeRange(0, 91),
                                 NSMakeRange(93, 30),
                                 NSMakeRange(125, 23),
                                 NSMakeRange(150, 19),
                                 NSMakeRange(171, 17),
                                 NSMakeRange(190, 8),
                                 NSMakeRange(200, 13),
                                 NSMakeRange(215, 12),
                                 NSMakeRange(229, 16),
                                 NSMakeRange(247, 13),
                                 NSMakeRange(262, 13),
                                 NSMakeRange(277, 15) ];

        var index = 0;
        let result = try! candidate.enumerateStringsSeparated(by: regexPattern, using: { (capturedStrings, capturedRanges) in
            let string = capturedStrings[0]
            let range = capturedRanges[0]
            let rangeCheck = rangeValueChecks[index]
            print("Forward: string = \(string) and range = \(range)")
            XCTAssert(NSEqualRanges(range, rangeCheck))
            index += 1
        })

        XCTAssert(result);
    }

    func testCaseBehavior() {
        let matched: Bool

        switch "eat some food" {
        case "foo":
            matched = true
        default:
            matched = false
        }

        XCTAssert(matched)
    }

    func testIsRegexValid() {
        let badPattern = "[a-z"
        XCTAssertFalse(badPattern.isRegexValid())

        let goodPattern = "[a-z]"
        XCTAssert(goodPattern.isRegexValid())
    }

    func testStringByReplacingOccurrencesOfRegexUsingClosure() {
        let pattern = "((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+\\.\\d+))";

        let output = try! candidate.stringByReplacingOccurences(of: pattern, using: { (capturedStrings, capturedRanges) in
            var replacement = ""
            let dateRegex = "^\\d+-\\d+-\\d+$"
            let timeRegex = "^\\d+:\\d+:\\d+\\.\\d+$"

            for capture in capturedStrings {
                if try! capture.matches(dateRegex) {
                    replacement.append("cray ")
                }
                else if try! capture.matches(timeRegex) {
                    replacement.append("cray!")
                }
            }

            return replacement
        })

        XCTAssert(output =~ "cray cray!")
    }

    func testReploceOccurrencesOfRegexWithReplacement() {
        var mutableCandidate = String(candidate)
        let count = try! mutableCandidate.replaceOccurrences(of: ", ", with: " barney ")
        XCTAssert(count == 11)
        XCTAssert(mutableCandidate =~ " barney ")
    }

    func testReplaceOccurrencesOfRegexUsingClosure() {
        var mutableCandidate = String(candidate)
        let count = try! mutableCandidate.replaceOccurrences(of: ", ", using: { (captureStrings, captureRanges) -> String in
            return " barney "
        })

        XCTAssert(count == 11)
        XCTAssert(mutableCandidate =~ " barney ")
    }

    // MARK: Performance Tests
    // These performance tests were adapted from https://rpubs.com/jonclayden/regex-performance
    // by Jon Clayden

    func testPerformanceRegex01() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "Sherlock", options:.RKXMultiline)
            XCTAssert(matches.count == 97, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex02() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "^Sherlock", options:.RKXMultiline)
            XCTAssert(matches.count == 34, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex03() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "Sherlock$", options:.RKXMultiline)
            XCTAssert(matches.count == 6, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex04() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "a[^x]{20}b", options:.RKXMultiline)
            XCTAssert(matches.count == 405, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex05() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "Holmes|Watson", options:.RKXMultiline)
            XCTAssert(matches.count == 542, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex06() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: ".{0,3}(Holmes|Watson)", options:.RKXMultiline)
            XCTAssert(matches.count == 542, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex07() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "[a-zA-Z]+ing", options:.RKXMultiline)
            XCTAssert(matches.count == 2824, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex08() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "^([a-zA-Z]{0,4}ing)[^a-zA-Z]", options:.RKXMultiline)
            XCTAssert(matches.count == 163, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex09() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "[a-zA-Z]+ing$", options:.RKXMultiline)
            XCTAssert(matches.count == 152, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex10() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "^[a-zA-Z ]{5,}$", options:.RKXMultiline)
            XCTAssert(matches.count == 876, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex11() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "^.{16,20}$", options:.RKXMultiline)
            XCTAssert(matches.count == 238, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex12() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "([a-f](.[d-m].){0,2}[h-n]){2}", options:.RKXMultiline)
            XCTAssert(matches.count == 1597, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex13() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "([A-Za-z]olmes)|([A-Za-z]atson)[^a-zA-Z]", options:.RKXMultiline)
            XCTAssert(matches.count == 542, "The count is \(matches.count)")
        }
    }

    func testPerformanceRegex14() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "\"[^\"]{0,30}[?!\\.]\"", options:.RKXMultiline)
            XCTAssert(matches.count == 582, "The count is \(matches.count)")
        }
    }


    func testPerformanceRegex15() {
        measure {
            let matches = try! self.testCorpus.componentsMatched(by: "Holmes.{10,60}Watson|Watson.{10,60}Holmes", options:.RKXMultiline)
            XCTAssert(matches.count == 2, "The count is \(matches.count)")
        }
    }
}

