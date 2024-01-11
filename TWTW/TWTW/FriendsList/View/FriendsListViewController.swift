//
//  FriendsListViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

/// 친구목록
final class FriendsListViewController: UIViewController {
    
    /// 친구 검색 버튼
    private lazy var rightItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    
    /// 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "친구 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        return searchBar
    }()
    
    /// 검색된 친구 테이블
    private lazy var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendListTableViewCell.rawValue)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: FriendsListViewModel
    
    // MARK: - Init
    init(viewModel: FriendsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
        bind()
        addSubviews()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        searchBar.endEditing(true)
    }
    
    // MARK: - Set Up
    /// Add  UI - SearchBar
    private func addSubviews() {
        navigationItem.title = "친구 목록"
        view.addSubview(searchBar)
        view.addSubview(friendsTableView)
        navigationItem.rightBarButtonItem = rightItemButton
        configureConstraints()
    }
    
    private func configureConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(searchBar.snp.width).multipliedBy(0.2)
        }
        friendsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview().inset(5)
        }
    }
    
    /// binding
    private func bind() {
        let input = FriendsListViewModel.Input(searchBarEvents: searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(300),
                      scheduler: MainScheduler.instance)
                .distinctUntilChanged(),
                                               selectedFriendsEvents: friendsTableView.rx.itemSelected,
                                               clickedAddButtonEvents: rightItemButton.rx.tap
        )
        
        let output = viewModel.createOutput(input: input)
        bindTableView(output: output)
        hideKeyboard()
    }
    
    /// bind tableView
    private func bindTableView(output: FriendsListViewModel.Output) {
        output.filteringFriendListRelay
            .bind(to: friendsTableView.rx
                .items(cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                       cellType: FriendListTableViewCell.self)) { _, element, cell in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.accessoryType = .none
                cell.inputData(info: element)
                if output.selectedFriendRelay.value.contains(element) {
                    cell.accessoryType = .checkmark
                }
            }
                       .disposed(by: disposeBag)
    }
    /// keyboard 내림
    private func hideKeyboard() {
        friendsTableView.rx.didScroll
            .bind { [weak self] _ in
                guard let self = self else { return }
                searchBar.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}
