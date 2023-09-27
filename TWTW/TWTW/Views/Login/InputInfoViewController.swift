//
//  InputInfoViewController.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/25.
//

import Foundation
import UIKit
import SnapKit

final class InputInfoViewController: UIViewController {
    
    /// MARK: 프로필 설정 제목
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        return label
    }()
    
    /// MARK: 이미지 버튼
    private lazy var imageButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: Login.profile), for: .normal)
        return btn
    }()
    
    /// MARK: 카메라 버튼
    private lazy var cameraUIView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.layer.borderWidth = 1
        return view
    }()
    
    /// MARK: 카메라 버튼
    private lazy var cameraImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: Login.add_a_photo))
        return view
    }()
    
    /// MARK: 닉네임 설정 제목
    private lazy var nickNameTitle: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = .black
        return label
    }()
    
    /// MARK: 닉네임 입력
    private lazy var nickName: UITextField = {
        let field = UITextField()
        field.placeholder = "닉네임을 입력하세요"
        field.textAlignment = .left
        return field
    }()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubViews()
    }
    
    
    // MARK: - Functions
    
    /// MARK: Add UI
    private func addSubViews(){
        view.addSubview(titleLabel)
        view.addSubview(imageButton)
        view.addSubview(cameraUIView)
        cameraUIView.addSubview(cameraImage)
        view.addSubview(nickNameTitle)
        view.addSubview(nickName)
        
        constraints()
        setCornerRadius()
    }
    
    /// MARK: Set Constraints
    private func constraints(){
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        
        imageButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        cameraUIView.snp.makeConstraints { make in
            make.bottom.equalTo(imageButton.snp.bottom)
            make.trailing.equalTo(imageButton.snp.trailing)
            make.width.height.equalTo(imageButton.snp.width).multipliedBy(0.25)
        }
        
        cameraImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nickNameTitle.snp.makeConstraints { make in
            make.top.equalTo(cameraUIView.snp.bottom).offset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalTo(50)
        }
        
        nickName.snp.makeConstraints { make in
            make.top.equalTo(nickNameTitle.snp.top)
            make.leading.equalTo(nickNameTitle.snp.trailing).offset(20)
            make.centerY.equalTo(nickNameTitle.snp.centerY)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
    }
    
    /// MARK: Setting CornerRadius
    private func setCornerRadius(){
        cameraUIView.layoutIfNeeded()
        imageButton.layer.cornerRadius = imageButton.frame.width/2
        cameraUIView.layer.cornerRadius = cameraUIView.frame.width/2
    }
    
    
    
}


import SwiftUI
struct VCPreViewInputInfoViewController:PreviewProvider {
    static var previews: some View {
        InputInfoViewController().toPreview().previewDevice("iPhone 14 Pro")
        // 실행할 ViewController이름 구분해서 잘 지정하기
    }
}
struct VCPreViewInputInfoViewController2:PreviewProvider {
    static var previews: some View {
        InputInfoViewController().toPreview().previewDevice("iPhone SE (3rd generation)")
        // 실행할 ViewController이름 구분해서 잘 지정하기
    }
}
