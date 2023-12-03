//
//  FriendProtocol.swift
//  TWTW
//
//  Created by 정호진 on 12/1/23.
//

import Foundation
import RxSwift

protocol FriendProtocol {
    /// 전체 친구 목록 받아옴
    /// - Returns: 전체 친구 목록
    func getAllFriends() -> Observable<[Friend]>
    
    /// 닉네임 검색
    /// - Parameter word: 입력한 닉네임
    /// - Returns: 닉네임과 일치하는 친구 목록
    func searchingFriends(word: String) -> Observable<[Friend]>
}
