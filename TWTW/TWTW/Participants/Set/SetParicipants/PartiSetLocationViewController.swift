//
//  PartiSetLocationViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class PartiSetLocationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: PartiSetLocationViewModel
    
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
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("변경", for: .normal)
        
        return button
    }()
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        return button
    }()
    
    private lazy var selectedDateLabel: UILabel = UILabel()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    // MARK: - Init
    init(viewModel: PartiSetLocationViewModel) {
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
    }
    
    private func addSubeViews() {
        // 원래 위치 레이블
        view.addSubview(originalPlaceNameLabel)
        // 새 위치 레이블
        view.addSubview(newPlaceNameLabel)
        // 참여 인원 추가 버튼
        view.addSubview(addParticipantsButton)
        // 확인 버튼
        view.addSubview(confirmButton)
        // 날짜 선택 버튼
        view.addSubview(datePickerButton)
        // 선택된 날짜 레이블
        view.addSubview(selectedDateLabel)
        configureConstraints()
    }
    
    private func configureConstraints() {
        originalPlaceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
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
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(addParticipantsButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        datePickerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        selectedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    private func bind() {
        let input = PartiSetLocationViewModel.Input(clickedAddParticipantsEvents: addParticipantsButton.rx.tap)
        
        let output = viewModel.createOutput(input: input)
      
    }
    
    private func setupBindings() {
        addParticipantsButton.rx.tap
            .bind { [weak self] in
            
            }
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind { [weak self] in
                print("변경버튼 클릭")
            }
            .disposed(by: disposeBag)
        
        datePickerButton.rx.tap
            .bind { [weak self] in
                self?.presentDatePicker()
            }
            .disposed(by: disposeBag)
    }
    private func presentDatePicker() {
        let alertController = UIAlertController(title: "\n\n\n", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(alertController.view)
            make.width.equalTo(alertController.view)
        }
        let selectAction = UIAlertAction(title: "선택", style: .default) { [weak self] _ in
            self?.selectedDateLabel.text = self?.formattedDate(self?.datePicker.date)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    
    }
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
