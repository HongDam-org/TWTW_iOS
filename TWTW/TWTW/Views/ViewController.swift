//
//  ViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //테이블뷰를 넣어서 특정 약속을 통해 맵으로 이동할 예정
        view.backgroundColor = .white
        
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           
           let viewController = MainMapViewController()
           viewController.modalPresentationStyle = .fullScreen
           present(viewController, animated: true, completion: nil)
       }


}

