//
//  DateExtensions.swift
//  RCRC
//
//  Created by Errol on 28/10/20.
//

import Foundation

// MARK: - Date Extensions
extension Date {
    // Constant date formatter
    static let dateTimeHistoryFull = "dd/MM/yyyy | h:mm a"
    static let dateTime = "dd MM yyyy | h:mm a"
    static let dateTimeDOB = "dd/MM/yyyy"
    static let dateTimeDOBAPI = "yyyy-MM-dd"
    static let recordDate = "dd/MM/yy"
    
    // Conversion of Date to String
    // Default Format is ISO8601
    func toString(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ", timeZone: TimeZones) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.rawValue)
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }

    func toStringCurrentTimeZone(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
    
    func toString(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    // Milliseconds to Date
    // Date in UTC
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    // Comparison of Dates
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }

    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }

    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }

    func dayIndexOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }

    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self).capitalized
    }

    var dateString: String {
        return toString(withFormat: "yyyyMMdd", timeZone: .AST)
    }

    var date: String {
        return toString(withFormat: "dd", timeZone: .AST)
    }

    var hour: Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.hour, from: self)
    }

    var minute: Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.minute, from: self)
    }
    
    var seconds: Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.second, from: self)
    }
    
    func adding(minutes: Int) -> Date {
            return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
        }
    
    func adding(seconds: Int) -> Date {
            return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
        }
    func isBetween(_ start: Date, _ end: Date) -> Bool {
        start...end ~= self
    }
    
    func subtracting(days: Int) -> Date {
            return Calendar.current.date(byAdding: .day, value: days, to: self)!
        }
    
    func subtracting(hours: Int) -> Date {
            return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
        }
    
    func subtracting(mins: Int) -> Date {
            return Calendar.current.date(byAdding: .minute, value: mins, to: self)!
        }

    func subtracting(months: Int) -> Date? {
        if let date = Calendar.current.date(byAdding: .month, value:months, to: self) {
            return date
        } else {
            return nil
        }
    }
    
    func fetchMonth() -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.month, .year], from: self)
        return dateComponents.month ?? 0
    }
    
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.date(bySettingHour: 0, minute: 1, second: 1, of: self) //dateComponents([.year, .month, .day], from: self)
//            dateComponents.timeZone = TimeZone(secondsFromGMT: TimeZones.AST.rawValue)
            return dateComponents//calender.date(from: dateComponents)
        }
    }
    
    func makeDayPredicate() -> NSPredicate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        return NSPredicate(format: "day >= %@ AND day =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func makeStartDayPredicate(recordDate: Date) -> NSPredicate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        return NSPredicate(format: " %@ >= %@", argumentArray: [recordDate, startDate!])
    }
    
    func makeEndDayPredicate() -> NSPredicate {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        return NSPredicate(format: "day >= %@ AND day =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func getStartDayDate() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 00
        components.minute = 01
        components.second = 01
        let startDate = calendar.date(from: components)
        print("startDatessss : \(startDate)")
        return startDate ?? Date()
        //return NSPredicate(format: " %@ >= %@", argumentArray: [recordDate, startDate!])
    }
}
