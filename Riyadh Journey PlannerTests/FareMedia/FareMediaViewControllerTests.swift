//
//  FareMediaViewControllerTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 28/07/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class FareMediaViewControllerTests: XCTestCase {

    func test_viewDidLoad_ConfiguresTableView() {
        let sut = FareMediaViewController()

        sut.loadViewIfNeeded()

        XCTAssertEqual(String(describing: sut.tableView.dataSource!), String(describing: sut))
        XCTAssertEqual(String(describing: sut.tableView.delegate!), String(describing: sut))
        XCTAssertNotNil(sut.tableView.refreshControl)
        XCTAssertNotNil(sut.tableView.tableFooterView)
    }

    func test_viewDidLoad_RegistersTableViewCells() {
        let sut = FareMediaViewController()
        sut.loadViewIfNeeded()

        guard let registeredCells = sut.tableView.value(forKey: "_cellClassDict") as? [String: Any] else {
            XCTFail("No Table View Cells registered for \(String(describing: sut.tableView))")
            return
        }

        XCTAssertGreaterThan(registeredCells.count, 0)
    }

    func test_viewWillAppear_ConfiguresNavigationBarTitle() {
        let sut = FareMediaViewController()
        sut.loadViewIfNeeded()

        sut.viewWillAppear(false)

        XCTAssertEqual(sut.navigationItem.title, "Tickets".localized)
    }
}
