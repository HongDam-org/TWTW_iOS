//
//  BaseTabCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/11.
//

import Foundation
import UIKit

protocol TabBarCoordinator: Coordinator {
    var tabBarController: UITabBarController { get set }
}
