//Created for churchApp  (26.09.2020 )
 
import UIKit

extension Date {
    private static var cachedDateFormatters = [String: DateFormatter]()
    
    func toString(format: DateFormatType, timeZone: TimeZoneType = .current, locale: Locale = Locale.current, ampmSymbolsLowercased: Bool = false) -> String {
        let formatter = Date.cachedFormatter(format.stringFormat, timeZone: timeZone.timeZone, locale: locale)
        let stringedDate: String
        
        if ampmSymbolsLowercased {
            let origAmPm: (String, String) = (formatter.amSymbol, formatter.pmSymbol)
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            stringedDate = formatter.string(from: self)
            formatter.amSymbol = origAmPm.0
            formatter.pmSymbol = origAmPm.1
        } else {
            stringedDate = formatter.string(from: self)
        }
        
        return stringedDate
    }
    
    private static func cachedFormatter(_ format: String = DateFormatType.standard.stringFormat, timeZone: Foundation.TimeZone = Foundation.TimeZone.current, locale: Locale = Locale.current) -> DateFormatter {
        let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        if Date.cachedDateFormatters[hashKey] == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = timeZone
            formatter.locale = locale
            formatter.isLenient = true
            Date.cachedDateFormatters[hashKey] = formatter
        }
        return Date.cachedDateFormatters[hashKey]!
    }

    func changeTime(from: Date) -> Date{
        let date1 = self
        let date2 = from
        var calendar = Calendar(identifier: .iso8601)
        let utcTimeZone = TimeZone(secondsFromGMT: 0)!
        calendar.timeZone = utcTimeZone
        let date1Comp = calendar.dateComponents([.year, .month, .day], from: date1)
        let date2Comp = calendar.dateComponents([.hour, .minute, .second], from: date2)
        var newDateComp = DateComponents()
        newDateComp.timeZone = utcTimeZone
        if let year = date1Comp.year,
           let month = date1Comp.month,
           let day = date1Comp.day,
           let hour = date2Comp.hour,
           let minute = date2Comp.minute,
           let second = date2Comp.second {
            newDateComp.year = year
            newDateComp.month = month
            newDateComp.day = day
            newDateComp.hour = hour
            newDateComp.minute = minute
            newDateComp.second = second
        }
        if let date = calendar.date(from: newDateComp) {
            return date
        }
        
        return self // Cannot change time, set to default time
    }
 
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func endDateOfTheWeek() -> Date {
        let calendar = Calendar.current
        let add6daysToCurrentDate = calendar.date(byAdding: .day, value: 6, to: self)
        return add6daysToCurrentDate!
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    func getWeekday() -> Weekday{
        let calendar = Calendar(identifier: .gregorian)
        let weekdayIndex = calendar.component(.weekday, from: self)
        let weekday = getWeekDaysInEnglish()[weekdayIndex - 1]
        return Weekday(rawValue: weekday.lowercased()) ?? .sunday
    }
    
    enum SearchDirection {
        case next
        case previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
    
    /**
Returns a different format depending on the distance of the given date from today.
     Chaining conditions:
     1. Is within today -> "h:mm a"
     2. Is within last week -> "E"
     3. Is past last week -> "MMM d"
     4. Is last year -> "MMM d, yyyy"
     */
    var formattedDateString: String {
        var dateFormat: String? = nil
        let cal = Calendar.current
        
        let isToday = cal.isDateInToday(self)
        if isToday {
            dateFormat = "h:mm a"
        } else {
            if let lastWeek = cal.date(byAdding: .day, value: -7, to: Date()) {
                let startOfLastWeek = cal.startOfDay(for: lastWeek)
                let startOfGivenDate = cal.startOfDay(for: self)
                let dateDiffComp = cal.dateComponents([.day], from: startOfLastWeek, to: startOfGivenDate)
                let isWithinLastWeek = (dateDiffComp.day ?? 0) > 0
                if isWithinLastWeek {
                    dateFormat = "E"
                } else {
                    let date1Comp = cal.dateComponents([.year], from: self)
                    let date2Comp = cal.dateComponents([.year], from: Date())
                    if let year1 = date1Comp.year,
                       let year2 = date2Comp.year,
                       year1 != year2 {
                        dateFormat = "MMM d '’'yy"
                    }
                }
            }
        }
        guard let dateFormat = dateFormat else {
            return self.toString(format: .custom("MMM d"), ampmSymbolsLowercased: true)
        }
        return self.toString(format: .custom(dateFormat), ampmSymbolsLowercased: true)
    }
    
    func getElapsedInterval() -> String {

        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())

        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"

        }

    }
}

public enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}


public enum DateFormatType {
    /// "MM.dd.yyyy" i.e. 07.16.1997
    case mmddyyyyDots
    
    case mmddyyyyDashes

    /// "yyyy" i.e. 1997
    case yyyy
    
    /// "yyyy-MM" i.e. 1997-07
    case yyyymmDashes

    /// "yyyy-MM-dd" i.e. 1997-07-16
    case yyyymmddDashes
    
    /// "yyyy-MM-dd'T'HH:mm:ssZ"
    case standard
    
    /// "yyyy-MM-dd'T'HH:mm:ss.SSZ"
    case standardFullSS

    /// "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case standardFull
    
    /// EE, MMMM dd 'at' h:mma
    case shortWeekdayLongMonthDateAtTime
    
    /// EE, MMM dd 'at' h:mma
    case shortWeekdayMonthDateAtTime
    
    /// EEE's' 'at' h:mma
    case weekdayAtTime
    
    /// h:mma
    case hoursAndMinutes
    
    /// MMMM d, yyyy
    case fullMonth
    
    /// MMM d· hh:mm a
    case monthDayTime
    
    /// A custom date format string
    case custom(String)
    
    var stringFormat: String {
        switch self {
        case .fullMonth: return "MMMM d, yyyy"
        case .mmddyyyyDots: return "MM.dd.yyyy"
        case .mmddyyyyDashes: return "MM/dd/yyyy"
        case .yyyy: return "yyyy"
        case .yyyymmDashes: return "yyyy-MM"
        case .yyyymmddDashes: return "yyyy-MM-dd"
        case .hoursAndMinutes: return "h:mma"
        case .monthDayTime: return "MMM d · hh:mm a"

            
        case .standard: return "yyyy-MM-dd'T'HH:mm:ssZ"
        case .standardFullSS: return "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        case .standardFull: return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case .shortWeekdayLongMonthDateAtTime: return "EE, MMMM dd 'at' h:mma"
        case .shortWeekdayMonthDateAtTime: return "EE, MMM dd 'at' h:mma"
        case .weekdayAtTime: return "EEEE's' 'at' h:mma"
            
        case .custom(let customFormat): return customFormat
        }
    }
}

/// The time zone to be used for date conversion
public enum TimeZoneType {
    case current, utc
    var timeZone: TimeZone {
        switch self {
        case .current: return TimeZone.current
        case .utc: return TimeZone(secondsFromGMT: 0)!
        }
    }
}

extension String {
    func toDate(formattedAs format: DateFormatType = .standard, timeZone: TimeZone = TimeZone.current) -> Date? { //todo: - check for other usages
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = format.stringFormat
        return formatter.date(from: self)
    }
    
    func toStandardDate() -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = DateFormatType.standard.stringFormat
        return formatter.date(from: self)
    }
}
