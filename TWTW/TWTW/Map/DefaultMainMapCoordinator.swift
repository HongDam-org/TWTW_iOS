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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToParticipantsList(_:)),
                                               name: NSNotification.Name("moveToParticipantsList"), object: nil)
    }
    
    // MARK: - Fuctions
    
    func start() {
        guard let mainMapViewModel = mainMapViewModel else { return }
        navigationController.tabBarController?.tabBar.isHidden = true
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
        let participantsCoordinator = DefaultsParticipantsCoordinator(navigationController: navigationController)
        participantsCoordinator.start()
        childCoordinators.append(participantsCoordinator)
    }
    /// 알림 화면으로 이동
    func moveToPlans() {
        let plansCoordinator = DefaultPlansCoordinator(navigationController: navigationController)
        plansCoordinator.start()
        childCoordinators.append(plansCoordinator)
    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func moveToParticipantsList(_ notification: Notification) {
        print("show moveToParticipantsList🪡")
        moveToParticipantsList()
    }
}

// MARK: - SearchPlacesCoordinator에서 좌표 받는 함수

extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate {
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D, placeName: String, roadAddressName: String) {
        navigationController.popViewController(animated: true)
        mainMapViewModelOutput?.cameraCoordinateObservable.accept(coordinate)

        if let mainMapVC = navigationController.viewControllers.last as? MainMapViewController {
            mainMapVC.updateViewState(to: .searchMap, placeName: placeName, roadAddressName: roadAddressName)
        }
    }
}


