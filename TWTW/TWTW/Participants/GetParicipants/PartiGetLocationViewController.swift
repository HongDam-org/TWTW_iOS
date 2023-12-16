//
//  PartiGetLocationViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxCocoa
import RxSwift
import UIKit

final class PartiGetLocationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: PartiGetLocationViewModel
    
 
    // MARK: - Init
    init(viewModel: PartiGetLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
