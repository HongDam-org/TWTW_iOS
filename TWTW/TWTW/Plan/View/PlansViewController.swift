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
    
    /// 친구 검색 버튼
    private lazy var rightItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    
    /// sample
    let plans: [Plan] = [
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목")
    ]
    
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
        setupCallerBinding()
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
        bindTableView()
        bind()
    }
    
    // MARK: Function
    /// setupTableView - table addSubView, register
    private func setupCallerBinding() {
        viewModel.callerObservable
            .bind { [weak self] caller in
                guard let self = self else { return }
                if caller == .fromTabBar {
                    self.navigationItem.rightBarButtonItem = nil
                } else if caller == .fromAlert {
                    self.navigationItem.rightBarButtonItem = self.rightItemButton
                }
            }
            .disposed(by: disposeBag)
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
            selectedPlansList: planTableView.rx.itemSelected.asObservable())
        let output = viewModel.bind(input: input)
        // bindTableView()
    }
    
    /// bindTableView - touchEvent with rx
    private func bindTableView() {
        Observable.just(plans)
            .bind(to: planTableView.rx.items(
                cellIdentifier: CellIdentifier.planTableViewCell.rawValue,
                cellType: PlanTableViewCell.self)) {
                    (row, plan, cell) in
                    cell.configure(plan: plan)
                }
        
    }
    
}
