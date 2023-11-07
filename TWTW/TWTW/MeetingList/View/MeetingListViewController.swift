//
//  ViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import UIKit
import RxSwift
import RxCocoa

/// MARK: 모임 리스트
final class MeetingListViewController: UIViewController {
    var viewModel: MeetingListViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: MeetingListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //테이블뷰를 넣어서 특정 약속을 통해 맵으로 이동할 예정
        view.backgroundColor = .white
        
        //임시 버튼 생성...
        let button = UIButton(type: .system)
        button.setTitle("Meeing생성후 맵이동버튼", for: .normal)
     
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        view.addSubview(button)
        
        button.rx.tap
            .bind{[weak self] in
                self?.viewModel.buttonTapped()
            }.disposed(by: disposeBag)
    }
  
 
}
