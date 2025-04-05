import SnapKit
import UIKit

final class DateTimePickerManager {

    static let shared = DateTimePickerManager()

    private init() { }

    // MARK: - Date Range Picker (시작일/종료일)
    func showDateRange(
        on viewController: UIViewController,
        completion: @escaping (Date, Date) -> Void
    ) {
        // 1) 시작일
        let alert1 = UIAlertController(title: "시작일 선택", message: nil, preferredStyle: .actionSheet)
        let dp1 = UIDatePicker()
        dp1.datePickerMode = .date
        dp1.preferredDatePickerStyle = .wheels

        alert1.view.addSubview(dp1)
        dp1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(150)
        }

        alert1.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            let startDate = dp1.date
            // 2) 종료일
            self.showEndDatePicker(on: viewController, startDate: startDate, completion: completion)
        }))
        alert1.addAction(UIAlertAction(title: "취소", style: .cancel))

        alert1.view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        viewController.present(alert1, animated: true)
    }

    private func showEndDatePicker(
        on viewController: UIViewController,
        startDate: Date,
        completion: @escaping (Date, Date) -> Void
    ) {
        let alert2 = UIAlertController(title: "종료일 선택", message: nil, preferredStyle: .actionSheet)
        let dp2 = UIDatePicker()
        dp2.datePickerMode = .date
        dp2.preferredDatePickerStyle = .wheels
        dp2.minimumDate = startDate

        alert2.view.addSubview(dp2)
        dp2.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(150)
        }

        alert2.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            let endDate = dp2.date
            completion(startDate, endDate)
        }))
        alert2.addAction(UIAlertAction(title: "취소", style: .cancel))

        alert2.view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        viewController.present(alert2, animated: true)
    }

    // MARK: - Time Range Picker (시작시간/종료시간)
    func showTimeRange(
        on viewController: UIViewController,
        completion: @escaping (Date, Date) -> Void
    ) {
        // 시작시간
        let alert1 = UIAlertController(title: "시작시간 선택", message: nil, preferredStyle: .actionSheet)
        let dp1 = UIDatePicker()
        dp1.datePickerMode = .time
        dp1.preferredDatePickerStyle = .wheels

        alert1.view.addSubview(dp1)
        dp1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(150)
        }

        alert1.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            let startTime = dp1.date
            // 종료시간
            self.showEndTimePicker(on: viewController, startTime: startTime, completion: completion)
        }))
        alert1.addAction(UIAlertAction(title: "취소", style: .cancel))

        alert1.view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        viewController.present(alert1, animated: true)
    }

    private func showEndTimePicker(
        on viewController: UIViewController,
        startTime: Date,
        completion: @escaping (Date, Date) -> Void
    ) {
        let alert2 = UIAlertController(title: "종료시간 선택", message: nil, preferredStyle: .actionSheet)
        let dp2 = UIDatePicker()
        dp2.datePickerMode = .time
        dp2.preferredDatePickerStyle = .wheels

        alert2.view.addSubview(dp2)
        dp2.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(150)
        }

        alert2.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            let endTime = dp2.date
            completion(startTime, endTime)
        }))
        alert2.addAction(UIAlertAction(title: "취소", style: .cancel))

        alert2.view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }

        viewController.present(alert2, animated: true)
    }
}
