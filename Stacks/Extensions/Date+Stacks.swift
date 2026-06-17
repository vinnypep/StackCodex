import Foundation

extension Date {
    var stackHeaderDate: String {
        formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

