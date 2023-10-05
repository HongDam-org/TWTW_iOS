//
//  InputInfoViewController.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/25.
//

import Foundation
import UIKit
import SnapKit
import PhotosUI
import RxSwift
import RxRelay

final class InputInfoViewController: UIViewController {
    
    /// MARK: 프로필 설정 제목
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        label.textColor = .black
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    /// MARK: 이미지 버튼
    private lazy var imageButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: Login.profile)?.resize(newWidth: 200, newHeight: 200), for: .normal)
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
        label.text = "닉네임 입력"
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    /// MARK: 닉네임 입력
    private lazy var nickName: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(string: "닉네임을 입력해주세요!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        field.textAlignment = .left
        field.backgroundColor = UIColor.profileTextFieldColor
        field.layer.cornerRadius = 10
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.profileTextFieldColor?.cgColor
        field.textColor = .black
        field.delegate = self
        
        let leftView = UIView(frame: CGRect(x: .zero, y: .zero, width: 10, height: field.frame.height))
        field.leftView = leftView
        field.leftViewMode = .always
        return field
    }()
    
    /// MARK: 완료 버튼
    private lazy var doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = SignInViewModel.shared
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubViews()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        nickName.endEditing(true)
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
        view.addSubview(doneButton)
        
        constraints()
        setCornerRadius()
        bind()
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
            make.width.height.equalTo(200)
        }
        
        cameraUIView.snp.makeConstraints { make in
            make.bottom.equalTo(imageButton.snp.bottom)
            make.trailing.equalTo(imageButton.snp.trailing)
            make.width.height.equalTo(imageButton.snp.width).multipliedBy(0.25)
        }
        
        cameraImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(imageButton.snp.width).multipliedBy(0.15)
        }
        
        nickNameTitle.snp.makeConstraints { make in
            make.top.equalTo(cameraUIView.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            let labelSize = ((nickNameTitle.text ?? "") as NSString).size(withAttributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold) ])
            make.width.equalTo(labelSize.width)
        }
        
        nickName.snp.makeConstraints { make in
            make.top.equalTo(nickNameTitle.snp.top)
            make.leading.equalTo(nickNameTitle.snp.trailing).offset(10)
            make.centerY.equalTo(nickNameTitle.snp.centerY)
            make.height.equalTo(30)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nickName.snp.top).offset(50)
            make.width.equalTo(view.safeAreaLayoutGuide.layoutFrame.width/5)
            make.height.equalTo(30)
        }
        
    }
    
    /// MARK: Setting CornerRadius
    private func setCornerRadius(){
        cameraUIView.layoutIfNeeded()
        self.imageButton.clipsToBounds = true
        imageButton.layer.cornerRadius = imageButton.frame.width/2
        cameraUIView.layer.cornerRadius = cameraUIView.frame.width/2
    }
    
    /// MARK: ViewModel binding
    private func bind(){
        nickName.rx.text
            .bind { [weak self] text in
                guard let self = self  else {return}
                guard let text = text else {return}
                viewModel.nickName.accept(text)
            }
            .disposed(by: disposeBag)
        
        imageButton.rx.tap
            .bind { [weak self ] _ in
                guard let self = self  else {return}
                selectedPicture()
            }
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind { [weak self ] _ in
                guard let self = self  else {return}
                checkOverlapId()
            }
            .disposed(by: disposeBag)
        
        
    }
    
    /// MARK: 아이디 중복 확인 검사
    private func checkOverlapId(){
        // ID 중복 검사 코드 작성
        let viewController = MeetingListViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// MARK: 사진 선택하는 actionSheet
    private func selectedPicture(){
        let alert = UIAlertController(title: "프로필 선택", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction =  UIAlertAction(title: "카메라 선택", style: UIAlertAction.Style.default) { [weak self] _ in
            guard let self = self else { return }
            takePhoto()
        }
        let photoAction =  UIAlertAction(title: "사진 선택", style: UIAlertAction.Style.default){ [weak self] _ in
            guard let self = self else { return }
            selectedPhoto()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    /// 사진 앱에서 사진 선택
    private func selectedPhoto() {
        if #available(iOS 14, *){
            print("called1")
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 10
            configuration.filter = .any(of: [.images])
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            let nvPicker = UINavigationController(rootViewController: picker)
            nvPicker.modalPresentationStyle = .fullScreen
            present(nvPicker,animated: false)
        }
        else {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    /// MARK: 카메라로 사진 찍기
    private func takePhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /// MARK: 회원가입
    private func signUp(){
        viewModel.signUp()
            .subscribe(onNext:{ [weak self] data in
                guard let self = self else {return}
                let viewController = MeetingListViewController()
                navigationController?.pushViewController(viewController, animated: true)
            },onError: { error in   // 에러 처리 해야함
                print(#function)
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

/// MARK: 카메라 사진찍은 경우 or iOS 14이전
extension InputInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.viewModel.selectedPhotoImages.accept(image)
            self.imageButton.setImage(image.resize(newWidth: 200, newHeight: 200), for: .normal)
            self.setCornerRadius()
        }
        dismiss(animated: true, completion: nil)
    }
}

/// MARK: iOS14 이후 사진 선택
extension InputInfoViewController: PHPickerViewControllerDelegate {
    
    /// 사진을 선택완료 했을 때 실행
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    if let image = image as? UIImage {
                        self.viewModel.selectedPhotoImages.accept(image)
                        self.imageButton.setImage(image.resize(newWidth: 200, newHeight: 200), for: .normal)
                        self.setCornerRadius()
                    }
                }
            }
        }
        
    }
    
    /// 취소버튼 누른 경우
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension InputInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel.calculateTextField(text: textField.text ?? "", string: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkOverlapId()
        print(#function)
        return true
    }
}
