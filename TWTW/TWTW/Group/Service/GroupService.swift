//
//  GroupService.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Alamofire
import RxSwift

final class GroupService: GroupProtocol {
    /// 자신이 속한 그룹 받기
    /// - Returns: 자신이 속한 그룹
    func groupList() -> Observable<[Group]> {
        let url = Domain.RESTAPI + GroupPath.group.rawValue
        let headers = Header.header.getHeader()
        print(url)
        print(headers)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: headers)
            .responseDecodable(of: [Group].self) { response in
                print(#function, response)
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
    
    /// Create Group
    /// - Parameter info: Group Info
    /// - Returns: Group
    func createGroup(info: Group) -> Observable<Group> {
        let url = Domain.RESTAPI + GroupPath.group.rawValue
        let headers = Header.header.getHeader()
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: info,
                       encoder: JSONParameterEncoder.default,
                       headers: headers)
            .responseDecodable(of: Group.self) { response in
                print(#function, response)
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
    
    /// 그룹에 친구 초대
    /// - Parameters:
    ///   - inviteMembers: Member Array
    ///   - groupId: Group Id
    /// - Returns: Group Info
    func inviteGroup(inviteMembers: [String], groupId: String) -> Observable<Group> {
        let url = Domain.RESTAPI + GroupPath.invite.rawValue
        let headers = Header.header.getHeader()
        let parameter = [
            "friendMemberIds": inviteMembers,
            "groupId": groupId
        ] as [String: Any]
        
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: parameter,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .responseDecodable(of: Group.self) { response in
                print(#function, response)
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
    
    /// 그룹에 가입하기
    /// - Parameters:
    ///   - groupId: Group Id
    /// - Returns: Group Id
    func joinGroup(groupId: String) -> Observable<Group> {
        let url = Domain.RESTAPI + GroupPath.join.rawValue
        let headers = Header.header.getHeader()
        let parameter = [
            "groupId": groupId
        ] as [String: Any]
        
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: parameter,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .responseDecodable(of: Group.self) { response in
                print(#function, response)
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
    
}
