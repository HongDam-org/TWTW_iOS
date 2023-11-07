//
//  SignUpService.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation
import Alamofire
import RxSwift

final class SignUpService: SignUpProtocol {
    private let disposeBag = DisposeBag()
    
    /// 회원가입할 떄 호출
    /// - Parameter request: 서버에 보내는 회원가입 정보
    /// - Returns: 회원 상태, AccesToken, RefreshToken
    func signUpService(request: LoginRequest) -> Observable<LoginResponse> {
        let url = Domain.REST_API + LoginPath.signUp.rawValue
        print(#function)
        print(url)
        print(request)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: request,
                       encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: LoginResponse.self) { response in
                
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    /// ID 중복 검사
    /// - Parameter id: nickName
    /// - Returns: true 중복, false: 사용가능
    func checkOverlapId(id: String) -> Observable<Bool> {
        var url = Domain.REST_API + LoginPath.checkOverlapId.rawValue
        url = url.replacingOccurrences(of: "Id", with: id)
        print(url)
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: OverLapIdResponse.self){ res in
                print(res)
                switch res.result{
                case .success(let data):
                    observer.onNext(data.isPresent ?? true)
                case .failure(let error):
                    print(#function)
                    print(error)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
}
