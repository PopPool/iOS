//
//  UIColor+.swift
//  PopPool
//
//  Created by Porori on 6/20/24.
//

import UIKit

public extension UIColor {

    // 무채색 컬러
    static let g50 = UIColor(hexCode: "F2F5F7")
    static let g100 = UIColor(hexCode: "DFE2E6")
    static let g200 = UIColor(hexCode: "AFB7C0")
    static let g300 = UIColor(hexCode: "808E9C")
    static let g400 = UIColor(hexCode: "808E9C")
    static let g500 = UIColor(hexCode: "626F7F")
    static let g600 = UIColor(hexCode: "444E5C")
    static let g700 = UIColor(hexCode: "2D3540")
    static let g800 = UIColor(hexCode: "1F242B")
    static let g900 = UIColor(hexCode: "17191C")
    static let g1000 = UIColor(hexCode: "141414")

    // 화이트 톤
    static let w4 = UIColor(hexCode: "ffffff", alpha: 0.04)
    static let w7 = UIColor(hexCode: "ffffff", alpha: 0.07)
    static let w10 = UIColor(hexCode: "ffffff", alpha: 0.1)
    static let w30 = UIColor(hexCode: "ffffff", alpha: 0.3)
    static let w50 = UIColor(hexCode: "ffffff", alpha: 0.5)
    static let w70 = UIColor(hexCode: "ffffff", alpha: 0.7)
    static let w90 = UIColor(hexCode: "ffffff", alpha: 0.9)
    static let w100 = UIColor(hexCode: "ffffff", alpha: 1.0)

    // 퓨어 블랙
    static let pb4 = UIColor(hexCode: "141414", alpha: 0.04)
    static let pb7 = UIColor(hexCode: "141414", alpha: 0.07)
    static let pb10 = UIColor(hexCode: "141414", alpha: 0.1)
    static let pb30 = UIColor(hexCode: "141414", alpha: 0.3)
    static let pb50 = UIColor(hexCode: "141414", alpha: 0.5)
    static let pb60 = UIColor(hexCode: "141414", alpha: 0.6)
    static let pb70 = UIColor(hexCode: "141414", alpha: 0.7)
    static let pb90 = UIColor(hexCode: "141414", alpha: 0.9)
    static let pb100 = UIColor(hexCode: "141414", alpha: 1.0)

    // 블루
    static let blu100 = UIColor(hexCode: "E5EEFF")
    static let blu200 = UIColor(hexCode: "B5CCFE")
    static let blu300 = UIColor(hexCode: "81ABFD")
    static let blu400 = UIColor(hexCode: "4F89FC")
    static let blu500 = UIColor(hexCode: "1562FC")
    static let blu600 = UIColor(hexCode: "043FC9")
    static let blu700 = UIColor(hexCode: "023197")
    static let blu800 = UIColor(hexCode: "022364")
    static let blu900 = UIColor(hexCode: "011132")

    // 제이드
    static let jd100 = UIColor(hexCode: "E6FFFA")
    static let jd200 = UIColor(hexCode: "CCFFF6")
    static let jd300 = UIColor(hexCode: "99FFEC")
    static let jd400 = UIColor(hexCode: "66FFE3")
    static let jd500 = UIColor(hexCode: "03FFD0")
    static let jd600 = UIColor(hexCode: "00E6BD")
    static let jd700 = UIColor(hexCode: "00CCA7")
    static let jd800 = UIColor(hexCode: "00997D")
    static let jd900 = UIColor(hexCode: "00997D")
    static let jd1000 = UIColor(hexCode: "004D3E")

    // 레드
    static let re100 = UIColor(hexCode: "FFE6E5")
    static let re200 = UIColor(hexCode: "FFCCCC")
    static let re300 = UIColor(hexCode: "FF999A")
    static let re400 = UIColor(hexCode: "FF6666")
    static let re500 = UIColor(hexCode: "FF0000")
    static let re600 = UIColor(hexCode: "E60001")
    static let re700 = UIColor(hexCode: "B30100")
    static let re800 = UIColor(hexCode: "800000")
    static let re900 = UIColor(hexCode: "4D0000")

    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
            var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

            if hexFormatted.hasPrefix("#") {
                hexFormatted = String(hexFormatted.dropFirst())
            }

            assert(hexFormatted.count == 6, "Invalid hex code used.")

            var rgbValue: UInt64 = 0
            Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: alpha)
        }
}
