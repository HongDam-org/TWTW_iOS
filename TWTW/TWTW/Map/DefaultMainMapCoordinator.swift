//
//  DefaultMainMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import CoreLocation
import Foundation
import RxSwift
import UIKit

/// MainMap 관리하는 Coordinator
final class DefaultMainMapCoordinator: MainMapCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var mainMapViewModel: MainMapViewModel?
    private var mainMapViewModelOutput: MainMapViewModel.Output?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        mainMapViewModel = MainMapViewModel(coordinator: self, routeService: RouteService())
        
    }
    
    // MARK: - Fuctions

    func start() {
        guard let mainMapViewModel = mainMapViewModel else { return }
        
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel, coordinator: self)
        self.navigationController.pushViewController(mainMapViewController, animated: true)
    }
    
    /// SearchPlacesMapCoordinator 시작하는 메소드
    func moveSearch(output: MainMapViewModel.Output) {
        mainMapViewModelOutput = output
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController,
                                                                           delegate: self)
        _ = KeychainWrapper.saveItem(value: "\(output.myLocatiaonRelay.value.latitude)", forKey: "latitude")
        _ = KeychainWrapper.saveItem(value: "\(output.myLocatiaonRelay.value.longitude)", forKey: "longitude")
        searchPlacesMapCoordinator.start()
        childCoordinators.append(searchPlacesMapCoordinator)
    }
    ///  친구 목록 화면으로 이동
    func moveToParticipantsList() {
        let friendsListCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)
              friendsListCoordinator.start()
              childCoordinators.append(friendsListCoordinator)
      }
    /// 알림 화면으로 이동
    func moveToNotifications() {
        let notificationCoordinator = DefaultNotificationCoordinator(navigationController: navigationController)
        notificationCoordinator.start()
        childCoordinators.append(notificationCoordinator)
       }
  
}
// MARK: - SearchPlacesCoordinator에서 좌표 받는 함수
extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate {
    
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D, searchPlaceList: [PlaceInformation]) {
        mainMapViewModelOutput?.cameraCoordinateObservable.accept(coordinate)
        mainMapViewModelOutput?.nearByplaceRelay.accept(searchPlaceList)
        _ = childCoordinators.popLast()
        print(#function)
        print(childCoordinators)
    }
}
