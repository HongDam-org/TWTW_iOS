//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/21/23.
//

import Foundation
import UIKit

protocol FriendsListCoordinator: Coordinator {
    /// Create Controller
    /// - Returns: NavigationController
    func startPush() -> UINavigationController
}
