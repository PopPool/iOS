import UIKit
import SnapKit
import GoogleMaps

final class MapMarker: UIView {
   // MARK: - Components
   private let markerImageView: UIImageView = {
       let imageView = UIImageView()
       imageView.image = UIImage(named: "Marker")
       imageView.contentMode = .scaleAspectFit
       return imageView
   }()

   private let clusterContainer: UIView = {
       let view = UIView()
       view.backgroundColor = .white
       view.layer.cornerRadius = 12
       view.layer.borderWidth = 1
       view.layer.borderColor = UIColor.black.cgColor
       return view
   }()

   private let labelStackView: UIStackView = {
       let stack = UIStackView()
       stack.axis = .horizontal
       stack.spacing = 4
       return stack
   }()

   private let regionLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 13)
       label.textColor = .black
       return label
   }()

   private let countLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 13)
       label.textColor = .red
       return label
   }()

   // MARK: - Init
   init() {
       super.init(frame: .zero)
       self.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
       setUpConstraints()
   }

   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}

// MARK: - SetUp
private extension MapMarker {
   func setUpConstraints() {
       addSubview(markerImageView)
       addSubview(clusterContainer)
       clusterContainer.addSubview(labelStackView)
       labelStackView.addArrangedSubview(regionLabel)
       labelStackView.addArrangedSubview(countLabel)

       // 전체 뷰 크기 제약조건
       self.snp.makeConstraints { make in
           make.width.height.equalTo(200)  // 충분히 큰 크기로 설정
       }

       // 마커 이미지뷰 제약조건
       markerImageView.snp.makeConstraints { make in
           make.center.equalToSuperview()
           make.size.equalTo(32)
       }

       // 클러스터 컨테이너 제약조건
       clusterContainer.snp.makeConstraints { make in
           make.center.equalToSuperview()
           make.height.equalTo(24)
           make.width.equalTo(200)
       }

       labelStackView.snp.makeConstraints { make in
           make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
       }

       // 초기 상태 설정
       clusterContainer.isHidden = true
   }

   func updateMarkerImage(isSelected: Bool) {
       let imageName = isSelected ? "TapMarker" : "Marker"
       let size = isSelected ? 44 : 32
       markerImageView.image = UIImage(named: imageName)

       markerImageView.snp.updateConstraints { make in
           make.size.equalTo(size)
       }

       layoutIfNeeded()
   }
}

// MARK: - Inputable
extension MapMarker: Inputable {
   struct Input {
       var isSelected: Bool = false
       var isCluster: Bool = false
       var regionName: String = ""
       var count: Int = 0
   }

    func injection(with input: Input) {
        if input.isCluster {
            markerImageView.isHidden = true
            clusterContainer.isHidden = false
            regionLabel.text = input.regionName
            countLabel.text = "\(input.count)"

            // 텍스트 크기에 따른 너비 계산을 위해 우선 레이아웃 업데이트
            layoutIfNeeded()

            // 스택뷰의 실제 콘텐츠 크기 계산
            let contentWidth = labelStackView.systemLayoutSizeFitting(
                CGSize(width: UIView.layoutFittingCompressedSize.width, height: 24)
            ).width

            // 좌우 패딩 16 추가
            let totalWidth = contentWidth + 16

            Logger.log(message: "클러스터 마커 크기 계산: contentWidth: \(contentWidth), totalWidth: \(totalWidth)", category: .debug)

            // 컨테이너 너비 업데이트
            clusterContainer.snp.updateConstraints { make in
                make.width.equalTo(totalWidth)
            }
        } else {
            markerImageView.isHidden = false
            clusterContainer.isHidden = true
            updateMarkerImage(isSelected: input.isSelected)
        }
    }

}
