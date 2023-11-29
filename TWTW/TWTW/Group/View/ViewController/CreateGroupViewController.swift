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
    
    /// 스크롤 뷰
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// contentview
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var viewModel: CreateGroupViewModel
    private let friendListView: FriendListView
    
    // MARK: - Init
    init(viewModel: CreateGroupViewModel, friendListview: FriendListView) {
        self.viewModel = viewModel
        self.friendListView = friendListview
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
        let title = NSAttributedString(string: "그룹 만들기", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        navigationItem.title = title.string
        addSubViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        groupTitleTextField.endEditing(true)
    }
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(groupImageButton)
        contentView.addSubview(groupTitleLabel)
        contentView.addSubview(groupTitleTextField)
        contentView.addSubview(friendListView)
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.bottom.equalTo(scrollView.snp.bottom)
            make.width.equalTo(scrollView.snp.width)
        }
        
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
        
        friendListView.snp.makeConstraints { make in
            make.top.equalTo(groupTitleTextField.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
