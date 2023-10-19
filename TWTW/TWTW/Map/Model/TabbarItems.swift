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

enum TabbarItemTitle: String {
    case house
    case calendar
    case person = "person.2"
    case bell
    case phone
}
