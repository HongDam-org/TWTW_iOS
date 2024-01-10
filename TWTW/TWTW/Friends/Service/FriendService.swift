//
//  FriendService.swift
//  TWTW
//
//  Created by 정호진 on 12/1/23.
//

import Alamofire
import RxSwift

final class FriendService: FriendProtocol {
    /// 전체 친구 목록 받아옴
    /// - Returns: 전체 친구 목록
    func getAllFriends() -> Observable<[Friend]> {
        let url = Domain.RESTAPI + FriendPath.all.rawValue
        let header = Header.header.getHeader()
        
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: [Friend].self) { response in
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
    
    /// 닉네임 검색
    /// - Parameter word: 입력한 닉네임
    /// - Returns: 닉네임과 일치하는 친구 목록
    func searchingFriends(word: String) -> Observable<[Friend]> {
        let url = Domain.RESTAPI + FriendPath.search.rawValue
            .replacingOccurrences(of: "NAME", with: word)
        let header = Header.header.getHeader()
        
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: [Friend].self) { response in
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
    
    
    /// 친구 신청보내기
    func requestFriends(memberId: String) -> Observable<Void> {
        let url = Domain.RESTAPI + FriendPath.request.rawValue
        let header = Header.header.getHeader()
        let parameters: [String: Any] = ["memberId": memberId]
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: header)
            .response { response in
                switch response.result {
                case .success:
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 친구가 아닌 친구에게 친구 신청
    func searchNotFriends(nickName: String) -> Observable<[Friend]> {
        let url = Domain.RESTAPI + FriendPath.notFriendSearch.rawValue
            .replacingOccurrences(of: "NAME", with: nickName)
        let header = Header.header.getHeader()
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: [Friend].self) { response in
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
    
    /// 친구가 아닌 친구에게 친구 신청
    func statusFriend(memberId: String, status: String) -> Observable<Void> {
        let url = Domain.RESTAPI + FriendPath.status.rawValue
        let header = Header.header.getHeader()
        let body: Parameters = [
            "memberId" : memberId,
            "friendStatus" : status
        ]
        print(#function)
        print(url)
        print(body)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: body,
                       encoding: JSONEncoding.default,
                       headers: header)
            .response { response in
                switch response.result {
                case .success(_):
                    observer.onNext(())
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
