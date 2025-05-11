import Foundation
import OSLog

public struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.poppoolIOS.poppool"

    public enum Level: Hashable {
        case info
        case debug
        case network
        case error
        case event
        case custom(name: String)

        var categoryName: String {
            switch self {
            case .info:
                return "Info"
            case .debug:
                return "Debug"
            case .network:
                return "Network"
            case .error:
                return "Error"
            case .event:
                return "Event"
            case .custom(let name): return name
            }
        }

        var categoryIcon: String {
            switch self {
            case .info:
                return "✅"
            case .debug:
                return "⚠️"
            case .network:
                return "🌎"
            case .error:
                return "⛔️"
            case .event:
                return "🎉"
            case .custom:
                return "🍎"
            }
        }
    }

    public enum LogLevel {
        case debug
        case info
        case error
        case fault

        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .error: return .error
            case .fault: return .fault
            }
        }
    }

    private static var isShowFileName: Bool = false
    private static var isShowLine: Bool = true
    private static var isShowLog: Bool = true

    private static var loggers: [Level: os.Logger] = [:]
    private static func getLogger(for category: Level) -> os.Logger {
        let categoryName = category.categoryName

        if let cachedLogger = loggers[category] {
            return cachedLogger
        }

        let logger = os.Logger(subsystem: subsystem, category: categoryName)
        loggers[category] = logger
        return logger
    }

    public static func log(
        _ message: Any,
        category: Level,
        level: LogLevel = .info,
        file: String = #file,
        line: Int = #line
    ) {
        guard isShowLog else { return }

        let logger = getLogger(for: category)
        var fullMessage = "\(category.categoryIcon) \(message)"

        if isShowFileName {
            let fileNameOnly = (file as NSString).lastPathComponent
            fullMessage += " | 📁 \(fileNameOnly)"
        }

        if isShowLine {
            fullMessage += " | 📍 \(line)"
        }

        logger.log(level: level.osLogType, "\(fullMessage, privacy: .public)")
    }
}
