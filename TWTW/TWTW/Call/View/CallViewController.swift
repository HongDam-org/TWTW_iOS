//
//  CallViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import CallKit
import Foundation
import UIKit

// 통화하기
final class CallViewController: UIViewController {
    let cv = CXCallController()
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}


extension CallViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
}
