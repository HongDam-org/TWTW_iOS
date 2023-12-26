//
//  ParticipantsViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/30.
//

import RxCocoa
import RxSwift
import UIKit

final class ParticipantsViewController: UIViewController {
    
    /// plus
    private lazy var plusRightButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        return btn
    }()
    
    private lazy var partiTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Init
    init(viewModel: ParticipantsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    private var viewModel: ParticipantsViewModel
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "친구목록"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusRightButton)
        
        setupTableView()
        bind()
    }
    
    /// binding
    private func bind() {
        let input = ParticipantsViewModel.Input(changeLocationButtonTapped: partiTableView.rx.itemSelected,
                                                plusButtonEvents: plusRightButton.rx.tap)
        
        let output = viewModel.bind(input: input)
        
        bindTableView(output: output)
    }
    
    private func setupTableView() {
        view.addSubview(partiTableView)
        partiTableView.register(ParticipantsTableViewCell.self, forCellReuseIdentifier: CellIdentifier.participantsTableViewCell.rawValue)
        partiTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindTableView(output: ParticipantsViewModel.Output) {
        // 데이터 바인딩
        output.participantsRelay
            .bind(to: partiTableView.rx.items(
                cellIdentifier: CellIdentifier.participantsTableViewCell.rawValue,
                cellType: ParticipantsTableViewCell.self)) { (_, participant, cell) in
                    cell.configure(participant: participant)
                    cell.backgroundColor = .clear
                    cell.selectionStyle = .none
                    /// 전화 버튼 탭 이벤트 구독
                    cell.callBtnTapObservable
                        .subscribe(onNext: {
                            print("전화")
                        })
                        .disposed(by: cell.disposeBag)
                    
                    /// 위치 버튼 탭 이벤트 구독
                    cell.locationBtnTapObservable
                        .subscribe(onNext: {
                            print("위치")
                        })
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: disposeBag)
        
    }
}
