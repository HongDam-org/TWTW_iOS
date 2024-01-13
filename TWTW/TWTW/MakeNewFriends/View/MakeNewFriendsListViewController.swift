//
//  MakeNewFriendsListViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import RxCocoa
import RxSwift
import UIKit

final class MakeNewFriendsListViewController: UIViewController {
    
    /// 초대하기 버튼, 내비게이션 바 오른쪽 버튼
    private lazy var rightItemButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("추가", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    /// 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "친구 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    /// 검색된 친구테이블
    private lazy var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    
    private let viewModel: MakeNewFriendsListViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: MakeNewFriendsListViewModel) {
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
        navigationItem.title = "새로운 친구찾기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemButton)
        addSubviews()
        setupTableView()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        searchBar.endEditing(true)
    }
    
    // MARK: - Set Up
    /// Add  UI - SearchBar
    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(friendsTableView)
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
    
    private func setupTableView() {
        friendsTableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendListTableViewCell.rawValue)
    }
    /// binding
    private func bind() {
        let input = MakeNewFriendsListViewModel.Input(searchBarEvents: searchBar.rx.text.orEmpty
                                                                    .debounce(RxTimeInterval.milliseconds(300),
                                                                              scheduler: MainScheduler.instance)
                                                                    .distinctUntilChanged(),
                                                selectedFriendsEvents: friendsTableView.rx.itemSelected,
                                                clickedAddButtonEvents: rightItemButton.rx.tap)
        
        let output = viewModel.createOutput(input: input)
        bindTableView(output: output)
        hideKeyboard()
    }
    
    /// bind tableView
    private func bindTableView(output: MakeNewFriendsListViewModel.Output) {
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
