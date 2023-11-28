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
        let url = Domain.RESTAPI + GroupPath.groupList.rawValue
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
}
