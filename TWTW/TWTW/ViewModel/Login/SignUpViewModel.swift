//
//  SignUpViewModel.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation
import RxSwift
import RxRelay

final class SignUpViewModel {
    weak var coordinator: SignUpCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private let signUpServices: SignUpProtocol?
    final private let maxLength = 8
    final private let minLength = 2
    
    // MARK: - Init
    init(coordinator: SignUpCoordinatorProtocol?, signUpServices: SignUpProtocol?) {
        self.coordinator = coordinator
        self.signUpServices = signUpServices
    }

    /// Input
    struct Input {
        let doneButtonTapEvents: Observable<Void>
        let keyboardReturnTapEvents: Observable<Void>
        let nickNameEditEvents: Observable<String>
        let imageButtonTapEvents: Observable<Void>
    }
    
    /// Output
    struct Output {
        let nickNameFilteringRelay: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
        let overlapNickNameSubject: PublishSubject<Void> = PublishSubject<Void>()
        let checkSignUpSubject: PublishSubject<Bool> = PublishSubject<Bool>()
    }
    
    // MARK: - Functions
    
    /// binding Input
    /// - Parameters:
    ///   - input: Input 구조체
    /// - Returns: Output 구조체
    func bind(input: Input) -> Output {
        return createOutput(input: input)
    }
    
    /// MARK: create Output
    /// - Parameters:
    ///   - input: Input 구조체
    /// - Returns: Output 구조체
    private func createOutput(input: Input) -> Output{
        let output = Output()
        
        input.doneButtonTapEvents
            .bind { [weak self] _ in
                guard let self = self  else { return }
                if output.nickNameFilteringRelay.value != ""  && output.nickNameFilteringRelay.value.count >= minLength{
                    checkOverlapId(nickName: output.nickNameFilteringRelay.value, output: output)
                }
            }
            .disposed(by: disposeBag)
        
        input.keyboardReturnTapEvents
            .bind { [weak self] _ in
                guard let self = self  else { return }
                if output.nickNameFilteringRelay.value != "" && output.nickNameFilteringRelay.value.count >= minLength{
                    return checkOverlapId(nickName: output.nickNameFilteringRelay.value, output: output)
                }
                output.checkSignUpSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        
        input.nickNameEditEvents
            .bind { [weak self] text in
                guard let self = self else {return}
                if text.count <= maxLength{
                    return output.nickNameFilteringRelay.accept(text)
                }
                output.nickNameFilteringRelay.accept(String(text.dropLast(text.count-maxLength)))
                
            }
            .disposed(by: disposeBag)
        
        output.overlapNickNameSubject
            .bind {
                output.checkSignUpSubject.onNext(false)
            }
            .disposed(by: disposeBag)
        return output
    }

    // MARK: - API Connect
    
    /// ID 중복 검사
    /// - Parameters:
    ///   - nickName: user NickName
    ///   - output: Output 구조체
    func checkOverlapId(nickName: String, output: Output) {
        signUpServices?.checkOverlapId(id: nickName)
            .subscribe(onNext: { [weak self] check in
                guard let self = self  else {return}
                if !check {
                    return signUp(nickName: nickName, output: output)
                }
                output.overlapNickNameSubject.onNext(())
            },onError: { error in
                output.failureSignUpSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    /// 회원가입할 때 호출
    /// - Parameters:
    ///   - nickName: user NickName
    ///   - output: Output 구조체
    func signUp(nickName: String, output: Output){
        
        let identifier = KeychainWrapper.loadString(forKey: SignInSaveKeyChain.identifier.rawValue) ?? ""
        let authType = KeychainWrapper.loadString(forKey: SignInSaveKeyChain.authType.rawValue) ?? ""
        
        let loginRequest = LoginRequest(nickname: nickName,
                                        profileImage: "!!!!!",
                                        oauthRequest: OAuthRequest(token: identifier,
                                                                   authType: authType))
        print(#function)
        print(loginRequest)
        signUpServices?.signUpService(request: loginRequest)
            .subscribe(onNext:{ [weak self] data in
                guard let self = self else {return}
                output.checkSignUpSubject.onNext(true)
                coordinator?.moveMain()
            },onError: { error in   // 에러 처리 해야함
                print(#function)
                print(error)
                output.checkSignUpSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
}
