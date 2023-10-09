//
//  DefaultSignUpCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

final class DefaultSignUpCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    
    init( navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        
    }
    
    
}
