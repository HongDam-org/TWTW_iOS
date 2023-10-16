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

class DefaultMainMapCoordinator: MainMapCoordinator {
  
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController //for SearchPlacesCoordinator
    var tabBarController: TabBarController // for TabBarCoordinator
    
    private let cameraCoordinateSubject = PublishSubject<CLLocationCoordinate2D>()
    private var mainMapViewModel: MainMapViewModel?

    
    init(navigationController: UINavigationController, tabBarController: TabBarController){
        self.navigationController = navigationController
        self.tabBarController = tabBarController

    }
    func start(){
        let mainMapViewModel = MainMapViewModel(coordinator: self)
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel)
        
        mainMapViewModel.cameraCoordinateObservable = cameraCoordinateSubject.asObservable()

        //MainMapVC
        self.navigationController.pushViewController(mainMapViewController, animated: true)

    }

    ///SearchPlacesMapCoordinator 시작하는 메소드
    func showSearchPlacesMap(){
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController, delegate: self)
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
}

extension DefaultMainMapCoordinator : SearchPlacesMapCoordDelegate{
    //SearchPlacesCoordinator에서 좌표 받는 함수
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D) {
        cameraCoordinateSubject.onNext(coordinate)
    }
    
}
