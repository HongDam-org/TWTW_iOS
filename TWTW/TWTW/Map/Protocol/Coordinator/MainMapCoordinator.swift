//
//  MainMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

protocol MainMapCoordinator : Coordinator {
    /// 검색화면으로 이동
    func moveSearch(output: MainMapViewModel.Output)
    
    /// Create Tabbar Item 
    func createTabbarItem(_ tabbarController: TabBarController)
    
    /// Create Tabbar Item Coordinator
    func createTabbarItemCoordinators(_ tabbarController: TabBarController)
}
