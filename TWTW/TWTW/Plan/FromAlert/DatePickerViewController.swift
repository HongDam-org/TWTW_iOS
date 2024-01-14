//
//  DatePickerViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/20.
//

import RxCocoa
import RxSwift
import UIKit

final class DatePickerViewController: UIViewController {
    private let datePicker = UIDatePicker()
    let selectedDate = PublishSubject<Date?>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindActions()
    }

    // 데이트피커 setup
    private func setupViews() {
        view.backgroundColor = .white
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.minimumDate = Date()
        view.addSubview(datePicker)

        datePicker.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    // 피커 모달창 action
    private func bindActions() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("선택", for: .normal)
        view.addSubview(selectButton)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        view.addSubview(cancelButton)

        selectButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(10)
            make.centerX.equalToSuperview().offset(-50)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(10)
            make.centerX.equalToSuperview().offset(50)
        }

        selectButton.rx.tap
            .bind { [weak self] in
                self?.selectedDate.onNext(self?.datePicker.date)
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind { [weak self] in
                self?.selectedDate.onNext(nil)
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
