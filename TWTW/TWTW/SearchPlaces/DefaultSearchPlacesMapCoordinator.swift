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
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
   // weak var delegate: SearchPlacesMapCoordDelegate?
    
    private var searchPlacesMapViewController: SearchPlacesMapViewController?
    private var searchPlacesMapViewModel: SearchPlacesMapViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    
    }
    
    func start() {
        searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self,
                                                            searchPlacesServices: SearchPlacesMapService(),
                                                            surroundSearchServices: SurroundSearchService())
        searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController?.viewModel = searchPlacesMapViewModel
        
        if let searchPlacesMapViewController = searchPlacesMapViewController {
            navigationController.pushViewController(searchPlacesMapViewController, animated: true)
        }
    }
    /// 출발지 지정으로 들어가기
    func moveToStartSearchPlace() {
        searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self,
                                                            searchPlacesServices: SearchPlacesMapService(),
                                                            surroundSearchServices: SurroundSearchService(),
                                                            caller: .forStartCaller)
        searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController?.viewModel = searchPlacesMapViewModel

        if let searchPlacesMapViewController = searchPlacesMapViewController {
            navigationController.pushViewController(searchPlacesMapViewController, animated: true)
        }
    }
    /// 서치 완료후 :  cLLocation전달 & pop VC
    func finishSearchPlaces() {
        NotificationCenter.default.post(name: .didFinishSearchPlaces, object: nil)
        navigationController.popViewController(animated: true)
    }
}
