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

/// MainMapCustomTabButtonsView
final class MainMapCustomTabButtonsView: UIView {
    
    /// stackView - participantsBtn, planBtn
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 3
        stackView.distribution = .fillEqually
        return stackView
    }()
    /// participantsButton
    private lazy var participantsButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.setTitle("친구목록", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    /// notificationButton
    private lazy var notificationButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .white
        btn.setTitle("약속", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    private let viewModel: MainMapCustomTabButtonViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(frame: CGRect, viewModel: MainMapCustomTabButtonViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        addSubviews()
        bindViewModel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// addSubviews
    private func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(participantsButton)
        stackView.addArrangedSubview(notificationButton)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// bindViewModel
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        let input = MainMapCustomTabButtonViewModel.Input(
            participantsButtonTapped: participantsButton.rx.tap.asObservable(),
            notificationsButtonTapped: notificationButton.rx.tap.asObservable()
        )
        viewModel.bind(input: input)
    }
}
