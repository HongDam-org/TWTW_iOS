//
//  MainMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift

class MainMapCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController //for SearchPlacesCoordinator
    var tabBarController: UITabBarController // for TabBarCoordinator
    
    private let cameraCoordinateSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private var mainMapViewModel: MainMapViewModel?

    
    init(navigationController: UINavigationController, tabBarController: UITabBarController){
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        
       

    }
    func start(){
        let mainMapViewModel = MainMapViewModel(coordinator: self)
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel)
        
        mainMapViewModel.cameraCoordinateObservable = cameraCoordinateSubject.asObservable()
        
        // TabBarCoordinator 시작
       // showTabBarCoordinator()
        
        //MainMapVC
        self.navigationController.pushViewController(mainMapViewController, animated: true)
        
        
        //SearchPlaces는 MainMap에서 필요한 시점에 호출
    }
    ///TabBarCoordinator을 시작하는 메소드
//    func showTabBarCoordinator(){
//        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController )
//        tabBarCoordinator.start()
//        childCoordinators.append(tabBarCoordinator)
//    }
    
    ///SearchPlacesMapCoordinator 시작하는 메소드
    func showSearchPlacesMap(){
        let searchPlacesMapCoordinator = SearchPlacesMapCoordinator(navigationController: navigationController, parentCoordinator: self)
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
    
    //SearchPlacesCoordinator에서 좌표 받는 함수
    func selectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
            cameraCoordinateSubject.onNext(coordinate)
        }
        
}
