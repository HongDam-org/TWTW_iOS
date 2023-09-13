//
//  NearbyPlacesCollectionViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/23.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
///NearbyPlacesCollectionViewCell- 목적지 근방 장소들 보여주기
class NearbyPlacesCollectionViewCell : UICollectionViewCell{
    
  /// NearbyPlacesCollectionViewCell.cellIdentifier
    static let cellIdentifier = "NearbyPlacesCollectionViewCell"
    
    /// 셀구성을 감싸는 view
    let view: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    /// 장소 사진
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// 장소 이름
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    /// 장소에 관한 간단할 설명
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Fuctions
    /// MARK: Add  UI
    private func addSubViews(){
        contentView.addSubview(view)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        
        configureConstraints()
    }
    
    /// MARK: Configure Constraints UI
    private func configureConstraints(){
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
            
        }
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.top.equalToSuperview().inset(4)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }
}
