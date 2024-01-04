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
    //plan정보조회
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
    func savePlanService(request: PlanSaveRequest) -> RxSwift.Observable<PlanSaveResponse> {
        
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            var encodedRequest = request
                  encodedRequest.encodePlaceDetails()
            
            let url = Domain.RESTAPI + PlanPath.save.rawValue
            AF.request(url, method: .post, parameters: encodedRequest, encoder: JSONParameterEncoder.default, headers: header)
                .validate(statusCode: 200..<201)
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
}
