
import Foundation
import UIKit

// MARK: - Font cases
public enum PoppoolFont {
    // 한국어 Typeface Guide
    case KOl32, KOl28, KOl24, KOl20, KOl18, KOl16, KOl15, KOl14, KOl13, KOl12, KOl11
    case KOr32, KOr28, KOr24, KOr20, KOr18, KOr16, KOr15, KOr14, KOr13, KOr12, KOr11
    case KOm32, KOm28, KOm24, KOm20, KOm18, KOm16, KOm15, KOm14, KOm13, KOm12, KOm11
    case KOb32, KOb28, KOb24, KOb20, KOb18, KOb16, KOb15, KOb14, KOb13, KOb12, KOb11

    // 영어 Typeface Guide
    case ENl32, ENl28, ENl24, ENl20, ENl18, ENl16, ENl15, ENl14, ENl13, ENl12, ENl11
    case ENr32, ENr28, ENr24, ENr20, ENr18, ENr16, ENr15, ENr14, ENr13, ENr12, ENr11
    case ENm32, ENm28, ENm24, ENm20, ENm18, ENm16, ENm15, ENm14, ENm13, ENm12, ENm11
    case ENb32, ENb28, ENb24, ENb20, ENb18, ENb16, ENb15, ENb14, ENb13, ENb12, ENb11
}

// MARK: - Font size
extension PoppoolFont {
    /// 폰트 패밀리 크기
    public var size: CGFloat {
        switch self {
        case .KOl32, .KOr32, .KOm32, .KOb32, .ENl32, .ENr32, .ENm32, .ENb32: return 32
        case .KOl28, .KOr28, .KOm28, .KOb28, .ENl28, .ENr28, .ENm28, .ENb28: return 28
        case .KOl24, .KOr24, .KOm24, .KOb24, .ENl24, .ENr24, .ENm24, .ENb24: return 24
        case .KOl20, .KOr20, .KOm20, .KOb20, .ENl20, .ENr20, .ENm20, .ENb20: return 20
        case .KOl18, .KOr18, .KOm18, .KOb18, .ENl18, .ENr18, .ENm18, .ENb18: return 18
        case .KOl16, .KOr16, .KOm16, .KOb16, .ENl16, .ENr16, .ENm16, .ENb16: return 16
        case .KOl15, .KOr15, .KOm15, .KOb15, .ENl15, .ENr15, .ENm15, .ENb15: return 15
        case .KOl14, .KOr14, .KOm14, .KOb14, .ENl14, .ENr14, .ENm14, .ENb14: return 14
        case .KOl13, .KOr13, .KOm13, .KOb13, .ENl13, .ENr13, .ENm13, .ENb13: return 13
        case .KOl12, .KOr12, .KOm12, .KOb12, .ENl12, .ENr12, .ENm12, .ENb12: return 12
        case .KOl11, .KOr11, .KOm11, .KOb11, .ENl11, .ENr11, .ENm11, .ENb11: return 11
        }
    }
}

// MARK: - Font name
extension PoppoolFont {
    /// 폰트 패밀리 이름
    public var fontName: String {
        switch self {
        case .KOl32, .KOl28, .KOl24, .KOl20, .KOl18, .KOl16, .KOl15, .KOl14, .KOl13, .KOl12, .KOl11: return "GothicA1-Light"
        case .KOr32, .KOr28, .KOr24, .KOr20, .KOr18, .KOr16, .KOr15, .KOr14, .KOr13, .KOr12, .KOr11: return "GothicA1-Regular"
        case .KOm32, .KOm28, .KOm24, .KOm20, .KOm18, .KOm16, .KOm15, .KOm14, .KOm13, .KOm12, .KOm11: return "GothicA1-Medium"
        case .KOb32, .KOb28, .KOb24, .KOb20, .KOb18, .KOb16, .KOb15, .KOb14, .KOb13, .KOb12, .KOb11: return "GothicA1-Bold"

        case .ENl32, .ENl28, .ENl24, .ENl20, .ENl18, .ENl16, .ENl15, .ENl14, .ENl13, .ENl12, .ENl11: return "Poppins-Light"
        case .ENr32, .ENr28, .ENr24, .ENr20, .ENr18, .ENr16, .ENr15, .ENr14, .ENr13, .ENr12, .ENr11: return "Poppins-Regular"
        case .ENm32, .ENm28, .ENm24, .ENm20, .ENm18, .ENm16, .ENm15, .ENm14, .ENm13, .ENm12, .ENm11: return "Poppins-Medium"
        case .ENb32, .ENb28, .ENb24, .ENb20, .ENb18, .ENb16, .ENb15, .ENb14, .ENb13, .ENb12, .ENb11: return "Poppins-Bold"
        }
    }
}

// MARK: - Font line height
extension PoppoolFont {
    /// 폰트 패밀리 행간
    public var lineHeight: CGFloat {
        switch self {
            //
        case .KOl28, .KOl24, .KOl20, .KOl18, .KOl16, .KOl15, .KOl14, .KOl13, .KOl12, .KOl11,
             .KOr28, .KOr24, .KOr20, .KOr18, .KOr16, .KOr15, .KOr14, .KOr13, .KOr12, .KOr11,
             .KOm28, .KOm24, .KOm20, .KOm18, .KOm16, .KOm15, .KOm14, .KOm13, .KOm12, .KOm11:
            return 1.5

        case .KOl32, .KOr32, .KOm32, .KOb32, .KOb28, .KOb24, .KOb20, .KOb18, .KOb16, .KOb15, .KOb14, .KOb13, .KOb12, .KOb11:
            return 1.4

        case .ENl32, .ENl28, .ENl24, .ENl20, .ENl18, .ENl16, .ENl15, .ENl14, .ENl13, .ENl12, .ENl11,
             .ENr32, .ENr28, .ENr24, .ENr20, .ENr18, .ENr16, .ENr15, .ENr14, .ENr13, .ENr12, .ENr11,
             .ENm32, .ENm28, .ENm24, .ENm20, .ENm18, .ENm16, .ENm15, .ENm14, .ENm13, .ENm12, .ENm11,
             .ENb32, .ENb28, .ENb24, .ENb20, .ENb18, .ENb16, .ENb15, .ENb14, .ENb13, .ENb12, .ENb11:
            return 1.35
        }
    }
}
