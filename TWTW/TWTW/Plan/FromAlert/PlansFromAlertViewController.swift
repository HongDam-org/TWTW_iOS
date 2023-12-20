//
//  PlansFromAlertViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class PlansFromAlertViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: PlansFromAlertViewModel
    private let datePickerViewController = DatePickerViewController()

    private lazy var selectedFriendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendListTableViewCell.rawValue)
        tableView.rowHeight = 100
        tableView.isScrollEnabled = false
        return tableView
    }()
    private lazy var originalMeetingNameLabel: UILabel = {
        let label = UILabel()
        label.text = "약속 명 (수정가능)"
        return label
    }()
    
    private lazy var originalPlaceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "이전 목적지 명"
        return label
    }()
    
    private lazy var newPlaceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "선택한 목적지명"
        
        return label
    }()
    
    private lazy var addParticipantsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("참여 인원", for: .normal)
        
        return button
    }()
    private lazy var confirmUIView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        
        return uiView
    }()
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정완료", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        return button
    }()
    
    private lazy var selectedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "선택한 날짜"
        
        return label
    }()
    private lazy var selectedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "선택한 시간"
        
        return label
    }()
    
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    // MARK: - Init
    init(viewModel: PlansFromAlertViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubeViews()
        setupBindings()
        bind()
        bindTableView()
        
    }
    
    private func addSubeViews() {
        view.addSubview(scrollView)
        view.addSubview(confirmUIView)
        confirmUIView.addSubview(confirmButton)
        scrollView.addSubview(contentView)
        // 원래 위치 레이블
        contentView.addSubview(originalPlaceNameLabel)
        // 새 위치 레이블
        contentView.addSubview(newPlaceNameLabel)
        // 참여 인원 추가 버튼
        contentView.addSubview(addParticipantsButton)
        
        contentView.addSubview(selectedFriendsTableView)
        // 확인 버튼
        // 날짜 선택 버튼
        contentView.addSubview(datePickerButton)
        // 선택된 날짜 레이블
        contentView.addSubview(selectedDateLabel)
        contentView.addSubview(selectedTimeLabel)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        originalPlaceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        newPlaceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(originalPlaceNameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        addParticipantsButton.snp.makeConstraints { make in
            make.top.equalTo(newPlaceNameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        selectedFriendsTableView.snp.makeConstraints { make in
            make.top.equalTo(addParticipantsButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        datePickerButton.snp.makeConstraints { make in
            make.top.equalTo(selectedFriendsTableView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        selectedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        selectedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedDateLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        confirmUIView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(0.3)
        }
        confirmButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = PlansFromAlertViewModel.Input(clickedAddParticipantsEvents: addParticipantsButton.rx.tap,
                                                  clickedConfirmEvents: confirmButton.rx.tap)
        
        let output = viewModel.createOutput(input: input)
        
        viewModel.newPlaceName
            .bind(to: newPlaceNameLabel.rx.text)
            .disposed(by: disposeBag)
    }
    private func bindTableView() {
        viewModel.selectedFriendsObservable
            .do(onNext: { [weak self] friends in
                self?.updateTableViewHeight(friends.count)
            })
        
            .bind(to: selectedFriendsTableView.rx
                .items(cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                       cellType: FriendListTableViewCell.self)) { index, friend, cell in
                cell.inputData(info: friend)
            }.disposed(by: disposeBag)
    }
    
    private func updateTableViewHeight(_ count: Int) {
        let rowHeight = selectedFriendsTableView.rowHeight
        let totalHeight = rowHeight * CGFloat(count)
        selectedFriendsTableView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        view.layoutIfNeeded()
    }
    private func setupBindings() {
        datePickerButton.rx.tap
            .bind { [weak self] in
                self?.presentDatePicker()
            }
            .disposed(by: disposeBag)
    }
    private func presentDatePicker() {
        datePickerViewController.modalPresentationStyle = .formSheet
        datePickerViewController.modalTransitionStyle = .flipHorizontal
        
        datePickerViewController.selectedDate
            .subscribe(onNext: { [weak self] selectedDate in
                guard let selectedDate = selectedDate else { return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = dateFormatter.string(from: selectedDate)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let formattedTime = timeFormatter.string(from: selectedDate)
                
                self?.selectedDateLabel.text = formattedDate
                self?.selectedTimeLabel.text = formattedTime
            })
            .disposed(by: disposeBag)
        
        present(datePickerViewController, animated: true, completion: nil)
    }
}
