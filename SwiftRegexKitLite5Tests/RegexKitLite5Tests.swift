//
//  RegexKitLite5Tests.swift
//  SwiftRegexKitLite5Tests
//
//  Created by Sam Krishna on 8/27/17.
//  Copyright © 2017 Sam Krishna. All rights reserved.
//

import XCTest
@testable import SwiftRegexKitLite5

class RegexKitLite5Tests: XCTestCase {
    public let candidate = "2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsMatchedByRegexRangeOptionsMatchingOptions() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let result = try! candidate.isMatchedBy(regex)
        XCTAssert(result)
    }

    func testIsMatchedByRegexRange() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let resultWithFullRange = try! candidate.isMatchedBy(regex, searchRange: candidate.stringRange)
        XCTAssertTrue(resultWithFullRange)
        let resultWithHalfRange = try! candidate.isMatchedBy(regex, searchRange: NSMakeRange(0, (candidate.utf16.count / 2)))
        XCTAssertFalse(resultWithHalfRange)
    }

    func testIsMatchedByRegexOptionsRange() {
        let regex = "(.*) execution_data: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        let result = try! candidate.isMatchedBy(regex, searchRange: candidate.stringRange, options: .RKLCaseless)
        XCTAssertTrue(result)

        let failResult = try! candidate.isMatchedBy(regex, searchRange: candidate.stringRange, options: [.RKLCaseless, .RKLIgnoreMetacharacters ])
        XCTAssertFalse(failResult)
    }

    func testCustomOperators() {
        let regex = "(.*) EXECUTION_DATA: .* (\\w{3}.\\w{3}) .* orderId:(\\d+): clientId:(\\w+), execId:(.*.01), .*, acctNumber:(\\w+).*, side:(\\w+), shares:(\\d+), price:(.*), permId:(\\d+).*"
        XCTAssertTrue(candidate =~ regex)
        XCTAssertTrue(regex ~= candidate)
    }

    func testRangeOfRegexInRangeCapture() {
        let regex = "((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))"
        let captureRange = try! candidate.rangeOf(regex)
        XCTAssert(captureRange.location == 0);
        XCTAssert(captureRange.length == 19);

        let dateRange = try! candidate.rangeOf(regex, capture: 1)
        XCTAssert(dateRange.location == 0);
        XCTAssert(dateRange.length == 10);

        let yearRange = try! candidate.rangeOf(regex, capture: 2)
        XCTAssert(yearRange.location == 0);
        XCTAssert(yearRange.length == 4);

        let monthRange = try! candidate.rangeOf(regex, capture: 3)
        XCTAssert(monthRange.location == 5);
        XCTAssert(monthRange.length == 2);

        let dayRange = try! candidate.rangeOf(regex, capture: 4)
        XCTAssert(dayRange.location == 8);
        XCTAssert(dayRange.length == 2);

        let timeRange = try! candidate.rangeOf(regex, capture: 5)
        XCTAssert(timeRange.location == 11);
        XCTAssert(timeRange.length == 8);

        let hourRange = try! candidate.rangeOf(regex, capture: 6)
        XCTAssert(hourRange.location == 11);
        XCTAssert(hourRange.length == 2);

        let minuteRange = try! candidate.rangeOf(regex, capture: 7)
        XCTAssert(minuteRange.location == 14);
        XCTAssert(minuteRange.length == 2);

        let secondRange = try! candidate.rangeOf(regex, capture: 8)
        XCTAssert(secondRange.location == 17);
        XCTAssert(secondRange.length == 2);
    }

    func testFailedRangeOfRegex() {
        let failRange: NSRange = try! candidate.rangeOf("blah")
        XCTAssert(failRange.location == NSNotFound)
        XCTAssert(failRange.length == 0)
    }

    func testStringByMatchingInRangeCaptureOptionsMatchingOptions() {
        // @"2014-05-06 17:03:17.967 EXECUTION_DATA: -1 EUR EUR.JPY 14321016 orderId:439: clientId:75018, execId:0001f4e8.536956da.01.01, time:20140506  17:03:18, acctNumber:DU161169, exchange:IDEALPRO, side:SLD, shares:141500, price:141.73, permId:825657452, liquidation:0, cumQty:141500, avgPrice:141.73";

        let regex = "((\\d+)-(\\d+)-(\\d+)) ((\\d+):(\\d+):(\\d+))";
        let timestamp = try! candidate.stringByMatching(regex)
        XCTAssert(timestamp == "2014-05-06 17:03:17");
    }

    func testStringByReplacingOccurrencesOfRegexReplacementSearchRangeOptionsMatchingOptions() {
        let failedPattern = "2014-05-06 17:03:17.967 EXECUTION_DINO"
        let failureControl = "2014-05-06 17:03:17.967 EXECUTION_DATA"
        let failureRange = NSMakeRange(0, 38);
        let failureResult = try! candidate.stringByReplacingOccurrencesOf(failedPattern, replacement: "BARNEY RUBBLE", searchRange: failureRange)
        XCTAssert(failureResult == failureControl)

        let successPattern = "2014-05-06 17:03:17.967 EXECUTION_DATA"
        let successResult = try! candidate.stringByReplacingOccurrencesOf(successPattern, replacement: "BARNEY RUBBLE", searchRange: failureRange)
        XCTAssert(try! successResult.isMatchedBy("BARNEY RUBBLE"))
    }

    func testComponentsMatchedByRegexSearchRangeCaptureOptionsMatchingOptions() {
        let list = "$10.23, $1024.42, $3099"
        let listItems: [String] = try! list.componentsMatchedBy("\\$((\\d+)(?:\\.(\\d+)|\\.?))", capture: 3)

        XCTAssert(listItems[0] == "23")
        XCTAssert(listItems[1] == "42")
        XCTAssert(listItems[2] == "")
    }

}
