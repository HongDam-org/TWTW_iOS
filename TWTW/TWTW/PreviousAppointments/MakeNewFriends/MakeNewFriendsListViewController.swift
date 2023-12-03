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
    
    // 더미 데이터 생성
    let friendsd: [Friend] =
    [ Friend(memberId: "1234", nickname: "박다미"),
      Friend(memberId: "1234", nickname: "박다미"),
      Friend(memberId: "1234", nickname: "박다미"),
      Friend(memberId: "1234", nickname: "박유미")
    ]
    /// 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "친구 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    /// 검색된 지역테이블
    private lazy var friendsTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let disposeBag = DisposeBag()
    var viewModel: FriendsListViewModel?
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupTableView()
        bindTableView()
    }
    
    // MARK: - Set Up
    /// Add  UI - SearchBar
    private func addSubviews() {
        navigationItem.title = "친구찾기"
        view.addSubview(searchBar)
        view.addSubview(friendsTableView)
        setNavi()
        configureConstraints()
        
    }
    private func setNavi() {
        navigationItem.rightBarButtonItem = addButton
        makeNewFriendsTapped()
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
    private func bindTableView() {
        // 데이터 바인딩
        Observable.just(friendsd)
            .bind(to: friendsTableView.rx.items(
                cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                cellType: FriendListTableViewCell.self)) { (row, friend, cell) in
                    cell.inputData(info: friend)
                }
                .disposed(by: disposeBag)
    }
    private func makeNewFriendsTapped() {
        addButton.rx.tap
               .subscribe(onNext: { [weak self] in
                   self?.showFindNewFriendsListVC()
               })
               .disposed(by: disposeBag)
    }
    private func showFindNewFriendsListVC() {
        let newFriendsVC = MakeNewFriendsListViewController() // FindNewFriendsListVC 인스턴스 생성
        navigationController?.pushViewController(newFriendsVC, animated: true)
    }

}
