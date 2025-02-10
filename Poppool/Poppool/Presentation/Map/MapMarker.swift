import UIKit
import SnapKit
import GoogleMaps

final class MapMarker: UIView {
    // MARK: - Components

    private(set) var isSelected: Bool = false

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

    /// 개별 마커에서 같은 위치에 여러 스토어가 있을 경우 우측 상단에 표시될 배지 뷰
    private let countBadgeView: UIView = {
       let view = UIView()
       view.backgroundColor = .white
       view.layer.cornerRadius = 10
       view.layer.borderColor = UIColor.blu500.cgColor  // 보더 컬러 변경
       view.layer.borderWidth = 2
       view.layer.masksToBounds = true
       view.isHidden = true
       return view
    }()


    /// 배지 내부에 표시될 숫자 레이블
    private let badgeCountLabel: UILabel = {
       let label = UILabel()
       label.font = .systemFont(ofSize: 11, weight: .bold)  // 폰트 사이즈와 weight 변경
       label.textColor = .blu500   // 텍스트 컬러 변경
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
        // 기본 프레임 설정 (필요에 따라 변경)
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
        // 기본 서브뷰 추가
        addSubview(markerImageView)
        addSubview(clusterContainer)
        addSubview(countBadgeView)  // 배지 뷰 추가

        // 클러스터용 스택뷰 설정
        clusterContainer.addSubview(labelStackView)
        labelStackView.addArrangedSubview(regionLabel)
        labelStackView.addArrangedSubview(countLabel)

        // self 크기 설정 (전체 마커 뷰)
        self.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(70)
        }

        // 마커 이미지 제약조건 (하단 중앙)
        markerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()       // 뷰의 bottom이 마커 이미지의 기준
            make.width.height.equalTo(32)         // 기본 이미지 크기
        }

        // 클러스터 컨테이너 제약조건 (중앙)
        clusterContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(80)
        }

        // 스택뷰 제약조건 (클러스터 컨테이너 내부)
        labelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        }

        // 배지 뷰 제약조건 (마커 이미지의 우측 상단에 배치)
        countBadgeView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalTo(markerImageView.snp.top).offset(-4)  // 상단으로 살짝 띄움
            make.right.equalTo(markerImageView.snp.right).offset(4)  // 우측으로 살짝 띄움
        }


        // 배지 내부의 레이블은 배지 뷰를 꽉 채우도록 설정
        countBadgeView.addSubview(badgeCountLabel)
        badgeCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 초기 상태: 클러스터 컨테이너와 배지 모두 숨김
        clusterContainer.isHidden = true
        countBadgeView.isHidden = true
    }

    func updateMarkerImage(isSelected: Bool) {
        self.isSelected = isSelected  // 새로 추가
        let imageName = isSelected ? "TapMarker" : "Marker"
        let size = isSelected ? 44 : 32
        markerImageView.image = UIImage(named: imageName)

        markerImageView.snp.updateConstraints { make in
            make.width.height.equalTo(size)
        }

        updateBadgePosition(isSelected: isSelected)  // 새로운 메서드 호출

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateBadgePosition(isSelected: Bool) {
        countBadgeView.snp.updateConstraints { make in
            make.width.height.equalTo(20)
            if isSelected {
                make.top.equalTo(markerImageView.snp.top)
                make.right.equalTo(markerImageView.snp.right)
            } else {
                make.top.equalTo(markerImageView.snp.top).offset(-4)
                make.right.equalTo(markerImageView.snp.right).offset(4)
            }
        }
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
            // 클러스터 마커 처리 (시/구 레벨)
            markerImageView.isHidden = true
            clusterContainer.isHidden = false
            regionLabel.text = input.regionName
            regionLabel.textColor = .w100  // 사용자 정의 색상 (예: 흰색 계열)
            countLabel.text = "\(input.count)"
            // 클러스터 마커에서는 개별 배지 사용하지 않음
            countBadgeView.isHidden = true

            // 만약 regionLabel의 텍스트가 변경되었다면 스택뷰의 컨텐츠 사이즈에 따라 clusterContainer 너비 업데이트
            if let previousText = regionLabel.text, previousText == input.regionName {
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

            // 개별 마커에서 같은 위치에 여러 스토어가 있을 경우 (count > 1)
            if input.count > 1 {
                countBadgeView.isHidden = false
                badgeCountLabel.text = "\(input.count)"
            } else {
                countBadgeView.isHidden = true
            }
        }
    }
}
extension MapMarker {
    var imageView: UIImageView {
        return markerImageView
    }
}
