//
//  PlanViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import RxCocoa
import RxSwift
import UIKit

///  PlanViewController - 일정
final class PlansViewController: UIViewController {
    private var currentViewType: PlanCaller = .fromTabBar
    
    /// 친구 검색 버튼
    private lazy var rightItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    
    /// sample 내가 속한 계획중 GroudID가 겹치는것만
    
    // MARK: Properties
    /// planTableView
    private lazy var planTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: PlansViewModel
    
    // MARK: - Init
    
    init(viewModel: PlansViewModel) {
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
        
        setupTableView()
        addSubviews()
        bind()
    }
    
    // MARK: Function
    
    private func updateViewState(from newViewState: PlanCaller) {
        currentViewType = newViewState
        switch currentViewType {
        case .fromTabBar:
            self.navigationItem.rightBarButtonItem = nil
            
        case .fromAlert:
            self.navigationItem.rightBarButtonItem = self.rightItemButton
        }
    }
    
    private func setupTableView() {
        view.addSubview(planTableView)
        planTableView.register(PlanTableViewCell.self, forCellReuseIdentifier: CellIdentifier.planTableViewCell.rawValue)
        
    }
    private func addSubviews() {
        constraintsTableView()
    }
    
    /// constraintsTableView
    private func constraintsTableView() {
        planTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// binding
    private func bind() {
        let input = PlansViewModel.Input(
            selectedPlansList: planTableView.rx.itemSelected.asObservable(),
            addPlans: rightItemButton.rx.tap.asObservable()
        )
        let output = viewModel.bind(input: input)
        updateViewState(from: output.callerState)
        bindTableView(output: output)
    }
    

        /// binding TableView
        /// - Parameter output: Output
        private func bindTableView(output: PlansViewModel.Output) {
            output.planListRelay
                .bind(to: planTableView.rx
                    .items(cellIdentifier: CellIdentifier.planTableViewCell.rawValue,
                           cellType: PlanTableViewCell.self)) { _, element, cell in
                    cell.inputData(plan: element)
                    cell.backgroundColor = .clear
                    cell.selectionStyle = .none
                }
                           .disposed(by: disposeBag)
            
        }
    
}
