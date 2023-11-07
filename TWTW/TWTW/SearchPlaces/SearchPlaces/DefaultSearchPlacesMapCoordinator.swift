//
//  DefaultSearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import Foundation
import UIKit
import RxSwift

class DefaultSearchPlacesMapCoordinator: SearchPlacesMapCoordinatorProtocol {
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
        searchPlacesMapViewModel = SearchPlacesMapViewModel(coordinator: self, searchPlacesServices: SearchPlacesMapService())
        searchPlacesMapViewController = SearchPlacesMapViewController()
        searchPlacesMapViewController?.viewModel = searchPlacesMapViewModel
        
        // 좌표를 delegate를 통해서 전달
        searchPlacesMapViewModel?.selectedCoordinate
            .subscribe(onNext: { [weak self] coordinate in
                // 좌표를 MainMapCoordinator로 전달
                self?.delegate?.didSelectCoordinate(coordinate: coordinate)
                // 좌표 전달 후 화면 닫기
                self?.finishSearchPlaces()
            })
            .disposed(by: disposeBag)
        
        if let searchPlacesMapViewController = searchPlacesMapViewController {
            navigationController.pushViewController(searchPlacesMapViewController, animated: true)
        }
    }
    
    func finishSearchPlaces() {
        navigationController.popViewController(animated: true)
    }
}
