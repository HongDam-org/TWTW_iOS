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
    
    private lazy var partiTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 20
        setupTableView()
        bindTableView()
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

        /// 셀 선택 이벤트 처리
        partiTableView.rx.itemSelected
            .map { indexPath in
                self.participants[indexPath.row]
            }
            .subscribe(onNext: { [weak self] _ in
                let changeLocationVC = ChangeLocationViewController()
                self?.present(changeLocationVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

}
