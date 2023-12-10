//
//  BaseTabCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/11.
//

import Foundation

/// Tabbar hidden/show 관리 포함 Coordinator
protocol BaseTabBarCoodinator: Coordinator {
    
    /// 탭바관리 함수
    func setNavigationControllerDelegate()
}
