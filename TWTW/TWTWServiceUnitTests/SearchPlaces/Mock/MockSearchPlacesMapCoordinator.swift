//
//  MockSearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/23.
//

import Foundation
import UIKit
import CoreLocation

final class MockSearchPlacesMapCoordinator: SearchPlacesMapCoordinatorProtocol {
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var finishSearchPlacesCalled = false

    init(childCoordinators: [Coordinator], navigationController: UINavigationController) {
        self.childCoordinators = childCoordinators
        self.navigationController = navigationController
    }

    func finishSearchPlaces(coordinate coordinator: CLLocationCoordinate2D) {
        finishSearchPlacesCalled = true
        print("Mock \(#function)")
    }

    func start() {
        print("Mock \(#function)")
    }
}
