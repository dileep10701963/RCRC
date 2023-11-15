//
//  RouteCellViewModelTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 31/05/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class RouteCellViewModelTests: XCTestCase {

    // MARK: - Valid Cases

    func test_TripWithSingleLeg_returnsValidLines() {
        let leg = makeSingleLegData(for: "footpath")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.origin.0, Colors.green)
        XCTAssertEqual(sut.origin.1, Images.originStop!)
        XCTAssertEqual(sut.destination.0, Colors.green)
        XCTAssertEqual(sut.destination.1, Images.destinationStop!)
    }

    func test_TripWithSingleLegForFootpath_returnsValidCellViewModelForFootpath() {
        let leg = makeSingleLegData(for: "footpath")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min walk")
    }



    func test_TripWithSingleLegForBus_returnsValidCellViewModelForBus() {
        let leg = makeSingleLegData(for: "Bus")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min, 3 Stops")
    }

    func test_TripWithSingleLegForCycling_returnsValidCellViewModelForCycling() {
        let leg = makeSingleLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Cycling")
    }

    func test_TripWithSingleLegForTaxi_returnsValidCellViewModelForTaxi() {
        let leg = makeSingleLegData(for: "Taxi")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Drive")
    }

    func test_tripWithMultipleModesWhere_Footpath_IsFirst_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "footpath")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min walk")
    }

    func test_tripWithMultipleModesWhere_Bus_IsFirst_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Bus")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min, 3 Stops")
    }

    func test_tripWithMultipleModesWhere_Cycling_IsFirst_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Cycling")
    }

    func test_tripWithMultipleModesWhere_Taxi_IsFirst_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Taxi")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Drive")
    }

    func test_tripWithMultipleModesWhere_Footpath_IsInBetween_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "footpath")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min walk")
    }

    func test_tripWithMultipleModesWhere_Bus_IsInBetween_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Bus")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min, 3 Stops")
    }

    func test_tripWithMultipleModesWhere_Cycling_IsInBetween_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Cycling")
    }

    func test_tripWithMultipleModesWhere_Taxi_IsInBetween_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Taxi")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Drive")
    }

    func test_tripWithMultipleModesWhere_Footpath_IsLast_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "footpath")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min walk")
    }

    func test_tripWithMultipleModesWhere_Bus_IsLast_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Bus")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min, 3 Stops")
    }

    func test_tripWithMultipleModesWhere_Cycling_IsLast_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Cycling")
    }

    func test_tripWithMultipleModesWhere_Taxi_IsLast_returnsValidCellViewModel() {
        let leg = makeSingleLegData(for: "Taxi")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh")
        XCTAssertEqual(sut.duration, "2 Min Drive")
    }

    // MARK: - Invalid Cases
    func test_TripWithInvalidLegForFootpath_returnsValidCellViewModelForFootpath() {
        let leg = makeInvalidLegData(for: "footpath")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min walk")
    }



    func test_TripWithInvalidLegForBus_returnsValidCellViewModelForBus() {
        let leg = makeInvalidLegData(for: "Bus")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min, 0 Stops")
    }

    func test_TripWithInvalidLegForCycling_returnsValidCellViewModelForCycling() {
        let leg = makeInvalidLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Cycling")
    }

    func test_TripWithInvalidLegForTaxi_returnsValidCellViewModelForTaxi() {
        let leg = makeInvalidLegData(for: "Taxi")
        let sut = RouteCellViewModel(singleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Drive")
    }

    func test_tripWithInvalidMultipleModesWhere_Footpath_IsFirst_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "footpath")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.duration, "0 Min walk")
    }

    func test_tripWithInvalidMultipleModesWhere_Bus_IsFirst_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Bus")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min, 0 Stops")
    }

    func test_tripWithInvalidMultipleModesWhere_Cycling_IsFirst_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Cycling")
    }

    func test_tripWithInvalidMultipleModesWhere_Taxi_IsFirst_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Taxi")
        let sut = RouteCellViewModel(originLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Drive")
    }

    func test_tripWithInvalidMultipleModesWhere_Footpath_IsInBetween_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "footpath")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min walk")
    }

    func test_tripWithInvalidMultipleModesWhere_Bus_IsInBetween_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Bus")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min, 0 Stops")
    }

    func test_tripWithInvalidMultipleModesWhere_Cycling_IsInBetween_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Cycling")
    }

    func test_tripWithInvalidMultipleModesWhere_Taxi_IsInBetween_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Taxi")
        let sut = RouteCellViewModel(middleLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Drive")
    }

    func test_tripWithInvalidMultipleModesWhere_Footpath_IsLast_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "footpath")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .dotted)
        XCTAssertEqual(sut.image, Images.walkingIcon!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.duration, "0 Min walk")
    }

    func test_tripWithInvalidMultipleModesWhere_Bus_IsLast_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Bus")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeBus!)
        XCTAssertEqual(sut.stopName, "Bus 660")
        XCTAssertEqual(sut.stopAddress, "Dirab 10, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min, 0 Stops")
    }

    func test_tripWithInvalidMultipleModesWhere_Cycling_IsLast_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Fahrrad")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeCareem!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, "Arfat 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Cycling")
    }

    func test_tripWithInvalidMultipleModesWhere_Taxi_IsLast_returnsValidCellViewModel() {
        let leg = makeInvalidLegData(for: "Taxi")
        let sut = RouteCellViewModel(destinationLeg: leg)

        XCTAssertEqual(sut.line.1, .solid)
        XCTAssertEqual(sut.image, Images.transportModeUber!)
        XCTAssertEqual(sut.originAddress?.string, "Dirab 10, Riyadh, Riyadh")
        XCTAssertEqual(sut.destinationAddress?.string, ", Riyadh")
        XCTAssertEqual(sut.duration, "0 Min Drive")
    }

    // MARK: - Helpers
    private func makeSingleLegData(for mode: String) -> Leg {
        let data = Data("{\"duration\":120,\"distance\":30,\"origin\":{\"id\":\"originID\",\"name\":\"Dirab 10, Riyadh\",\"disassembledName\":\"Dirab 10\",\"parent\":{\"name\":\"Riyadh\",\"parent\":{\"name\":\"Riyadh\"}}},\"destination\":{\"id\":\"destId\",\"name\":\"Arfat 10, Riyadh\",\"disassembledName\":\"Arfat 10\",\"parent\":{\"name\":\"Riyadh\",\"parent\":{\"name\":\"Riyadh\"}}},\"transportation\":{\"name\":\"Bus 660\",\"product\":{\"name\":\"\(mode)\"}},\"stopSequence\":[{\"id\":\"\"},{\"id\":\"\"},{\"id\":\"\"}],\"coords\":[[24.12,42.21],[24.13,42.22],[24.14,42.24]]}".utf8)

        return try! JSONDecoder().decode(Leg.self, from: data)
    }

    private func makeInvalidLegData(for mode: String) -> Leg {
        let data = Data("{\"distance\":30,\"origin\":{\"id\":\"originID\",\"name\":\"Dirab 10, Riyadh\",\"parent\":{\"name\":\"Riyadh\"}},\"destination\":{\"id\":\"destId\",\"name\":\"Arfat 10, Riyadh\",\"parent\":{\"name\":\"Riyadh\",\"parent\":{\"name\":\"Riyadh\"}}},\"transportation\":{\"name\":\"Bus 660\",\"product\":{\"name\":\"\(mode)\"}},\"coords\":[[24.12,42.21],[24.13,42.22],[24.14,42.24]]}".utf8)

        return try! JSONDecoder().decode(Leg.self, from: data)
    }

}
