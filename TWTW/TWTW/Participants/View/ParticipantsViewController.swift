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
    
    // 더미 데이터 생성
    let participants: [Participant] =
    [
        Participant(participantsimage: UIImage(systemName: "person"),
                    name: "박다미",
                    callImage: UIImage(systemName: "phone"), locationImage: UIImage(systemName: "map")),
        Participant(participantsimage: UIImage(systemName: "person"),
                    name: "박다미", callImage: UIImage(systemName: "phone"),
                    locationImage: UIImage(systemName: "map")),
        Participant(participantsimage: UIImage(systemName: "person"),
                    name: "박다미", callImage: UIImage(systemName: "phone"),
                    locationImage: UIImage(systemName: "map")),
        Participant(participantsimage: UIImage(systemName: "person"),
                    name: "박다미", callImage: UIImage(systemName: "phone"),
                    locationImage: UIImage(systemName: "map"))
    ]
    private let disposeBag = DisposeBag()
    private var viewModel: PartiLocationViewModel
    private let addButtonTappedSubject = PublishSubject<Void>()
    
    private lazy var partiTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - Init
    init(viewModel: PartiLocationViewModel) {
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
        setupTableView()
        bindTableView()
        setupNavigationItem()
    }
    
    private func setupTableView() {
        view.addSubview(partiTableView)
        partiTableView.register(ParticipantsTableViewCell.self, forCellReuseIdentifier: CellIdentifier.participantsTableViewCell.rawValue)
        partiTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindTableView() {
        // 데이터 바인딩
        Observable.just(participants)
            .bind(to: partiTableView.rx.items(
                cellIdentifier: CellIdentifier.participantsTableViewCell.rawValue,
                cellType: ParticipantsTableViewCell.self)) { (row, participant, cell) in
                    cell.configure(participant: participant)
                    
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
        // 셀 선택
        if let getViewModel = viewModel as? ParticipantsGetViewModel {
            let selectedPlace = partiTableView.rx.modelSelected(Participant.self).asObservable()
            
            let input = ParticipantsGetViewModel.Input(selectedPlace: selectedPlace)
            getViewModel.bind(input: input)
        }
        if let setViewModel = viewModel as? ParticipantsSetViewModel {
            let selectedPlace = partiTableView.rx.modelSelected(Participant.self).asObservable()
            let input = ParticipantsSetViewModel.Input(selectedPlace: selectedPlace, addButtonTapped: addButtonTappedSubject.asObservable())
            setViewModel.bind(input: input)
        }
    }
    
    private func setupNavigationItem() {
        
        if viewModel is ParticipantsGetViewModel {
            navigationItem.rightBarButtonItem = nil
        } else if viewModel is ParticipantsSetViewModel {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
            navigationItem.rightBarButtonItem = addButton
            addButton.rx.tap
                .bind(to: addButtonTappedSubject)
                .disposed(by: disposeBag)
        }
    }
}
