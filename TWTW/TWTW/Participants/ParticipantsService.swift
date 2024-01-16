//
//  ParticipantsService.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/23.
//

import Alamofire
import RxSwift

final class ParticipantsService: ParticipantsProtocol {
    
    /// 그룹사람
    /// - 처음 지도화면들어갔을땐 plan에대한 정보가 없다
    /// - Group을 통해 Group참여자들 모두 조회
    /// - Returns: Group내 모든 친구 조회
    func getGroupFriends() -> Observable<[Friend]> {
        let groupID = KeychainWrapper.loadItem(forKey: "GroupId") ?? ""
        let url = Domain.RESTAPI + GroupPath.lookUpGroup.rawValue
            .replacingOccurrences(of: "GROUPID", with: groupID)
        let header = Header.header.getHeader()
        
        print(url)
        print("header \(header)")
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: GroupLookUpInfo.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data.groupMembers ?? [])
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    /// plan 내 사람
    /// - Parameter word: planID
    /// - Returns: plan내 Friends
    func getParticipants(request: String) -> RxSwift.Observable<[Friend]> {
        let planID = "plan 셀로 들어올때 ID KeyChain에 저장"
        
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            let url = Domain.RESTAPI + ParticipantsPath.all.rawValue
                .replacingOccurrences(of: "PLANID", with: planID)
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: Plan.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data.members)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 내 위치 변경
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: 성공 여부
    func changeMyLocation(latitude: Double, longitude: Double) -> Observable<Void> {
        let url = Domain.RESTAPI + GroupPath.changeMyLocation.rawValue
        let header = Header.header.getHeader()
        let groupId = KeychainWrapper.loadItem(forKey: "GroupId") ?? ""
        print(#function, url)
        
        let body: Parameters = [
              "groupId": groupId,
              "longitude": longitude,
              "latitude": latitude
        ]
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: body,
                       encoding: JSONEncoding.default,
                       headers: header)
            .response { response in
                switch response.result {
                case .success((_)):
                    observer.onNext(())
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func getMyInformation() -> Observable<MyInfo> {
        let url = Domain.RESTAPI + LoginPath.myInfo.rawValue
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: MyInfo.self) { response in
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
