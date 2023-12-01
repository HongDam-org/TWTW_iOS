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
    }
}
