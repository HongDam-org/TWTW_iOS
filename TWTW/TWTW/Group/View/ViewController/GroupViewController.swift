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
    
    /// 버튼들 담는 StackView
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [alertBarButton, createGroupBarButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 20
        return view
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
        
        addSubViews()
        bind()
    }
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(stackView)
        view.addSubview(groupListTableView)
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        groupListTableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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
    /// - Parameter output: Output
    private func bindTableView(output: GroupViewModel.Output) {
        output.groupListRelay
            .bind(to: groupListTableView.rx
                .items(cellIdentifier: CellIdentifier.groupTableViewCell.rawValue,
                       cellType: GroupTableViewCell.self)) { _, element, cell in
                cell.inputData(item: element)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        groupListTableView.rx.itemDeleted
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                groupListTableView.deleteRows(at: [indexPath], with: .automatic)
                // todo: 삭제 API 작성
            }
            .disposed(by: disposeBag)
    }
    
}
