//
//  FriendSearchViewController.swift
//  TWTW
//
//  Created by 정호진 on 12/1/23.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

final class FriendSearchViewController: UIViewController {
    
    /// 초대하기 버튼, 내비게이션 바 오른쪽 버튼
    private lazy var rightItemButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        btn.setTitle("초대하기", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .yellow
        return btn
    }()
    
    /// 친구 검색 버튼
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Searching Friends"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    /// 검색된 친구 목록
    private lazy var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let viewModel: FriendSearchViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: FriendSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "친구 찾기"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemButton)
        
        addSubViews()
        bind()
    }
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(searchBar)
        view.addSubview(friendsTableView)
        
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        friendsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    /// binding
    private func bind() {
        let input = FriendSearchViewModel.Input(searchBarEvents: searchBar.rx.text,
                                                selectedFriendsEvents: friendsTableView.rx.itemSelected)
        
        let output = viewModel.createOutput(input: input)
        bindTableView(output: output)
    }
    
    /// bind tableView
    private func bindTableView(output: FriendSearchViewModel.Output) {
        output.friendListRelay
            .bind(to: friendsTableView.rx
                .items(cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                       cellType: FriendListTableViewCell.self)) { _, element, cell in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                if output.selectedFriendsRelay.value.contains(element) {
                   return cell.selectedFriendInputData(info: element, selected: true)
                }
                return cell.selectedFriendInputData(info: element, selected: false)
            }
            .disposed(by: disposeBag)
        
    }
}
