import Foundation

let tracker1 = Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .ypSelection2, emoji: "😻", timetable: [.wednesday, .thursday])

let tracker2 = Tracker(id: UUID(), name: "Мама прислала открытку", color: .ypSelection1, emoji: "🌺", timetable: [.monday,.tuesday, .wednesday, .friday])

let tracker3 = Tracker(id: UUID(), name: "Свидание", color: .ypSelection14, emoji: "❤️", timetable: [.saturday, .sunday])

let tracker4 = Tracker(id: UUID(), name: "Поливать растения", color: .ypSelection5, emoji: "🌺", timetable: [.friday, .saturday, .wednesday])

let trackersHabits = TrackerCategory(title: "Домашний уют", trackers: [tracker4])

let trackersEvents = TrackerCategory(title: "Радостные мелочи", trackers: [tracker1, tracker2, tracker3])
