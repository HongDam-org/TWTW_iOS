//
//  PlanViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import RxCocoa
import RxSwift
import UIKit

final class PlanViewController: UIViewController {
    ///더미
    let plans: [Plan] = [
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목"),
        Plan(planTitle: "제목", plansubTitle: "부제목")
    ]
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
    private func setupTableView() {
        view.addSubview(planTableView)
        planTableView.register(PlanTableViewCell.self, forCellReuseIdentifier: CellIdentifier.planTableViewCell.rawValue)
        planTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func bindTableView() {
        Observable.just(plans)
            .bind(to: planTableView.rx.items(
                cellIdentifier: CellIdentifier.planTableViewCell.rawValue,
                cellType: PlanTableViewCell.self)){
                    (row, plan, cell) in
                    cell.configure(plan: plan)
                }
    }
}
