//
//  PartiSetLocationViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxCocoa
import RxSwift
import UIKit

final class PartiSetLocationViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var viewModel: PartiSetLocationViewModel
    
 
    // MARK: - Init
    init(viewModel: PartiSetLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PartiSetLocationViewController")
        view.backgroundColor = .orange
    }
}
