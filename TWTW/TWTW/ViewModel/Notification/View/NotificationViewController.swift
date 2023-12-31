//
//  NotificationViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit

// 알림
final class NotificationViewController: UIViewController {
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        setNavi()
    }
    /// 네비게이션 item보이기
    private func setNavi() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
