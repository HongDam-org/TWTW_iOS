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
    let plans: [Plan] = [
        Plan(
            planId: "3b8e94bc-310a-4ee9-b5cc-624d3c794dd4",
            placeId: "91e3045e-f75b-42a5-a5f5-2d63db7e2df8",
            planMakerId: "065c66a2-7d21-47f0-bbfd-4751242d0a78",
            placeDetails: PlaceDetails(
                placeName: "서울 여의도공원",
                placeUrl: "https://example.com/place/1",
                roadAddressName: "여의도로 123",
                longitude: 35.5259,
                latitude: 129.9242
            ),
            groupInfo: GroupInfo(
                groupId: "aa977768-a940-4f89-ba24-aa1bf2f71355",
                leaderId: "8df2b9ac-b424-44ca-9f30-25b245dc75f1",
                name: "친구와 나들이1", groupImage: "aaaaa"
            ),
            members: [
                Friend(
                    memberId: "37f64bef-b266-4787-8b53-599b2e0cea3c",
                    nickname: "친구1",
                    participantsImage: ""
                ),
                Friend(
                    memberId: "2f6f96bf-4e17-41d7-8e17-15e17d41d7b0",
                    nickname: "친구2",
                    participantsImage: ""
                )
            ]
        ),
        Plan(
            planId: "3b8e94bc-310a-4ee9-b5cc-624d3c794dd4",
            placeId: "91e3045e-f75b-42a5-a5f5-2d63db7e2df8",
            planMakerId: "065c66a2-7d21-47f0-bbfd-4751242d0a78",
            placeDetails: PlaceDetails(
                placeName: "서울 여의도공원2",
                placeUrl: "https://example.com/place/1",
                roadAddressName: "여의도로 1233",
                longitude: 37.5259,
                latitude: 126.9242
            ),
            groupInfo: GroupInfo(
                groupId: "aa977768-a940-4f89-ba24-aa1bf2f71355",
                leaderId: "8df2b9ac-b424-44ca-9f30-25b245dc75f1",
                name: "친구와 나들이2", groupImage: "aaaaa"
            ),
            members: [
                Friend(
                    memberId: "37f64bef-b266-4787-8b53-599b2e0cea3c",
                    nickname: "친구1",
                    participantsImage: ""
                ),
                Friend(
                    memberId: "2f6f96bf-4e17-41d7-8e17-15e17d41d7b0",
                    nickname: "친구2",
                    participantsImage: ""
                )
            ]
        ),
        Plan(
            planId: "4b8e94bc-310a-4ee9-b5cc-624d3c794dd4",
            placeId: "31e3045e-f75b-42a5-a5f5-2d63db7e2df8",
            planMakerId: "165c66a2-7d21-47f0-bbfd-4751242d0a78",
            placeDetails: PlaceDetails(
                placeName: "인천 투썸",
                placeUrl: "https://example.com/place/2",
                roadAddressName: "여의도로 1234",
                longitude: 38.5259,
                latitude: 127.0242
            ),
            groupInfo: GroupInfo(
                groupId: "ba977768-a940-4f89-ba24-aa1bf2f71355",
                leaderId: "9df2b9ac-b424-44ca-9f30-25b245dc75f1",
                name: "그룹이름임", groupImage: "aaaaa"
            ),
            members: [
                Friend(
                    memberId: "47f64bef-b266-4787-8b53-599b2e0cea3c",
                    nickname: "친구11",
                    participantsImage: ""
                ),
                Friend(
                    memberId: "3f6f96bf-4e17-41d7-8e17-15e17d41d7b0",
                    nickname: "친구12",
                    participantsImage: ""
                )
            ]
        )
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
