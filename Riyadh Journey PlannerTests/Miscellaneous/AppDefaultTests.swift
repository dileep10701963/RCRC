//
//  AppDefaultTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 04/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class AppDefaultTests: XCTestCase {

    func test_AppFirstLaunch_returnsTrueIfLaunchedBefore() {
        AppDefaults.shared.didLaunchBefore = true
        XCTAssertTrue(AppDefaults.shared.didLaunchBefore)
    }

    func test_AppFirstLaunch_returnsFalseIfNotLaunchedBefore() {
        AppDefaults.shared.didLaunchBefore = false
        XCTAssertFalse(AppDefaults.shared.didLaunchBefore)
    }

    func test_BiometricsEnabled_returnsTrueIfEnabled() {
        AppDefaults.shared.isBiometricsEnabled = true
        XCTAssertTrue(AppDefaults.shared.isBiometricsEnabled)
    }

    func test_BiometricsEnabled_returnsFalseIfNotEnabled() {
        AppDefaults.shared.isBiometricsEnabled = false
        XCTAssertFalse(AppDefaults.shared.isBiometricsEnabled)
    }

    func test_UserLoggedIn_returnsTrueIfLoggedIn() {
        AppDefaults.shared.isUserLoggedIn = true
        XCTAssertTrue(AppDefaults.shared.isUserLoggedIn)
    }

    func test_UserLoggedIn_returnsFalseIfNotLoggedIn() {
        AppDefaults.shared.isUserLoggedIn = false
        XCTAssertFalse(AppDefaults.shared.isUserLoggedIn)
    }
}
