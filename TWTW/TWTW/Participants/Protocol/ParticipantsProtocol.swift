//
//  ParticipantsProtocol.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/24.
//

import Foundation
import RxSwift

protocol ParticipantsProtocol {

/// - Group 친구
/// 그룹 전체 참여자 목록 받아옴
    func getGroupFriends() -> Observable<[Friend]>

///  - Plan 참여자 친구
/// 그룹 내 특정 plan 참여자 목록
    func getParticipants(request: String) -> Observable<[Friend]>

    /// 내 위치 변경
    /// - Parameters:
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: 성공 여부
    func changeMyLocation(latitude: Double, longitude: Double) -> Observable<Void>
    
///  - 참여자가 아닌 친구
/// 목록 보여주기
//func getNotYetParticipants(request: String) -> Observable<[Friend]>
//    
///// 그룹 내 특정 plan 참여 요청
///// - Parameter memberId
//func requestNotYetParticipants(request: String) -> Observable<Void>
}
