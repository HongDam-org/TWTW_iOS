//
//  test.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/20.
//

import Foundation

 import UIKit
 import Alamofire
 import RxSwift
 import RxCocoa

 class Test: UIViewController {
     private let disposeBag = DisposeBag()

     override func viewDidLoad() {
         super.viewDidLoad()
/*
 struct Domain {
     static let REST_API = "http://" + (Bundle.main.object(forInfoDictionaryKey: "IP") as? String ?? "") + (Bundle.main.object(forInfoDictionaryKey: "PORT") as? String ?? "") + "/api/v1"
 }
 ...
 let url = Domain.REST_API + LoginPath.signUp
...
 struct SearchPath {
     static let placeAndCategory = "/plans/search/destination/"
     
 }

 struct LoginPath {
     static let signUp = "/auth/save"
     static let signIn = "/auth/login"
     static let updateToken = "/auth/refresh"
     static let checkValidation = "/auth/validate"
     static let checkOverlapId = "/member/duplicate/Id"
 }

 */
         let baseURL =  "http://192.168.0.170:8080/api/v1"  // 서버의 기본 URL (192.168.0.170-> wifi ip), (:8080/api/v1->서버 주소)
         let apiPath = "/plans/search/destination" // API 엔드포인트:
         let query = "이디야커피 안성죽산점" //한글치면 인식 안됨 query ->encode추가해서 풀어주기
         let x = "127.426"
         let y = "37.0764"
         let page = "1"
         let categoryGroupCode = "CE7"

         // query 문자열을 URL에서 사용 가능하도록 인코딩
         let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

         // 요청할 URL을 생성
         if let url = URL(string: "\(baseURL)\(apiPath)?query=\(encoded)&x=\(x)&y=\(y)&page=\(page)&categoryGroupCode=\(categoryGroupCode)") {
             // RxSwift로 API 요청을 관찰 가능한(Observable)로
             let requestObservable = Observable<Void>.create { observer in
                 // Alamofire를 사용하여 GET 요청
                 AF.request(url, method: .get)
                     .validate(statusCode: 200..<300)
                     .response { response in
                         if let error = response.error {
                             // 에러가 발생한 경우, Observable에서 에러를 발생
                             observer.onError(error)
                         } else {
                             // 요청이 성공하고 응답을 받은 경우, Observable에 성공 이벤트를 전달
                             observer.onNext(()) //onNext(())는 성공 이벤트를 전달
                             observer.onCompleted()//onCompleted()는 이 Observable의 작업이 완료됨을 알림
                         }
                     }
                 return Disposables.create() //Disposable 객체를 반환합니다. 이것은 Observable의 수명 주기를 관리하는 데 사용되며, Observable 구독을 해제하거나 취소할 때 자원을 해제하는 데 도움
             }

             // API 요청을 구독하고 응답 데이터를 처리
             requestObservable
                 .subscribe(onNext: {
                     // 요청이 성공한 경우, 로그를 출력
                     print("서버와 연결 성공")
                 }, onError: { error in
                     // 에러가 발생한 경우, 에러 로그를 출력
                     print(url)
                     print("서버와 연결 실패: \(error.localizedDescription)")
                 })
                 .disposed(by: disposeBag)
         } else {
             // 유효하지 않은 URL인 경우, 에러 로그를 출력.
             print("유효하지 않은 URL!")
         }
     }
 }
 
