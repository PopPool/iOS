import Foundation

public extension UInt64 {
	static func seconds(_ seconds: Double) -> Self {
		return UInt64(seconds * 1_000_000_000)
	}
}
