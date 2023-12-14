//
//  SearchPlaceBottomSheet.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/11.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class SearchPlaceBottomSheet: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        titleLabel.text = "목적지명"
        descriptionLabel.text = "목적지 주소"
        actionButton.setTitle("목적지 변경", for: .normal)
        actionButton.backgroundColor = .blue
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(actionButton)
        
        // SnapKit을 사용한 레이아웃 설정
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
    }
    
    private func setupBindings() {
        actionButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                showAlert()
            }
            .disposed(by: disposeBag)
    }
    func setupPlace(name: String, address: String) {
        titleLabel.text = name
        descriptionLabel.text = address
    }
    private func showAlert() {
        let alert = UIAlertController(title: "목적지 변경", message: "목적지를 변경할 약속을 선택해주세요", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let selectAppointmentAction = UIAlertAction(title: "약속 선택하기", style: .default) { [weak self] _ in
            // 약속 선택 로직 구현
            self?.actionButton.setTitle("목적지 변경", for: .normal)
        }

        alert.addAction(cancelAction)
        alert.addAction(selectAppointmentAction)

        if let viewController = self.findViewController() {
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    private func findViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while nextResponder != nil {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
