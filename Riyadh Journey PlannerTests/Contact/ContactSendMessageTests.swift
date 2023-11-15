//
//  ContactSendMessageTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 04/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class ContactSendMessageTests: XCTestCase {

    func test_validEmail_returnsTrueForValidEmail() {
        let sut = ContactDetailViewModel()

        let result = sut.isValidEmail(email: "mail@mail.com")

        XCTAssertTrue(result)
    }

    func test_validEmail_returnsFalseForInvalidEmail() {
        let sut = ContactDetailViewModel()

        let result = sut.isValidEmail(email: "mail.com")

        XCTAssertFalse(result)
    }

    func test_validPhoneNumber_returnsTrueForValidPhoneNumber() {
        let sut = ContactDetailViewModel()

        let result = sut.isValidPhoneNumber(phone: "+966 1234567890")

        XCTAssertTrue(result)
    }

    func test_validPhoneNumber_returnsFalseForInvalidPhoneNumber() {
        let sut = ContactDetailViewModel()

        let result = sut.isValidPhoneNumber(phone: "1234")

        XCTAssertFalse(result)
    }

    func test_fetchUserProfile_fetchesUserInformationIfSaved() {
        let sut = ContactDetailViewModel()
        let profileInfo = ProfileInformation(emailAddress: "mail@mail.com", mobileNumber: "+966 123-456-7890", fullName: "Full Name", image: nil)
        UserProfileDataRepository.shared.fetchAll()?.forEach({ _ in UserProfileDataRepository.shared.delete() })
        UserProfileDataRepository.shared.create(record: profileInfo)

        sut.fetchUserProfile()

        XCTAssertEqual(sut.userData.value?.fullName, "Full Name")
        XCTAssertEqual(sut.userData.value?.emailAddress, "mail@mail.com")
        XCTAssertEqual(sut.userData.value?.mobileNumber, "+966 123-456-7890")
    }

    func test_fetchUserProfile_returnsNilWhenNoInformationIsSaved() {
        let sut = ContactDetailViewModel()
        UserProfileDataRepository.shared.fetchAll()?.forEach({ _ in UserProfileDataRepository.shared.delete() })

        sut.fetchUserProfile()

        XCTAssertNil(sut.userData.value)
    }

    func test_myAccountViewModel_fetchData_returnsDataIfExists() {
        let sut = MyAccountViewModel()
        let profileInfo = ProfileInformation(emailAddress: "mail@mail.com", mobileNumber: "+966 123-456-7890", fullName: "Full Name", image: nil)
        UserProfileDataRepository.shared.fetchAll()?.forEach({ _ in UserProfileDataRepository.shared.delete() })
        UserProfileDataRepository.shared.create(record: profileInfo)

        sut.fetchData()

        XCTAssertEqual(sut.myAccountData.value?.fullName, "Full Name")
        XCTAssertEqual(sut.myAccountData.value?.emailAddress, "mail@mail.com")
        XCTAssertEqual(sut.myAccountData.value?.mobileNumber, "+966 123-456-7890")
    }

    func test_myAccountViewModel_fetchData_returnsNilIfNotExists() {
        let sut = MyAccountViewModel()
        UserProfileDataRepository.shared.fetchAll()?.forEach({ _ in UserProfileDataRepository.shared.delete() })

        sut.fetchData()

        XCTAssertNil(sut.myAccountData.value)
    }
}
