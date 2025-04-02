//
//  UIImageView+.swift
//  Poppool
//
//  Created by SeoJunYoung on 12/3/24.
//

import UIKit

import Kingfisher

extension UIImageView {
    func setPPImage(path: String?) {
        guard let path = path else {
            self.image = UIImage(named: "image_default")
            return
        }
        let imageURLString = Secrets.popPoolS3BaseURL + path
        if let cenvertimageURL = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let imageURL = URL(string: cenvertimageURL)
            self.kf.setImage(with: imageURL) { result in
                switch result {
                case .failure(let error):
                    Logger.log(message: "\(path) image Load Fail: \(error.localizedDescription)", category: .error)
                default:
                    break
                }
            }
        }
    }
    
    func setPPImage(path: String?, completion: @escaping () -> Void) {
        guard let path = path else {
            self.image = UIImage(named: "image_default")
            completion()
            return
        }
        let imageURLString = Secrets.popPoolS3BaseURL + path
        if let cenvertimageURL = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let imageURL = URL(string: cenvertimageURL)
            self.kf.setImage(with: imageURL) { result in
                completion()
                switch result {
                case .failure(let error):
                    Logger.log(message: "\(path) image Load Fail: \(error.localizedDescription)", category: .error)
                default:
                    break
                }
            }
        }
    }
}
