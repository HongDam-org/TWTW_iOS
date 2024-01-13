//
//  PlanService.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/24.
//

import Alamofire
import CoreLocation
import Foundation
import RxSwift
import UIKit

/// Plan페이지 정보:
/// -  약속명, 목적지, 날짜시간, 참여인원 불러오기
final class PlanService: PlanProtocol {
    /// 단건조회
    func getPlanLookupService() -> RxSwift.Observable<[Plan]> {
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            let url = Domain.RESTAPI + PlanPath.all.rawValue
            AF.request(url, method: .get, headers: header)
                .responseDecodable(of: [Plan].self) { response in
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
    
    /// plan정보조회
    func getPlanService(request: String) -> RxSwift.Observable<Plan> {
        let planID = "plan 셀로 들어올때 ID KeyChain에 저장"
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            let url = Domain.RESTAPI + PlanPath.all.rawValue
                .replacingOccurrences(of: "PLANID", with: planID)
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: Plan.self) { response in
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
    
    /// 계획 저장 savePlanService
    func savePlanService(request: PlanSaveRequest) -> Observable<PlanSaveResponse> {
        let url = Domain.RESTAPI + PlanPath.save.rawValue
        let header = Header.header.getHeader()
        
        // 들어갈 JSON 데이터
        let placeDetailsJson: [String: Any] = [
            "placeName": request.placeDetails.placeName,
            "placeUrl": request.placeDetails.placeUrl,
            "roadAddressName": request.placeDetails.roadAddressName,
            "longitude": request.placeDetails.longitude,
            "latitude": request.placeDetails.latitude
        ]
        
        let parameters: [String: Any] = [
            "name": request.name ?? "",
            "groupId": request.groupId ?? "",
            "planDay": request.planDay ?? "",
            "placeDetails": placeDetailsJson,
            "memberIds": request.memberIds.compactMap { $0 }
        ]
        print(parameters)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: header)
            .responseDecodable(of: PlanSaveResponse.self) { response in
               
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
    
    /// 계획 참여
    /// - Parameter planId: 참여할 Plan 아이디
    func joinPlanService(planId: String) -> Observable<Void> {
        let url = Domain.RESTAPI + PlanPath.join.rawValue
        let header = Header.header.getHeader()
        let parameters: Parameters = [
            "planId": planId
        ]
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
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
}
