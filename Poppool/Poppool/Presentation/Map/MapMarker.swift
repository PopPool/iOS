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
          view.backgroundColor = .blu500
          view.layer.cornerRadius = 12
          view.layer.borderWidth = 0
          return view
      }()
    private let countBadgeView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            view.layer.borderColor = UIColor.blue.cgColor
            view.layer.borderWidth = 2
            view.layer.masksToBounds = true
            view.isHidden = true // 초기에는 숨겨놓음 (겹치는 개수 1 이하일 때)
            return view
        }()
    private let badgeCountLabel: UILabel = {
           let label = UILabel()
           label.font = .boldSystemFont(ofSize: 10)
           label.textColor = .blue
           label.textAlignment = .center
           return label
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
       label.textColor = .white
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
       

       self.snp.makeConstraints { make in
           make.width.equalTo(200)
           make.height.equalTo(70)

       }

       markerImageView.snp.makeConstraints { make in
           // 예) 하단 중앙 정렬
           make.centerX.equalToSuperview()
           make.bottom.equalToSuperview()       // 커스텀 뷰의 bottom이 곧 "마커 이미지 bottom"
           make.width.height.equalTo(32)        // 이미지 크기
       }


       // 클러스터 컨테이너 제약조건
       clusterContainer.snp.makeConstraints { make in
           make.center.equalToSuperview()
           make.height.equalTo(24)
           make.width.equalTo(80)
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
       var isMultiMarker: Bool = false
   }

    func injection(with input: Input) {
        if input.isCluster {
            // 클러스터 마커 처리 (기존과 동일)
            markerImageView.isHidden = true
            clusterContainer.isHidden = false
            regionLabel.text = input.regionName
            regionLabel.textColor = .w100
            countLabel.text = "\(input.count)"

            if let previousText = regionLabel.text,
               previousText == input.regionName {
                // 기존 제약조건 유지
            } else {
                self.layoutIfNeeded()
                let contentWidth = labelStackView.systemLayoutSizeFitting(
                    CGSize(width: UIView.layoutFittingCompressedSize.width, height: 24)
                ).width
                let totalWidth = contentWidth + 16
                clusterContainer.snp.updateConstraints { make in
                    make.width.equalTo(totalWidth)
                }
            }

        } else {
            // 단일 마커 처리
            markerImageView.isHidden = false
            clusterContainer.isHidden = true
            updateMarkerImage(isSelected: input.isSelected)
        }
    }
}
