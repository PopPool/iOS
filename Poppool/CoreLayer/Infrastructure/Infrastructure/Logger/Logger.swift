import Foundation

public struct Logger {
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
    }

    static var isShowFileName: Bool = false
    static var isShowLine: Bool = false
    static var isShowLog: Bool = true

    public static func log(
        message: Any,
        category: Level,
        fileName: String = "Input is not found",
        line: Int? = nil
    ) {
        if isShowLog {
            print("\(category.categoryIcon) [\(category.categoryName)]: \(message)")
            if isShowFileName {
                guard let fileName = fileName.components(separatedBy: "/").last else { return }
                print(" \(category.categoryIcon) [FileName]: \(fileName)")
            }
            if isShowLine {
                guard let line = line else { return }
                print(" \(category.categoryIcon) [Line]: \(line)")
            }
        }
    }
}
