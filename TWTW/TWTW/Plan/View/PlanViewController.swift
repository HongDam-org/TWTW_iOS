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
final class PlanViewController: UIViewController {
    
    /// sample
    let plans: [Plan] = [
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
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        setupTableView()
        bindTableView()
    }
    
    // MARK: Function
    /// setupTableView - table addSubView, register
    private func setupTableView() {
        view.addSubview(planTableView)
        planTableView.register(PlanTableViewCell.self, forCellReuseIdentifier: CellIdentifier.planTableViewCell.rawValue)
        constraintsTableView()
        
    }
    /// constraintsTableView
    private func constraintsTableView() {
        planTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
