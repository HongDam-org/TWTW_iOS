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
    
    private let disposeBag = DisposeBag()
    private let viewModel = SignInViewModel.shared
    /// 선택한 이미지들
    private var selectedPhotoImages: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage(resource: .profile))
    
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
                selectedList()
            }
            .disposed(by: disposeBag)
        
    }
    
    /// MARK:
    private func selectedList(){
        let alert = UIAlertController(title: "프로필 선택", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction =  UIAlertAction(title: "카메라 선택", style: UIAlertAction.Style.default) { [weak self] _ in
            guard let self = self else { return }
            takePhoto()
        }
        let photoAction =  UIAlertAction(title: "사진 선택", style: UIAlertAction.Style.default){ [weak self] _ in
            guard let self = self else { return }
            print("called")
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
    
}

/// MARK: 카메라 사진찍은 경우 or iOS 14이전
extension InputInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.selectedPhotoImages.accept(image)
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
                        self.selectedPhotoImages.accept(image)
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
