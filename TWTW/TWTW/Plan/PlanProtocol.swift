//
//  PlanProtocol.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/24.
//

import Foundation
import RxSwift
protocol PlanProtocol {
    /// 계획 불러오는 페이지
    //func getPlanLookupService() -> Observable<Plan>
    /// - Parameter request: 서버에 보내는 planID
    /// - Returns: Plan단건조회
    func getPlanService(request: String) -> Observable<Plan>
    /// 계획 저장
    func savePlanService(request: PlanSaveRequest) -> Observable<PlanSaveResponse>
}
