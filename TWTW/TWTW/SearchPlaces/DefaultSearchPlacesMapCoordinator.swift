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
    
    init(navigationController: UINavigationController, delegate: SearchPlacesMapCoordDelegate){
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        let searchPlacesMapViewModel = SearchPlacesMapViewModel()
        let searchPlaceMapViewController = SearchPlacesMapViewController(viewModel: searchPlacesMapViewModel)
        
        //좌표를 delegate를 통해서 전달
        searchPlacesMapViewModel.selectedCoordinateSubject
                  .subscribe(onNext: { [weak self] coordinate in
                      // 좌표를 MainMapCoordinator로 전달
                      self?.delegate?.didSelectCoordinate(coordinate: coordinate)
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
