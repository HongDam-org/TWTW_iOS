//
//  PartiMeetingViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/17.
//

import Foundation
import UIKit

class PartiMeetingViewController: UIViewController {
    var newPlace: UILabel!
    var addParticipantsButton: UIButton!
    var confirmButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // 공통 뷰 구성 요소 초기화
        newPlace = UILabel()
        addParticipantsButton = UIButton()
        confirmButton = UIButton()
        view.backgroundColor = .red
    }
    
    func setupCommonViews() {
        // newPlace, addParticipantsButton, confirmButton 설정
    }
    
    func setupCommonBindings() {
        // 공통 ViewModel 바인딩 코드 작성
    }
}
