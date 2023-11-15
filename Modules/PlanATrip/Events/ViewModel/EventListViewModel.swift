//
//  EventListViewModel.swift
//  RCRC
//
//  Created by Errol on 22/06/21.
//

import Foundation
import GoogleMaps

struct EventListViewModel {
    let eventsLoader: EventsLoader
    typealias EventsDisplayData = (currentEvents: [EventCellViewModel], upcomingEvents: [EventCellViewModel])

    init(eventsLoader: EventsLoader) {
        self.eventsLoader = eventsLoader
    }

    func searchEvents(keyword: String, completion: @escaping (EventsDisplayData) -> Void) {
        eventsLoader.searchEvents(keyword: keyword) { result in
            completion(handleResult(result))
        }
    }

    func loadEvents(completion: @escaping (EventsDisplayData) -> Void) {
        eventsLoader.fetchEvents { result in
            completion(handleResult(result))
        }
    }

    private func handleResult(_ result: Result<[Event], Error>) -> EventsDisplayData {
        switch result {
        case let .success(events):
            return handleResultData(events)
        case .failure:
            return ([], [])
        }
    }

    private func handleResultData(_ data: [Event]) -> EventsDisplayData {
        let events = data.map { makeCellViewModel($0) }
        return mapEvents(events)
    }

    private func mapEvents(_ events: [EventCellViewModel]) -> EventsDisplayData {
        let currentEvents = events.filter { $0.eventType == .current }
        let upcomingEvents = events.filter { $0.eventType == .upcoming }
        return (currentEvents, upcomingEvents)
    }

    private func makeCellViewModel(_ data: Event) -> EventCellViewModel {

        let coordinateArray = data.coordinates.split(separator: ",")
        var coordinate: CLLocationCoordinate2D?
        if coordinateArray.count == 2 {
            let latitude = String(coordinateArray[0]).toDouble()
            let longitude = String(coordinateArray[1]).toDouble()
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        let eventStartString = Utilities.shared.getAttributedText(data.startDate, data.startTime + " to ", Fonts.RptaSignage.seventeen!, Fonts.RptaSignage.seventeen!)
        let eventEndString = Utilities.shared.getAttributedText(data.endDate, data.endTime, Fonts.RptaSignage.seventeen!, Fonts.RptaSignage.seventeen!)
        eventStartString.append(eventEndString)
        let eventDuration = eventStartString

        let entryFee = Utilities.shared.getAttributedText(firstString: Constants.entryFee,
                                                          secondString: data.price + " SAR",
                                                          firstFont: (Fonts.RptaSignage.fifteen!, .white),
                                                          secondFont: (Fonts.RptaSignage.fifteen!, .white))
        let eventType = getEventType(startDate: (data.startDate, data.startTime), endDate: (data.endDate, data.endTime))
        let urlString = data.imagesEn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fileUrl = URL(string: urlString)
        return EventCellViewModel(name: data.nameEn, duration: eventDuration, imageURL: fileUrl ?? URL(fileURLWithPath: data.imagesEn) , entryFee: entryFee, description: data.descriptionEn, coordinate: coordinate, entryCost: data.price, eventType: eventType)
    }

    private func getEventType(startDate: (date: String, time: String), endDate: (date: String, time: String)) -> EventType {
        let currentDate = Date()
        let dateFormat = Constants.dateFormatForEvents

        let eventStartDateString = startDate.date + startDate.time
        let eventStartDate = eventStartDateString.toDate(withFormat: dateFormat, timeZone: .AST)

        let eventEndDateString = endDate.date + endDate.time
        let eventEndDate = eventEndDateString.toDate(withFormat: dateFormat, timeZone: .AST)

        guard let eventStartDate = eventStartDate else { return .current }
        guard let eventEndDate = eventEndDate else { return .current }
        
        if eventStartDate <= currentDate, eventEndDate >= currentDate {
            return .current
        }
        if eventStartDate > currentDate {
            return .upcoming
        }
        return .completed
    }
}
