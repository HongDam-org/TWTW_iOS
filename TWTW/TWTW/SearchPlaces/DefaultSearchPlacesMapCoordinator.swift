//
//  DefaultSearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import CoreLocation
import Foundation
import RxSwift
import UIKit

/// SearchPlacesMap 관리하는 Coordinator
final class DefaultSearchPlacesMapCoordinator: SearchPlacesMapCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: SearchPlacesMapCoordDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self,
                                                            searchPlacesServices: SearchPlacesMapService(),
                                                            surroundSearchServices: SurroundSearchService())
        let searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController.viewModel = searchPlacesMapViewModel
        
        navigationController.pushViewController(searchPlacesMapViewController, animated: true)
    }
    
    /// 출발지 지정으로 들어가기
    func moveToStartSearchPlace() {
        let searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self,
                                                            searchPlacesServices: SearchPlacesMapService(),
                                                            surroundSearchServices: SurroundSearchService(),
                                                            caller: .forStartCaller)
        let searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController.viewModel = searchPlacesMapViewModel

        navigationController.pushViewController(searchPlacesMapViewController, animated: true)
    }
    
    /// 그룹 멤버 위치 변경
    func moveByGroupMemberList() {
        let searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self,
                                                            searchPlacesServices: SearchPlacesMapService(),
                                                            surroundSearchServices: SurroundSearchService(),
                                                            caller: .groupMemberList)
        let searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController.viewModel = searchPlacesMapViewModel

        navigationController.pushViewController(searchPlacesMapViewController, animated: true)
    }
    
    /// 서치 완료후 :  cLLocation전달 & pop VC
    func finishSearchPlaces(searchPlace: SearchPlace?) {
        delegate?.didSelectPlace(searchPlace: searchPlace)
        navigationController.popViewController(animated: true)
    }
}
