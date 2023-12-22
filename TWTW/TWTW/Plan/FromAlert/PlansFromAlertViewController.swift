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
    private var currentViewType: SettingPlanCaller = .forNew

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
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.text = "약속 명"
        return label
    }()
    private lazy var meetingNameEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    // place이전 이후
    private lazy var placeNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        return stackView
    }()
    private lazy var originalPlaceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "이전 목적지 명"
        return label
    }()
    private lazy var placeChangeImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "arrowshape.right"))
        image.tintColor = .black
        return image
    }()
    
    private lazy var newPlaceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = "선택한 목적지명"
        
        return label
    }()
    
    private lazy var addParticipantsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.2.circle"), for: .normal)
        button.setTitle("참여 인원", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var confirmUIView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        
        return uiView
    }()
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("날짜설정", for: .normal)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private lazy var selectedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜를 선택해주세요"
        
        return label
    }()
    private lazy var selectedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간을 선택해주세요"
        
        return label
    }()
    
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
        bind()
        bindTableView()
    }

    private func addSubeViews() {
        view.addSubview(scrollView)
        view.addSubview(confirmUIView)
        confirmUIView.addSubview(confirmButton)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(originalMeetingNameLabel)
        contentView.addSubview(meetingNameEditButton)
        
        contentView.addSubview(placeNameStackView)
        placeNameStackView.addArrangedSubview(originalPlaceNameLabel)
        placeNameStackView.addArrangedSubview(placeChangeImage)
        placeNameStackView.addArrangedSubview(newPlaceNameLabel)
        // 원래 위치 레이블

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
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(confirmUIView.snp.top).offset(10)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        // 약속명
        originalMeetingNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        meetingNameEditButton.snp.makeConstraints { make in
            make.centerY.equalTo(originalMeetingNameLabel)
            make.leading.equalTo(originalMeetingNameLabel.snp.trailing).offset(5)
        }
        // 목적지
        placeNameStackView.snp.makeConstraints { make in
            make.top.equalTo(originalMeetingNameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        // 달력버튼
        datePickerButton.snp.makeConstraints { make in
            make.top.equalTo(placeNameStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        // 날짜 라벨
        selectedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        // 시간 라벨
        selectedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedDateLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        // 참여 인원 추가 버튼
        addParticipantsButton.snp.makeConstraints { make in
            make.top.equalTo(selectedTimeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        selectedFriendsTableView.snp.makeConstraints { make in
            make.top.equalTo(addParticipantsButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(0)
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
        let input = PlansFromAlertViewModel.Input(
            clickedAddParticipantsEvents: addParticipantsButton.rx.tap,
            clickedConfirmEvents: confirmButton.rx.tap)
        
        let output = viewModel.createOutput(input: input)
        
        output.newPlaceName
                    .bind(to: newPlaceNameLabel.rx.text)
                    .disposed(by: disposeBag)

        updateViewState(from: output.callerState)
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
        
        // alert 창 터치 이벤트 vc에서 진행함.
        
        datePickerButton.rx.tap
            .bind { [weak self] in
                self?.presentDatePicker()
            }
            .disposed(by: disposeBag)
        
        
        meetingNameEditButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showEditAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateTableViewHeight(_ count: Int) {
        let rowHeight = selectedFriendsTableView.rowHeight
        let totalHeight = rowHeight * CGFloat(count)
        selectedFriendsTableView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        view.layoutIfNeeded()
    }
    private func updateViewState(from newViewState: SettingPlanCaller) {
        currentViewType = newViewState
        switch currentViewType {
        case .forNew:
            originalPlaceNameLabel.removeFromSuperview()
            placeChangeImage.removeFromSuperview()
            originalPlaceNameLabel.isHidden = true
            placeChangeImage.isHidden = true

        case .forRevice:
            originalPlaceNameLabel.isHidden = false
            placeChangeImage.isHidden = false
            
        }
    }
    
    private func showEditAlert() {
        let alertController = UIAlertController(title: "약속 명 변경", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "새 약속 명을 입력하세요"
        }
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self, unowned alertController] _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                self?.originalMeetingNameLabel.text = newName
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func presentDatePicker() {
        datePickerViewController.modalPresentationStyle = .formSheet
        datePickerViewController.modalTransitionStyle = .coverVertical
        
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
