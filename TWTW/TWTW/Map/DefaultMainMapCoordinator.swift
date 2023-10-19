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
    private var tabBarController: TabBarController? // for TabBarCoordinator
    private var tabbarCoordinator: DefaultTabbarCoordinator
    private var mainMapViewModel: MainMapViewModel?
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.tabbarCoordinator = DefaultTabbarCoordinator(navigationController: navigationController)
        tabbarCoordinator.delegate = self
        tabbarCoordinator.start()
        mainMapViewModel = MainMapViewModel(coordinator: self)
    }
    
    func start(){
        guard let mainMapViewModel = mainMapViewModel else {return}
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel)
        self.navigationController.pushViewController(mainMapViewController, animated: true)
    }
    
    ///SearchPlacesMapCoordinator 시작하는 메소드
    func showSearchPlacesMap(){
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController, delegate: self)
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
}

extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate{
    //SearchPlacesCoordinator에서 좌표 받는 함수
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D) {
        mainMapViewModel?.cameraCoordinateObservable = coordinate
        
        //ViewController의 주변장소 설정 show/hide
        mainMapViewModel?.showNearPlacesUI.accept(true)
    }
}

extension DefaultMainMapCoordinator: TabbarCoordinatorDelegate {
    func tabbarControllerInstance(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
    }
}
