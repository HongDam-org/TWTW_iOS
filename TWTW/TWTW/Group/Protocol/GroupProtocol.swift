//
//  GroupProtocol.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation
import RxSwift

protocol GroupProtocol {
    /// 자신이 속한 그룹 받기
    /// - Returns: 자신이 속한 그룹
    func groupList() -> Observable<[Group]>
    
    /// Create Group
    /// - Parameter info: Group Info
    /// - Returns: Group
    func createGroup(info: Group) -> Observable<Group>
    
    /// 그룹에 가입하기
    /// - Parameters:
    ///   - groupId: Group Id
    /// - Returns: Group Id
    func joinGroup(groupId: String) -> Observable<Group>
    
    /// 그룹에 친구 초대
    /// - Parameters:
    ///   - inviteMembers: Member Array
    ///   - groupId: Group Id
    /// - Returns: Group Info
    func inviteGroup(inviteMembers: [String], groupId: String) -> Observable<Group>
}
