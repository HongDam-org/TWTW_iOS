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
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel, 
                                                          tabbarController: TabBarController())
        self.navigationController.pushViewController(mainMapViewController, animated: true)
    }
    
    /// MARK: SearchPlacesMapCoordinator 시작하는 메소드
    func moveSearch(output: MainMapViewModel.Output){
        mainMapViewModelOutput = output
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController, delegate: self)
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
}

// MARK: - SearchPlacesCoordinator에서 좌표 받는 함수
extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate{
    
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D) {
        mainMapViewModelOutput?.showNearPlacesUI.accept(true)
        mainMapViewModelOutput?.cameraCoordinateObservable.accept(coordinate)
    }
}
