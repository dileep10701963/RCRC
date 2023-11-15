//
//  AuthenticationTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Admin on 01/03/21.
//

import XCTest
@testable import Riyadh_Journey_Planner
import UIKit

class AuthenticationTests: XCTestCase {

    var signUpViewModel: SignUpViewModel?
    var loginViewModel: LoginViewModel?
    var editProfileViewModel: EditProfileViewModel?

    override func setUpWithError() throws {
        loginViewModel = LoginViewModel()
        signUpViewModel = SignUpViewModel()
        editProfileViewModel = EditProfileViewModel()
    }

    // MARK: - Register Text Field Validation
    func testRegisterFieldsNotEmpty() {
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.email = "email@email.com"
            signUpViewModel.name = "Full Name"
            signUpViewModel.mobileNumber = "9876543210"
            signUpViewModel.password = "Pass@123"
            signUpViewModel.repeatPassword = "Pass@123"
            let result = signUpViewModel.checkForEmptyFields()
            XCTAssertFalse(result)
        }
    }

    func testRegisterFieldsEmpty() {
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.email = ""
            signUpViewModel.name = ""
            signUpViewModel.mobileNumber = ""
            signUpViewModel.password = ""
            signUpViewModel.repeatPassword = ""
            let result = signUpViewModel.checkForEmptyFields()
            XCTAssertTrue(result)
        }
    }

    func testRegisterFieldsValidation() {
        // Check if Email, Name, Mobile number and Password is valid
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.email = "email@email.com"
            signUpViewModel.name = "Full Name"
            signUpViewModel.mobileNumber = "+966 9876543210"
            signUpViewModel.password = "Pass@123"
            signUpViewModel.repeatPassword = "Pass@123"
            let result = signUpViewModel.checkFieldValidation()
            XCTAssertTrue(result)
        }
    }

    func testRegisterFieldsValidationFailed() {
        // Check if Email, Name, Mobile number and Password is valid
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.email = "email.com"
            signUpViewModel.name = ""
            signUpViewModel.mobileNumber = "+966 987-654-3210"
            signUpViewModel.password = "Pass@123"
            signUpViewModel.repeatPassword = "Pass@123"
            let result = signUpViewModel.checkFieldValidation()
            XCTAssertFalse(result)
        }
    }

    func testIfPasswordsMatch() {
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.password = "Pass@123"
            signUpViewModel.repeatPassword = "Pass@123"
            let result = signUpViewModel.checkIfPasswordsMatch()
            XCTAssertTrue(result)
        }
    }
    
    func testIfPasswordsNotMatch() {
        if let signUpViewModel = self.signUpViewModel {
            signUpViewModel.password = "Pass@123"
            signUpViewModel.repeatPassword = "Pass@1234"
            let result = signUpViewModel.checkIfPasswordsMatch()
            XCTAssertFalse(result)
        }
    }

    // MARK: - Login Text Field Validation
    func testLoginPasswordValidation() {
        loginViewModel?.password = "Abcd@123"
        if let loginViewModel = loginViewModel {
            XCTAssertTrue(loginViewModel.isPasswordValid())
        }
    }

    func testLoginEmailValidation() {
        loginViewModel?.email = "email@gmail.com"
        if let loginViewModel = loginViewModel {
            XCTAssertTrue(loginViewModel.isEmailValid())
        }
    }

    func test_Login_Logout_Api() throws {
        let loginExp = expectation(description: "Login API Testing")
        let logoutExp = expectation(description: "Logout API Testing")
        loginViewModel?.login(user: "mobilityportal9", password: "_12345678Ta_") { result in
            XCTAssertEqual(result, .success)
            loginExp.fulfill()
            let logout = LogoutViewModel()
            logout.logout { didLogout in
                XCTAssertTrue(didLogout)
                logoutExp.fulfill()
            }
        }
        wait(for: [loginExp, logoutExp], timeout: 10.0)
    }

    func testLoginApiFail() throws {
        let expectation = self.expectation(description: "Login API Testing")
        loginViewModel?.login(user: "", password: "") { result in
            switch result {
            case .success:
                XCTFail("Expected API to fail when username password is invalid. Got \(result) instead.")
            case let .failure(errorMessage):
                XCTAssertGreaterThan(errorMessage.count, 0)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
    }

    func test_logoutAPI_FailureWhenUserNotLoggedIn() {
        let sut = LogoutViewModel()
        let exp = expectation(description: "Logout API Test when not logged in")
        sut.logout { _ in
            sut.logout { didLogout in
                XCTAssertFalse(didLogout)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func testEditProfileFieldValidation() {
        let data = EditProfileModel(name: "Full Name", surname: "SurName", gender: "Gender", documentType: "IQA", personalId: "123321", mail: "email@email.com", dateOfBirth: "1994-07-23", phone: "+966 9876543210", additionalEmails: [AdditionalEmail(email: "b@gmail.com")], additionalPhones: [AdditionalPhone(phoneNumber: "1111111111223")])

        let result = editProfileViewModel?.checkFieldValidation(data: data) ?? false
        XCTAssertTrue(result)
    }

    func testEditProfileFieldValidationFailed() {
        let data = EditProfileModel(name: "", surname: "", gender: "Gender", documentType: "IQA", personalId: "123321", mail: "email.com", dateOfBirth: "1994-07-23", phone: "9876565", additionalEmails: [AdditionalEmail(email: "b@gmail.com")], additionalPhones: [AdditionalPhone(phoneNumber: "1111111111223")])

        let result = editProfileViewModel?.checkFieldValidation(data: data) ?? false
        XCTAssertFalse(result)
    }

    func testEditProfileSave() {
        
        let data = EditProfileModel(name: "Full Name", surname: "SurName", gender: "Gender", documentType: "IQA", personalId: "123321", mail: "email@email.com", dateOfBirth: "1994-07-23", phone: "+966 9876543210", additionalEmails: [AdditionalEmail(email: "b@gmail.com")], additionalPhones: [AdditionalPhone(phoneNumber: "1111111111223")])

        let exp = expectation(description: "Update Profile API Test")
        
        editProfileViewModel?.updateProfileData(profileModel: data, completion: { result in
            switch result {
            case .success:
                XCTAssertEqual(result, .success)
            case let .failure(error, _):
                XCTFail("Failed to update the user detail with error: \(error)")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 10.0)
    }

    func test_editProfileFieldValidationForInvalidData() {
        let data = EditProfileModel(name: "Full Name", surname: "SurName", gender: "Gender", documentType: "IQA", personalId: "123321", mail: emptyString, dateOfBirth: "1994-07-23", phone: emptyString, additionalEmails: [AdditionalEmail(email: "b@gmail.com")], additionalPhones: [AdditionalPhone(phoneNumber: "1111111111223")])

        let result = editProfileViewModel?.checkFieldValidation(data: data) ?? false
        XCTAssertFalse(result)
    }

    /*
    func test_editProfileFetchDataReturnsNilWhenRecordIsEmpty() {
        let records = UserProfileDataRepository.shared.fetchAll()
        records?.forEach({ _ in UserProfileDataRepository.shared.delete() })

        editProfileViewModel?.fetchData { profileInfo in
            XCTAssertNil(profileInfo)
        }
    }
     */

    func testRegisterSaveData() {
        if let signUpViewModel = self.signUpViewModel {
            let result = signUpViewModel.register(name: "Full Name", mobile: "9876543210", email: "email@email.com", password: "Pass@123")
            XCTAssert(result)
        }
    }

    func testIfFieldIsEmpty_returnsFalseWhenEmpty() {
        XCTAssertFalse(Validation.shared.checkEmptyField(field: ""))
    }

    func testIfFieldIsEmpty_returnsTrueWhenNotEmpty() {
        XCTAssertTrue(Validation.shared.checkEmptyField(field: "Name"))
    }
    
    override func tearDownWithError() throws {
        signUpViewModel = nil
        loginViewModel = nil
        editProfileViewModel = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
