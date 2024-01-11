//
//  TabBarItemType.swift
//  TWTW
//
//  Created by 정호진 on 12/23/23.
//

import Foundation

enum TabBarItemType: String, CaseIterable {
    case friends, home, myPage
    
    // Int형에 맞춰 초기화
    init?(index: Int) {
        switch index {
        case 0: self = .friends
        case 1: self = .home
        case 2: self = .myPage
        default: return nil
        }
    }
    
    /// TabBarPage 형을 매칭되는 Int형으로 반환
    func toInt() -> Int {
        switch self {
        case .friends: return 0
        case .home: return 1
        case .myPage: return 2
        }
    }
    
    /// TabBarPage 형을 매칭되는 한글명으로 변환
    func toKrName() -> String {
        switch self {
        case .friends: return "친구 목록"
        case .home: return "홈"
        case .myPage: return "마이페이지"
        }
    }
    
    /// TabBarPage 형을 매칭되는 아이콘명으로 변환
    func toIconName() -> String {
        switch self {
        case .friends: return "person.2"
        case .home: return "house"
        case .myPage: return "person"
        }
    }
}
