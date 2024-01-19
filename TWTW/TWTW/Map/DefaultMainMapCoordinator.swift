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
        mainMapViewModel = MainMapViewModel(coordinator: self, service: MainMapService())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showPlanPage(_:)),
                                               name: NSNotification.Name("moveToPlans"), object: nil)
    }
    
    // MARK: - Fuctions
    
    func start() {
        guard let mainMapViewModel = mainMapViewModel else { return }
        navigationController.tabBarController?.tabBar.isHidden = true
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel, coordinator: self)
        navigationController.delegate = mainMapViewController
        self.navigationController.pushViewController(mainMapViewController, animated: true)
    }
    
    /// SearchPlacesMapCoordinator 시작하는 메소드
    func moveSearch(output: MainMapViewModel.Output) {
        mainMapViewModelOutput = output
        let searchPlacesMapCoordinator = DefaultSearchPlacesMapCoordinator(navigationController: navigationController)
        _ = KeychainWrapper.saveItem(value: "\(output.myLocatiaonRelay.value.latitude)", forKey: "latitude")
        _ = KeychainWrapper.saveItem(value: "\(output.myLocatiaonRelay.value.longitude)", forKey: "longitude")
        searchPlacesMapCoordinator.start()
        searchPlacesMapCoordinator.delegate = self
        childCoordinators.append(searchPlacesMapCoordinator)
    }
    
    ///  친구 목록 화면으로 이동
    func moveToParticipantsList() {
        let participantsCoordinator = DefaultsParticipantsCoordinator(navigationController: navigationController)
        participantsCoordinator.start()
        childCoordinators.append(participantsCoordinator)
    }
    
    func moveToPlanFromAlert(from source: PlanCaller) {
        let plansCoordinator = DefaultPlansCoordinator(navigationController: navigationController)
        plansCoordinator.startFromAlert()
        childCoordinators.append(plansCoordinator)
    }
    
    /// 알림 화면으로 이동
    func moveToPlans() {
        let plansCoordinator = DefaultPlansCoordinator(navigationController: navigationController)
        plansCoordinator.start()
        childCoordinators.append(plansCoordinator)
    }

    func startWithNaviInit() {
        guard let mainMapViewModel = mainMapViewModel else { return }
        let mainMapViewController = MainMapViewController(viewModel: mainMapViewModel, coordinator: self)
        self.navigationController.pushViewController(mainMapViewController, animated: true)
        print(navigationController.viewControllers)
        navigationController.setViewControllers([mainMapViewController], animated: true)
    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func showPlanPage(_ notification: Notification) {
        print("show moveToPlans🪡")
        moveToPlans()
        // TODO: 목적지 변경시 이동하는 코드
        // 약속장소 화면으로 이동하는 Notification 등록해야함
        // DefaultPlansCoordinator에서 Notification 등록해야함
        NotificationCenter.default.post(name: Notification.Name("moveTo약속장소"), object: nil)
    }

}

extension DefaultMainMapCoordinator: SearchPlacesMapCoordDelegate {
    func didSelectPlace(searchPlace: SearchPlace?) {
        mainMapViewModelOutput?.finishSearchCoordinator.onNext(true)
    }
}
