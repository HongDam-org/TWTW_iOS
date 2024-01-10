//
//  NotificationViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit

// 알림
final class NotificationViewController: UIViewController {
    
    /// Custom 내비게이션 뷰
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 제목 라벨
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "알림"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 알림 목록 리스트
    private lazy var listTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.register(NotificationTableViewCell.self,
                      forCellReuseIdentifier: CellIdentifier.notificationTableViewCell.rawValue)
        return view
    }()
    
    private let viewModel: NotificationViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: NotificationViewModel) {
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
        
        addSubViews()
        bind()
        
        // 알림 제거
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(topView)
        view.addSubview(titleLabel)
        view.addSubview(listTableView)
        
        constraints()
    }
    
    /// Set Constraints
    private func constraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        topView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10).isActive = true
        
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    /// Bind
    private func bind() {
        let input = NotificationViewModel.Input(selectedCellEvents: listTableView.rx.itemSelected)
        
        let output = viewModel.createOutput(input: input)
        
        bindListTableView(output: output)
    }
    
    /// Bind tableView
    private func bindListTableView(output: NotificationViewModel.Output) {
        output.notificationListRelay
            .bind(to: listTableView.rx
                .items(cellIdentifier: CellIdentifier.notificationTableViewCell.rawValue,
                       cellType: NotificationTableViewCell.self)) { _, element, cell in
                cell.inputData(info: element)
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
            }
           .disposed(by: disposeBag)
        
    }
    
}
