//
//  FriendListView.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FriendListView: UIView {
    /// 친구 목록 제목
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    /// 친구 목록 tableView
    private lazy var friendListTableView: UITableView = {
        let view = UITableView()
        view.isScrollEnabled = false
        view.register(FriendListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendListTableViewCell.rawValue)
        return view
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: FriendListViewModel?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Add UI
    private func addSubViews() {
        addSubview(headerTitleLabel)
        addSubview(friendListTableView)
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        friendListTableView.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// binding
    private func bind() {
        let input = FriendListViewModel.Input()
        
        guard let output = viewModel?.createOutput(input: input) else { return }
        
        bindFriendListTableView(output: output)
    }

    /// binding FriendListTableView
    private func bindFriendListTableView(output: FriendListViewModel.Output) {
        output.friendListRelay
            .bind(to: friendListTableView.rx
                .items(cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                       cellType: FriendListTableViewCell.self)) { _, element, cell in
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                cell.inputData(info: element)
            }
            .disposed(by: disposeBag)
        
    }
    
}
