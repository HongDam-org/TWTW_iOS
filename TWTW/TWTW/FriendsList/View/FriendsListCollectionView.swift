//
//  FriendsListCollectionView.swift
//  TWTW
//
//  Created by 박다미 on 2023/09/11.
//

import Foundation
import SnapKit
import UIKit

final class FriendsListColletionViewCell: UICollectionViewCell {
    /// 사진
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    /// 이름
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// addSubviews
    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        configureConstraints()
    }
    
    /// Configure Constraints UI
    private func configureConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(3)
            make.height.equalTo(imageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
    }
}
