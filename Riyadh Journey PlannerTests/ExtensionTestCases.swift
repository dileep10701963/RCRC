//
//  ExtensionTestCases.swift
//  Riyadh Journey PlannerTests
//
//  Created by Ganesh on 24/05/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class ExtensionTestCases: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIntExtension(){
        let seconds = 60
        XCTAssertEqual(1, seconds.minutes)
    }
    func testdoubleToRound(){
        let val : Double = 20.123
        let result : Double = 20.1
        XCTAssertEqual(result, val.round(to: 1))
    }
    
    func testDoubleToInt(){
        let val : Double = 20.12
        XCTAssertEqual(20, val.toInt())
    }
    
    // Date
    
    func testDateToString(){
        let strDate = "20/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let resultDate = df.date(from: strDate)
        XCTAssertEqual(strDate, resultDate?.toString(withFormat: "dd/mm/yyyy", timeZone: .IST))
    }
    
    func testDateMillisecondsSince1970(){
        let strDate = "20/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let resultDate = df.date(from: strDate)
        XCTAssertEqual(1611081240000, resultDate?.millisecondsSince1970 ?? 0)

    }
    func testDateEqual(){
        let strDate = "20/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let firstDate = df.date(from: strDate)
        let secondDate = df.date(from: strDate)
        XCTAssertTrue(firstDate!.isEqualTo(secondDate!))
    }

    func testIsDateGreaterThan(){
        let strDate = "20/04/2021"
        let strResultDate = "19/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let firstDate = df.date(from: strDate)
        let secondDate = df.date(from: strResultDate)
        XCTAssertTrue(firstDate!.isGreaterThan(secondDate!))

    }
    
    func testIsDateLessThan(){
        let strDate = "20/04/2021"
        let strResultDate = "29/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let firstDate = df.date(from: strDate)
        let secondDate = df.date(from: strResultDate)
        XCTAssertTrue(firstDate!.isSmallerThan(secondDate!))

    }
    func testDayIndexOfWeek (){
        let strDate = "20/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let resultDate = df.date(from: strDate)
        XCTAssertEqual(4, resultDate?.dayIndexOfWeek() ?? 0)
    }
    func testDayOfWeek (){
        let strDate = "20/04/2021"
        let df = DateFormatter()
        df.dateFormat = "dd/mm/yyyy"
        let resultDate = df.date(from: strDate)
        XCTAssertEqual("20", resultDate?.dayOfWeek() ?? "0")
    }
    
    
    //String
    func testString(){
        let string = "Sample"
        XCTAssertEqual(string, string.string)
    }

    func testToDouble(){
        let strValue = "20.1"
        XCTAssertEqual(Double(20.1), strValue.toDouble())
    }
    
    func testToInt(){
        let strValue = "20"
        XCTAssertEqual(20, strValue.toInt())
    }

    func test_doubleToInt_returns0_whenInvalidDouble() {
        let number = Double(Int.max) + 1
        XCTAssertEqual(number.toInt(), 0)
    }

    func test_filenameExtract_returnsFilename() {
        let file = "file.txt"
        XCTAssertEqual(file.fileName(), "file")
    }

    func test_toInt_returns_0_asDefault() {
        let number = ""
        XCTAssertEqual(number.toInt(), 0)
    }

    func test_toDouble_returns_0_asDefault() {
        let number = ""
        XCTAssertEqual(number.toDouble(), 0)
    }

    func test_toDate_ReturnsDateWithEnLocaleForEnglish() {
        let dateString = "20210604"
        XCTAssertNotNil(dateString.toDate(withFormat: "yyyyMMdd", timeZone: .IST, language: .english))
    }

    func test_toDate_ReturnsDateWithArLocaleForArabic() {
        let dateString = "20210604"
        XCTAssertNotNil(dateString.toDate(withFormat: "yyyyMMdd", timeZone: .IST, language: .arabic))
    }

    func test_toDate_ReturnsDateWithUrLocaleForUrdu() {
        let dateString = "20210604"
        XCTAssertNotNil(dateString.toDate(withFormat: "yyyyMMdd", timeZone: .IST, language: .urdu))
    }
}
