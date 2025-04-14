//
//  SelectableImage.swift
//  Poppool
//
//  Created by 김기현 on 1/13/25.
//

import Foundation
import UIKit

public struct ExtendedImage: Equatable {
    public var filePath: String
    public var image: UIImage
    public var isMain: Bool

    public init(filePath: String, image: UIImage, isMain: Bool) {
        self.filePath = filePath
        self.image = image
        self.isMain = isMain
    }

    // MARK: - Equatable
    public static func == (lhs: ExtendedImage, rhs: ExtendedImage) -> Bool {
        return lhs.filePath == rhs.filePath && lhs.isMain == rhs.isMain
    }
}
