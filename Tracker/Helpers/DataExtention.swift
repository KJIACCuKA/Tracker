import Foundation

extension Date {
    var startOfDay: Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString) ?? Date()
    }
}
