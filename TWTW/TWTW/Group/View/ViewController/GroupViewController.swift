//
//  ViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

/// 그룹 ViewController
final class GroupViewController: UIViewController {
    /// 알림 버튼
    private lazy var alertBarButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        btn.setImage(UIImage(systemName: "bell", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal),
                     for: .normal)
        return btn
    }()
    
    /// 그룹 생성하는 버튼
    private lazy var createGroupBarButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        btn.setImage(UIImage(systemName: "person.3", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal),
                     for: .normal)
        return btn
    }()
    
    /// 그룹 목록 보여줄 tableView
    private lazy var groupListTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.register(GroupTableViewCell.self, forCellReuseIdentifier: CellIdentifier.groupTableViewCell.rawValue)
        return view
    }()
    
    var viewModel: GroupViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: GroupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        addSubViews()
        bind()
    }
    /// 네비게이션 바 설정
        private func setupNavigationBar() {
            let alertBarButtonItem = UIBarButtonItem(customView: alertBarButton)
            let createGroupBarButtonItem = UIBarButtonItem(customView: createGroupBarButton)

            navigationItem.rightBarButtonItems = [createGroupBarButtonItem, alertBarButtonItem]
        }
    /// Add UI
    private func addSubViews() {
        view.addSubview(groupListTableView)
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        groupListTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    /// bind
    private func bind() {
        let input = GroupViewModel.Input(clickedAlertEvenets: alertBarButton.rx.tap,
                                         clickedCreateGroupEvents: createGroupBarButton.rx.tap,
                                         clickedTableViewItemEvents: groupListTableView.rx.itemSelected)
        
        let output = viewModel.createOutput(input: input)
        bindTableView(output: output)
    }
    
    /// binding TableView
    private func bindTableView(output: GroupViewModel.Output) {
        output.groupListRelay.bind(to: groupListTableView.rx
            .items(cellIdentifier: CellIdentifier.groupTableViewCell.rawValue,
                   cellType: GroupTableViewCell.self)) { _, element, cell in
            cell.inputData(item: element)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
        }
        .disposed(by: disposeBag)
    }
}
