//
//  TabBarItemsCollectionViewCell.swift
//  TWTW
//
//  Created by 정호진 on 10/20/23.
//

import Foundation
import UIKit

/// Tabbar CollectionView Cell
final class TabBarItemsCollectionViewCell: UICollectionViewCell {
    static let identfier = "TabBarItemsCollectionViewCell"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// MARK: Add  UI
    private func addSubViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        configureConstraints()
    }
    
    /// MARK: Configure Constraints UI
    private func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    /// MARK: Input Data
    func inputData(item: TabItem) {
        imageView.image = UIImage(systemName: item.imageName)?.resize(newWidth: 25, newHeight: 25)
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        titleLabel.text = item.title
    }
    
    func selectedCell() {
        
    }
    
}
