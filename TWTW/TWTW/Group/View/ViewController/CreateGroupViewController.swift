//
//  CreateGroupViewController.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class CreateGroupViewController: UIViewController {
    
    /// 그룹 이미지 선택하는 버튼
    private lazy var groupImageButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "profile"), for: .normal)
        return btn
    }()
    
    /// 그룹 이름 입력
    private lazy var groupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "그룹 이름 입력"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    /// 그룹 이름 입력
    private lazy var groupTitleTextField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(string: "홍담진",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.textAlignment = .left
        field.backgroundColor = UIColor.profileTextFieldColor
        field.layer.cornerRadius = 10
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.profileTextFieldColor?.cgColor
        field.textColor = .black
        
        let leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: 10, height: field.frame.height))
        field.leftView = leftView
        field.leftViewMode = .always
        return field
    }()
    
    /// 친구 추가 버튼
    private lazy var addFriendButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("친구 추가", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    /// 친구 목록 제목
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "초대할 친구"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    /// 친구 목록 tableView
    private lazy var friendListTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.register(FriendListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.friendListTableViewCell.rawValue)
        return view
    }()
    
    /// 생성하기 버튼
    private lazy var createGroupButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("생성하기", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private var viewModel: CreateGroupViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: CreateGroupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "그룹 만들기"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        addSubViews()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        groupTitleTextField.endEditing(true)
    }
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(groupImageButton)
        view.addSubview(groupTitleLabel)
        view.addSubview(groupTitleTextField)
        view.addSubview(headerTitleLabel)
        view.addSubview(friendListTableView)
        view.addSubview(addFriendButton)
        view.addSubview(createGroupButton)
        
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        groupImageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
        }
        
        groupTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(groupImageButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
        }
        
        groupTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(groupTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(groupTitleLabel.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(40)
        }
        
        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(groupTitleTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        addFriendButton.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.top)
            make.trailing.equalTo(friendListTableView.snp.trailing)
        }
        
        friendListTableView.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(createGroupButton.snp.top).offset(-20)
        }
        
        createGroupButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
    }
    
    /// Bind
    func bind() {
        let input = CreateGroupViewModel.Input(clickedAddFriendEvents: addFriendButton.rx.tap,
                                               groupTitleEvents: groupTitleTextField.rx.text.orEmpty
                                                                    .distinctUntilChanged()
                                                                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance),
                                               clickedCreateButtonEvents: createGroupButton.rx.tap)
        let output = viewModel.createOutput(input: input)
        
        bindFriendListTableView(output: output)
        bindFailures(output: output)
    }
    
    /// Binding FriendListTableView
    /// - Parameter output: Output
    private func bindFriendListTableView(output: CreateGroupViewModel.Output) {
        output.selectedFriendListRelay
            .bind(to: friendListTableView.rx
                .items(cellIdentifier: CellIdentifier.friendListTableViewCell.rawValue,
                       cellType: FriendListTableViewCell.self)) { _, element, cell in
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                cell.inputData(info: element)
            }
            .disposed(by: disposeBag)
        
    }
    
    /// When Failures
    /// - Parameter output: Output
    private func bindFailures(output: CreateGroupViewModel.Output) {
        output.failCreateGroupSubject
            .bind { [weak self] check in
                guard let self = self else { return }
                if check {
                    showToast(view, message: "모임 생성에 실패하였습니다.")
                }
            }
            .disposed(by: disposeBag)
        
        output.errorTextFieldSubject
            .bind { [weak self] check in
                guard let self = self else { return }
                if check {
                    showToast(view, message: "그룹이름을 입력해 주세요")
                }
            }
            .disposed(by: disposeBag)
        
        output.failInviteGroupMemberSubject
            .bind { [weak self] check in
                guard let self = self else { return }
                if check {
                    showToast(view, message: "친구 초대에 실패하였습니다.")
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// show Toast Message
    /// - Parameters:
    ///   - view: 보여줄 View
    ///   - message: 보여줄 Message
    ///   - duration: 보여줄 시간
    private func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.lightGray
        toastLabel.layer.cornerRadius = 10
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = NSTextAlignment.center
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        },
                       completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
