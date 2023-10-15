//
//  SearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import RxSwift

class SearchPlacesMapCoordinator: Coordinator {
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: MainMapCoordinator?
    
    init(navigationController: UINavigationController, parentCoordinator: MainMapCoordinator){
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        let searchPlacesMapViewModel = SearchPlacesMapViewModel()
        let searchPlaceMapViewController = SearchPlacesMapViewController(viewModel: searchPlacesMapViewModel)
        
        ///searchPlacesMapViewModel 구독
        searchPlacesMapViewModel.selectedCoordinateSubject
                  .subscribe(onNext: { [weak self] coordinate in
                      // 좌표를 MainMapCoordinator로 전달
                      self?.parentCoordinator?.selectedCoordinate(coordinate)
                      // 좌표 전달 후 화면 닫기
                      self?.finishSearchPlaces()
                  })
                  .disposed(by: searchPlaceMapViewController.disposeBag)
        
        navigationController.pushViewController(searchPlaceMapViewController, animated: true)
    }
    func finishSearchPlaces(){
        navigationController.popViewController(animated: true)
    }

    
}
