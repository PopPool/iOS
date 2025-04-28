import Foundation
import OSLog

public struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.poppoolIOS.poppool"

    public enum Level {
        case info
        case debug
        case network
        case error
        case event
        case custom(categoryName: String)

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
            case .custom(let categoryName):
                return categoryName
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

        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info, .event:
                return .info
            case .network:
                return .default
            case .error:
                return .error
            case .custom:
                return .default
            }
        }
    }

    static var isShowFileName: Bool = false // 파일 이름 포함여부
    static var isShowLine: Bool = true // 라인 번호 포함 여부
    static var isShowLog: Bool = true

    private static var loggers: [String: os.Logger] = [:]
    private static func getLogger(for category: Level) -> os.Logger {
        let categoryName = category.categoryName

        if let cachedLogger = loggers[categoryName] {
            return cachedLogger
        }

        let logger = os.Logger(subsystem: subsystem, category: categoryName)
        loggers[categoryName] = logger
        return logger
    }

    public static func log(
        message: Any,
        category: Level,
        fileName: String = #file,
        line: Int = #line
    ) {
        guard isShowLog else { return }

        let logger = getLogger(for: category)
        var fullMessage = "\(category.categoryIcon) \(message)"

        if isShowFileName {
            guard let fileNameOnly = fileName.components(separatedBy: "/").last else { return }
            fullMessage += " | 📁 \(fileNameOnly)"
        }

        if isShowLine {
            fullMessage += " | 📍 \(line)"
        }

        logger.log(level: category.osLogType, "\(fullMessage, privacy: .public)")

        // 디버깅 시 Xcode 콘솔에서도 바로 확인할 수 있도록 print도 함께 사용 불필요시 제거
        print("\(category.categoryIcon) [\(category.categoryName)]: \(message)")
        if isShowFileName {
            guard let fileNameOnly = fileName.components(separatedBy: "/").last else { return }
            print(" \(category.categoryIcon) [FileName]: \(fileNameOnly)")
        }
        if isShowLine {
            print(" \(category.categoryIcon) [Line]: \(line)")
        }
    }
}
