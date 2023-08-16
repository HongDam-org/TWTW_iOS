//
//  MainMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import UIKit
import NMapsMap
import RxCocoa
import RxSwift
import SnapKit
import CoreLocation //위치정보

///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
    
    /// MARK: 지도 아랫부분 화면
    private lazy var bottomSheetViewController: BottomSheetViewController = {
        let viewModel = BottomSheetViewModel(viewHeight: self.view.frame.height)// 필요한 초기값으로 설정
        let view = BottomSheetViewController(viewModel: viewModel)
        view.delegate = self
        return view
    }()
    
    /// MARK: 네이버 지도
    private lazy var mapView: NMFMapView = {
        var view = NMFMapView()
        view.positionMode = .normal
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    private var tapGesture: UITapGestureRecognizer?
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        viewModel.setupLocationManager()
        addTapGesture()
        bind()
    }
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addBottomSheetSubViews()
    }
    
    // MARK: - Fuctions
    
    /// MARK: Add Gesture
    private func addTapGesture(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture ?? UITapGestureRecognizer())
    }
    
    /// MARK: Add BottomSheet UI
    private func addBottomSheetSubViews() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureBottomSheetConstraints()
    }
    
    /// MARK: Configure Constraints UI
    private func configureBottomSheetConstraints() {
        bottomSheetViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomSheetViewController.viewModel.minHeight)
        }
    }
    
    /// setupMapView()
    private func setupMapView() {
        mapView = NMFMapView(frame: view.frame)
        mapView.positionMode = .normal
        view.addSubview(mapView)
    }
    
    /// MARK: viewModel binding
    private func bind(){
        
        viewModel.checkTouchEventRelay
            .bind { [weak self] check in
                if check {  // 화면 터치시 주변 UI 숨기기
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.bottomSheetViewController.view.alpha = 0
                    }) { (completed) in
                        if completed {
                            self?.bottomSheetViewController.view.isHidden = true
                        }
                    }
                }
                else{
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.bottomSheetViewController.view.alpha = 1
                    }) { (completed) in
                        if completed {
                            self?.bottomSheetViewController.view.isHidden = false
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// MARK: 터치 이벤트 실행
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        viewModel.checkingTouchEvents()
    }
}

// BottomSheetDelegate 프로토콜
extension MainMapViewController: BottomSheetDelegate {
    func didUpdateBottomSheetHeight(_ height: CGFloat) {
        bottomSheetViewController.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
