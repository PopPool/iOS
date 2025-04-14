import UIKit

extension UIImageView {
    func setPPImage(path: String?) {
        guard let path = path else {
            self.image = UIImage(named: "image_default")
            return
        }
        let imageURLString = Secrets.popPoolS3BaseURL + path
        if let cenvertimageURL = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            ImageLoader.shared.loadImage(with: cenvertimageURL, defaultImage: UIImage(named: "image_default"), imageQuality: .origin) { [weak self] image in
                DispatchQueue.main.async {
                    self?.image = image
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
            ImageLoader.shared.loadImage(with: cenvertimageURL, defaultImage: UIImage(named: "image_default"), imageQuality: .origin) { [weak self] image in
                DispatchQueue.main.async {
                    completion()
                    self?.image = image
                }
            }
        }
    }
}
