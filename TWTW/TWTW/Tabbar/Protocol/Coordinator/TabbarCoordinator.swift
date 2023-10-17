//
//  TabbarCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/17/23.
//

import Foundation

/// Tabbar Coordinator protocol
protocol TabbarCoordinator: Coordinator {
    var tabBarController: TabBarController {get set} // for TabBarCoordinator
}
