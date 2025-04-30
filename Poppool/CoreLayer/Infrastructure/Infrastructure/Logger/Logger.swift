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
            case .error:
                return .error
            case .fault:
                return .fault
            }
        }
    }

    /// : 아래 옵션 주석 해제시 파일명/라인 번호를 로그 메시지에 포함
    // private static var isShowFileName: Bool = false // 파일 이름 포함 여부
    // private static var isShowLine: Bool = true     // 라인 번호 포함 여부
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

    /// : 파일명과 라인 정보 파라미터 포함
    // public static func log(
    //     _ message: Any,
    //     category: Level,
    //     level: LogLevel = .info,
    //     fileName: String = #file,
    //     line: Int = #line
    // ) {
    public static func log(
        _ message: Any,
        category: Level,
        level: LogLevel = .info
    ) {
        guard isShowLog else { return }

        let logger = getLogger(for: category)
        let fullMessage = "\(category.categoryIcon) \(message)"

        logger.log(level: level.osLogType, "\(fullMessage, privacy: .public)")
    }
}
