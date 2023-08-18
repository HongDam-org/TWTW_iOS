//
//  BottomSheetViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/13.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BottomSheetViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var viewModel: BottomSheetViewModel!
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    weak var delegate: BottomSheetDelegate?
    
    convenience init(viewModel: BottomSheetViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
    }
    
    private func addSubViews() {
        view.addSubview(bottomSheetView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(panGesture)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            viewModel.heightConstraintRelay.accept(make.height.equalTo(viewModel.minHeight).constraint)
        }
    }
    
    @objc
    private func handlePan(_ panGesture: UIPanGestureRecognizer){
        viewModel.handlePan(gesture: panGesture, view: view)
            .subscribe(onNext: { [weak self] targetHeight in
                guard let self = self else { return }
                self.delegate?.didUpdateBottomSheetHeight(targetHeight)
                UIView.animate(withDuration: 0.3) {
                    self.viewModel.heightConstraintRelay.accept(self.viewModel.heightConstraintRelay.value?.update(offset: targetHeight))
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}

protocol BottomSheetDelegate: AnyObject {
    func didUpdateBottomSheetHeight(_ height: CGFloat)
}
