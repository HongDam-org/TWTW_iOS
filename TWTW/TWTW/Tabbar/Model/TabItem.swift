//
//  TabbarItems.swift
//  TWTW
//
//  Created by 정호진 on 10/20/23.
//

import Foundation

struct TabItem {
    let title: String
    let imageName: String
}

enum TabbarItemImageName: String {
    case house
    case calendar
    case person = "person.2"
    case bell
    case phone
}

enum TabbarItemTitle: String{
    case house = "홈"
    case calendar = "일정"
    case person = "친구 목록"
    case bell = "알림"
    case phone = "전화"
}
