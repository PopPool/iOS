import Foundation

public extension String {
    var isHangul: Bool {
        return "\(self)".range(of: "\\p{Hangul}", options: .regularExpression) != nil
    }
}
