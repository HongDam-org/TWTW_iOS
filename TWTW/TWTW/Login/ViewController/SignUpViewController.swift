//
//  SignUpViewController.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/25.
//

import Foundation
import PhotosUI
import RxRelay
import RxSwift
import SnapKit
import UIKit

final class SignUpViewController: UIViewController {
    
    ///  프로필 설정 제목
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        label.textColor = .black
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    ///  이미지 버튼
    private lazy var imageButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: LoginImageTitle.profile.rawValue)?.resize(newWidth: 200, newHeight: 200), for: .normal)
        return btn
    }()
    
    /// 카메라 버튼
    private lazy var cameraUIView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.layer.borderWidth = 1
        return view
    }()
    
    ///  카메라 버튼
    private lazy var cameraImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: LoginImageTitle.photo.rawValue))
        return view
    }()
    
    /// 닉네임 설정 제목
    private lazy var nickNameTitle: UILabel = {
        let label = UILabel()
        label.text = "닉네임 입력"
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    /// 닉네임 입력
    private lazy var nickName: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(string: "닉네임을 입력해주세요!",
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
    
    /// 설명 글 담을 UIView
    private lazy var descriptionUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        return view
    }()
    
    /// 설명
    private lazy var descriptions: UILabel = {
        let label = UILabel()
        label.text = "∙ 특수문자, 띄어쓰기를를 입력할 수 없습니다.\n∙ 최소 2글자, 최대 8글자 입력가능합니다."
        label.numberOfLines = 2
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.44)
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    /// 완료 버튼
    private lazy var doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: SignUpViewModel?
    
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
    
    /// Add UI
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(imageButton)
        view.addSubview(cameraUIView)
        cameraUIView.addSubview(cameraImage)
        view.addSubview(nickNameTitle)
        view.addSubview(nickName)
        view.addSubview(descriptionUIView)
        descriptionUIView.addSubview(descriptions)
        view.addSubview(doneButton)
        
        constraints()
        setCornerRadius()
        bind()
    }
    
    /// Set Constraints
    private func constraints() {
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
            let labelSize = ((nickNameTitle.text ?? "") as NSString)
                .size(withAttributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold) ])
            make.width.equalTo(labelSize.width)
        }
        
        nickName.snp.makeConstraints { make in
            make.top.equalTo(nickNameTitle.snp.top)
            make.leading.equalTo(nickNameTitle.snp.trailing).offset(10)
            make.centerY.equalTo(nickNameTitle.snp.centerY)
            make.height.equalTo(30)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        descriptionUIView.snp.makeConstraints { make in
            make.top.equalTo(nickName.snp.top).offset(50)
            make.horizontalEdges.equalToSuperview()
            let labelSize = ((descriptions.text ?? "") as NSString)
                .size(withAttributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17) ])
            make.height.equalTo(labelSize.height+40)
        }
        
        descriptions.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionUIView.snp.bottom).offset(20)
            make.width.equalTo(view.safeAreaLayoutGuide.layoutFrame.width/5)
            make.height.equalTo(30)
        }
        
    }
    
    /// Setting CornerRadius
    private func setCornerRadius() {
        cameraUIView.layoutIfNeeded()
        self.imageButton.clipsToBounds = true
        imageButton.layer.cornerRadius = imageButton.frame.width/2
        cameraUIView.layer.cornerRadius = cameraUIView.frame.width/2
    }
    
    /// ViewModel binding
    private func bind() {
        let input = SignUpViewModel.Input(doneButtonTapEvents: doneButton.rx.tap.asObservable(),
                                          keyboardReturnTapEvents: nickName.rx.controlEvent([.editingDidEndOnExit]).asObservable(),
                                          nickNameEditEvents: nickName.rx.text.orEmpty.asObservable(),
                                          imageButtonTapEvents: imageButton.rx.tap.asObservable())
        
        let output = viewModel?.bind(input: input)
        
        imageButton.rx.tap
            .bind { [weak self ] _ in
                guard let self = self  else {return}
                selectedPicture()
            }
            .disposed(by: disposeBag)
        
        nickName.rx.text.orEmpty
            .asObservable()
            .scan("") { lastValue, newValue in
                let removedSpaceString = newValue.replacingOccurrences(of: " ", with: "")
                return removedSpaceString.count == newValue.count ? newValue : lastValue
            }
            .bind(to: nickName.rx.text)
            .disposed(by: self.disposeBag)
        
        bindNickNameFiltering(output: output)
        bindOverlapNickNameSubject(output: output)
        bindFailureSubject(output: output)
    }
    
    /// 닉네임 필터링 binding
    private func bindNickNameFiltering(output: SignUpViewModel.Output?) {
        output?.nickNameFilteringRelay
            .asDriver()
            .drive(nickName.rx.text)
            .disposed(by: disposeBag)
    }
    
    /// 닉네임 필터링 binding
    private func bindOverlapNickNameSubject(output: SignUpViewModel.Output?) {
        output?.overlapNickNameSubject
            .bind(onNext: { [weak self] _ in
                guard let self = self else {return}
                showAlert(title: "중복된 닉네임입니다.", message: nil)
            })
            .disposed(by: disposeBag)
    }
    
    /// 닉네임 필터링 binding
    private func bindFailureSubject(output: SignUpViewModel.Output?) {
        output?.checkSignUpSubject
            .bind(onNext: { [weak self] check in
                guard let self = self else { return }
                if !check {
                    showAlert(title: "회원가입 실패!", message: "다시 시도해주세요.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 사진 선택하는 actionSheet
    private func selectedPicture() {
        let alert = UIAlertController(title: "프로필 선택", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction =  UIAlertAction(title: "카메라 선택", style: UIAlertAction.Style.default) { [weak self] _ in
            guard let self = self else { return }
            takePhoto()
        }
        let photoAction =  UIAlertAction(title: "사진 선택", style: UIAlertAction.Style.default) { [weak self] _ in
            guard let self = self else { return }
            selectedPhoto()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    /// 사진 앱에서 사진 선택
    private func selectedPhoto() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .any(of: [.images])
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            let nvPicker = UINavigationController(rootViewController: picker)
            nvPicker.modalPresentationStyle = .fullScreen
            present(nvPicker, animated: false)
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /// 카메라로 사진 찍기
    private func takePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    /// 알림 팝업
    private func showAlert(title: String?, message: String?) {
        let alertControllerc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alertControllerc.addAction(confirm)
        present(alertControllerc, animated: true)
    }
}

/// 카메라 사진찍은 경우 or iOS 14이전
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.imageButton.setImage(image.resize(newWidth: 200, newHeight: 200), for: .normal)
            self.setCornerRadius()
        }
        dismiss(animated: true, completion: nil)
    }
}

/// iOS14 이후 사진 선택
extension SignUpViewController: PHPickerViewControllerDelegate {
    
    /// 사진을 선택완료 했을 때 실행
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _) in
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    if let image = image as? UIImage {
                        
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
