//
//  DefaultMainMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift

final class DefaultMainMapCoordinator: MainMapCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController //for SearchPlacesCoordinator
    private var mainMapViewModel: MainMapViewModel?
    private var mainMapViewModelOutput: MainMapViewModel.Output?
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        mainMapViewModel = MainMapViewModel(coordinator: self)
    }
    
    func start(){
        guard let mainMapViewModel = mainMapViewModel else {return}
        let tabbarController = TabBarController(viewModel: TabBarViewModel())
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel,
                                                          tabbarController: tabbarController)
        self.navigationController.pushViewController(mainMapViewController, animated: true)
        createTabbarItemCoordinators(tabbarController)
    }
    
    /// MARK: SearchPlacesMapCoordinator 시작하는 메소드
    func moveSearch(output: MainMapViewModel.Output){
        mainMapViewModelOutput = output
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController, delegate: self)
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
    
    /// Create Tabbar Item Coordinator
    func createTabbarItemCoordinators(_ tabbarController: TabBarController) {
        let homeCoordinator = DefaultPreviousAppointmentsCoordinator(navigationController: UINavigationController())
        let scheduleCoordinator = DefaultPreviousAppointmentsCoordinator(navigationController: UINavigationController())
        let friendsListCoordinator = DefaultFriendsListCoordinator(navigationController: UINavigationController())
        let notificationCoordinator = DefaultNotificationCoordinator(navigationController: UINavigationController())
        let callCoordinator = DefaultCallCoordinator(navigationController: UINavigationController())
        
        tabbarController.viewControllers = [ homeCoordinator.startPush(),
                                             scheduleCoordinator.startPush(),
                                             friendsListCoordinator.startPush(),
                                             notificationCoordinator.startPush(),
                                             callCoordinator.startPush()]
        createTabbarItem(tabbarController)
    }
    
    /// Create Tabbar Item
    func createTabbarItem(_ tabbarController: TabBarController) {
        let tabItems: [TabItem] = [
            TabItem(title: TabbarItemTitle.house.rawValue,
                    imageName: TabbarItemImageName.house.rawValue),
            TabItem(title: TabbarItemTitle.calendar.rawValue,
                    imageName: TabbarItemImageName.calendar.rawValue),
            TabItem(title: TabbarItemTitle.person.rawValue,
                    imageName: TabbarItemImageName.person.rawValue),
            TabItem(title: TabbarItemTitle.bell.rawValue,
                    imageName: TabbarItemImageName.bell.rawValue),
            TabItem(title: TabbarItemTitle.phone.rawValue,
                    imageName: TabbarItemImageName.phone.rawValue)
        ]
        
        tabbarController.viewControllers?
            .enumerated()
            .forEach { index, viewController in
                viewController.tabBarItem = UITabBarItem(title: tabItems[index].title,
                                                         image: UIImage(systemName: tabItems[index].imageName),
                                                         selectedImage: nil)
            }
        tabbarController.start()
    }
    
}

// MARK: - SearchPlacesCoordinator에서 좌표 받는 함수
extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate{
    
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D) {
        mainMapViewModelOutput?.showNearPlacesUI.accept(true)
        mainMapViewModelOutput?.cameraCoordinateObservable.accept(coordinate)
        
        let _ = childCoordinators.popLast()
        print(#function)
        print(childCoordinators)
    }
}
