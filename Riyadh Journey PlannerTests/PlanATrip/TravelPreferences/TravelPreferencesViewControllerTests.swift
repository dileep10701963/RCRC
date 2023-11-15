//
//  TravelPreferencesViewControllerTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Aashish Singh on 25/11/22.
//

import XCTest
@testable import Riyadh_Journey_Planner

class TravelPreferencesViewControllerTests: XCTestCase {
 
    func test_viewDidLoad_ConfiguresTableView() {
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()

        XCTAssertEqual(String(describing: sut.preferenceTableView.dataSource!), String(describing: sut))
        XCTAssertEqual(String(describing: sut.preferenceTableView.delegate!), String(describing: sut))
        XCTAssertNotNil(sut.preferenceTableView.estimatedRowHeight)
    }

    func test_viewDidLoad_RegistersTableViewCells() {
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()

        sut.savePreferencesButton.sendActions(for: .touchUpInside)
        guard let registeredCells = sut.preferenceTableView.value(forKey: "_nibMap") as? [String: Any] else {
            XCTFail("No Table View Cells registered for \(String(describing: sut.preferenceTableView))")
            return
        }

        XCTAssertGreaterThan(registeredCells.count, 0)
    }
    
    func test_tableView_NumberOfSection() {
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let numberOfSection = sut.preferenceTableView.numberOfSections
        XCTAssertGreaterThan(numberOfSection, 0)
    }
    
    func test_tableView_NumberOfRows() {
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        for section in 0 ..< sut.preferenceTableView.numberOfSections {
            let numberOfRows = sut.preferenceTableView.numberOfRows(inSection: section)
            XCTAssertGreaterThan(numberOfRows, 0)
        }
    }
    
    func test_correctResultAtSection_0() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_subHeader = IndexPath(row: 0, section: 0)
        let cell_subHeader = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_subHeader) as! TransportMethodSubHeader
        XCTAssertEqual(cell_subHeader.headerLabel.text, "The selected transport types will be used for trip planning.")
        
        let indexPath_transportMethod = IndexPath(row: 1, section: 0)
        let cell_transportMethod = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_transportMethod) as! TransportMethodCell
        XCTAssertEqual(cell_transportMethod.transportLabel.text, "Bus")
        
    }
    
    func test_correctResultAtSection_1() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_FilterRoute = IndexPath(row: 0, section: 1)
        let cell_FilterRoute = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_FilterRoute) as! FilterRoutesByCell
        
        cell_FilterRoute.optionsSelectionButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(cell_FilterRoute.headerLabel.text, "Quickest Connection")
        
    }
    
    func test_correctResultAtSection_2() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_MaxWalkTime = IndexPath(row: 0, section: 2)
        let cell_MaxWalkTime = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_MaxWalkTime) as! MaximumWalkTimeCell
        XCTAssertEqual(cell_MaxWalkTime.maximumWalkTimeLabel.text, "Set max minutes for walking duration of your journey")
        
    }
    
    func test_correctResultAtSection_3() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_SortRoute = IndexPath(row: 0, section: 3)
        let cell_SortRoute = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_SortRoute) as! SortRoutesByCell
        sut.reloadSortByTableView(tableViewCell: cell_SortRoute)
        XCTAssertEqual(cell_SortRoute.sortRouteByLabel.text, "Slow")
        
    }
    
    func test_correctResultAtSection_4() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_SortRoute = IndexPath(row: 0, section: 4)
        let cell_SortRoute = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_SortRoute) as! SortRoutesByCell
        sut.reloadSortByTableView(tableViewCell: cell_SortRoute)
        XCTAssertEqual(cell_SortRoute.sortRouteByLabel.text, "Include Nearby alternative stops")
        
    }
    
    func test_correctResultAtSection_5() {
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let indexPath_Reset = IndexPath(row: 0, section: 5)
        let cell_Reset = sut.preferenceTableView.dataSource?.tableView(sut.preferenceTableView, cellForRowAt: indexPath_Reset) as! ResetButtonCell
        cell_Reset.resetButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(cell_Reset.resetButton.titleLabel?.text, "Reset")
        
    }
    
    func test_viewForHeaderSection() {
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        let headerView = sut.preferenceTableView.delegate?.tableView?(sut.preferenceTableView, viewForHeaderInSection: 0) as! TravelPreferenceHeaderView
        XCTAssertNotNil(headerView)
        XCTAssertEqual(headerView.headerLabel.text, "Methods of Transport")
    }
    
    func test_TableViewConfromsToTableViewDelegateProtocol(){
        
        var sut = TravelPreferenceViewController()
        sut = TravelPreferenceViewController.instantiate(appStoryboard: .home)
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.responds(to: #selector(sut.tableView(_:didSelectRowAt:))))
    }

}
