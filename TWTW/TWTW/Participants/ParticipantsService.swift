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
    /// - 이후에 plan을 통해 이 화면으로 돌아온 경우 참여자만 보여줄지 상의 필요
    
    /// - Returns: Group내 모든 친구 조회
    func getGroupFriends(request: String) -> Observable<[Friend]> {
        let groupID = "처음에 group셀로 들어올때 groupID KeyChain에 저장"
        let url = Domain.RESTAPI + GroupPath.lookUpGroup.rawValue
            .replacingOccurrences(of: "GROUPID", with: "groupID")
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: GroupLookUpInfo.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data.groupMembers)
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
    
    // MARK: - 아직 서버 미구현 부분
    /// Description:  group이지만 참여하지 않은 친구 조회
    /// - Parameter word: <#word description#>
    /// - Returns: <#description#>
//    func getNotYetParticipants(request word: String) -> RxSwift.Observable<[Friend]> {
//        
//    }
//    
//    /// Description:  group이지만 참여하지 않은 친구 초대요청
//    /// - Parameter memberId: <#memberId description#>
//    /// - Returns: <#description#>
//    func requestNotYetParticipants(request memberId: String) -> RxSwift.Observable<Void> {
//    }
}
