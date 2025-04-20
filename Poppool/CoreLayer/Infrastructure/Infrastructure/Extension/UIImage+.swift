//
//  UIImage+.swift
//  Poppool
//
//  Created by SeoJunYoung on 11/25/24.
//

import UIKit

// UIImage를 색상으로 생성하는 Helper Extension
extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContext(size)
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
}

extension UIImage {
    func isBright(threshold: CGFloat = 0.5) -> Bool? {
        guard let cgImage = self.cgImage else { return nil }

        let width = 1
        let height = 1
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0

        // Brightness calculation formula
        let brightness = (red * 0.299 + green * 0.587 + blue * 0.114)

        return brightness > threshold
    }
}
