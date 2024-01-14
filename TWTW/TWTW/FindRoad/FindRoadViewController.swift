//
//  FindRoadViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FindRoadViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: FindRoadViewModel
    
    // MARK: - Init
    init(viewModel: FindRoadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
}
