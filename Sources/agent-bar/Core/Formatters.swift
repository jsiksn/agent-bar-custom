import Foundation

enum TokenFormatters {
    private static let displayLocale = Locale(identifier: "en_US")

    private static func makeRelativeFormatter() -> RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = displayLocale
        return formatter
    }

    private static func makeCountdownFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        formatter.zeroFormattingBehavior = .dropAll
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = displayLocale
        formatter.calendar = calendar
        return formatter
    }

    static func compactTokenString(_ value: Int) -> String {
        let absolute = Double(abs(value))
        let sign = value < 0 ? "-" : ""

        switch absolute {
        case 1_000_000_000...:
            return "\(sign)\(String(format: "%.1f", absolute / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(String(format: "%.1f", absolute / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(String(format: "%.1f", absolute / 1_000))k"
        default:
            return "\(value)"
        }
    }

    static func percentageString(for utilization: Double?) -> String {
        guard let utilization else { return "--" }
        return "\(Int((utilization * 100).rounded()))%"
    }

    static func resetLabelString(from now: Date = .now, resetAt: Date?) -> String {
        guard let resetAt else { return "No reset time" }

        let interval = resetAt.timeIntervalSince(now)
        if interval <= 0 {
            return "Resets soon"
        }

        if interval < 60 {
            return "Resets in less than 1m"
        }

        if let formatted = makeCountdownFormatter().string(from: interval), formatted.isEmpty == false {
            return "Resets in \(formatted)"
        }

        return "Resets in \(makeRelativeFormatter().localizedString(for: resetAt, relativeTo: now))"
    }

    static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = displayLocale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func dateTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = displayLocale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func relativeUpdateString(from now: Date = .now, updatedAt: Date) -> String {
        let interval = abs(now.timeIntervalSince(updatedAt))
        if interval < 5 {
            return "just now"
        }
        return makeRelativeFormatter().localizedString(for: updatedAt, relativeTo: now)
    }
}
