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
    weak var delegate: SearchPlacesMapCoordDelegate?
    
    private var searchPlacesMapViewController: SearchPlacesMapViewController?
    private var searchPlacesMapViewModel: SearchPlacesMapViewModel?
    
    init(navigationController: UINavigationController, delegate: SearchPlacesMapCoordDelegate) {
        self.navigationController = navigationController
        self.delegate = delegate
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
    
    /// 서치 완료후 :  cLLocation전달 & pop VC
    func finishSearchPlaces(coordinate: CLLocationCoordinate2D, placeName: String, roadAddressName: String) {
        delegate?.didSelectCoordinate(coordinate: coordinate, placeName: placeName, roadAddressName: roadAddressName)
        navigationController.popViewController(animated: true)
    }
}
