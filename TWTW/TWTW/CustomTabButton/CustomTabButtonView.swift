//
//  CustomTabButtonView.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/28.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class CustomTabButtonView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 3
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var participantsButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.setTitle("친구목록", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    private lazy var notificationButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .white
        btn.setTitle("약속", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    private let viewModel: CustomTabButtonViewModel?
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect, viewModel: CustomTabButtonViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        addSubviews()
        bindViewModel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(participantsButton)
        stackView.addArrangedSubview(notificationButton)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        let input = CustomTabButtonViewModel.Input(
            participantsButtonTapped: participantsButton.rx.tap.asObservable(),
            notificationsButtonTapped: notificationButton.rx.tap.asObservable()
        )
        viewModel.bind(input: input)
    }
}
