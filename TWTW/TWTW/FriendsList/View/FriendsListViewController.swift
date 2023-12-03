//
//  FriendsListViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import RxCocoa
import RxSwift
import UIKit

// 친구목록
final class FriendsListViewController: UIViewController {
    
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
    
    private let disposeBag = DisposeBag()
    var viewModel: FriendsListViewModel?
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
    }
    // MARK: - Set Up
    /// Add  UI - SearchBar
    private func addSubViews() {
        //navigationItem.titleView = searchBar
        view.addSubview(friendsTableView)
        friendsTableView.register(FriendsListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendsListTableViewCell.rawValue)
        configureConstraints()
    }
    
    private func configureConstraints() {
        friendsTableView.snp.makeConstraints { make in
            make.edges.equalTo(additionalSafeAreaInsets)
        }
    }
}
