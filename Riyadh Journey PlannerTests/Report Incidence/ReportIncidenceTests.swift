//
//  ReportIncidenceTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Ganesh on 06/07/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class ReportIncidenceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_EmailSend() {
        let sut = ReportIncidenceViewModel()
        let reportType = "Lost and found"
        let category = "House Keeping"
        let subCategory = "Other"
        let request = SendEmailRequest(from: "testing@gmail.com", to: "noreply.rcrc@gmail.com", subject: "Lost and Found - \(reportType) - \(category)", contentType: "text/html", content: "Sub Category: \(subCategory)\nPlace of Incidence: Riyadh \nDate of Incidence:  01/06/2021\nDescription: Test Description", attachmentId: "")
        let exp = expectation(description: "Send email")
        sut.emailSendRequest = request
        sut.performSendEmailRequest()
        sut.isSentMail.bind { isSent in
            if isSent != nil {
                XCTAssertTrue(isSent ?? false)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 100)
    }
    
    func test_UploadFile (){
        let sut = ReportIncidenceViewModel()

        guard let image = UIImage(named: "e-mail_icon") else { return }
        let exp = expectation(description: "Upload image attachment")

        let uploadRequest = FileUploadRequest(fileName: "Image-File\(String(describing: 01))", fileContent: image.convertToBase64String())
        sut.performFileUploadRequest(request: uploadRequest, index: 0)
        sut.isSentMail.bind { isSent in
            if isSent != nil {
                XCTAssertTrue(isSent ?? false)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 80.0)
    }
}
