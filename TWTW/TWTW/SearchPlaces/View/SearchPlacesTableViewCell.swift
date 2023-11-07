//
//  SearchPlacesTableViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import UIKit

///mark: - 서치테이블 정보talbeViewCell
final class SearchPlacesTableViewCell: UITableViewCell {
    
    ///mark: - 장소이름과 주소
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    ///mark: -주소명
    private let addressNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    ///mark: -카테고리명
    private let categoryNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Mark: - addSubViews()
    private func addSubViews(){
        contentView.addSubview(placeNameLabel)
        contentView.addSubview(addressNameLabel)
        contentView.addSubview(categoryNameLabel)
        
        configureConstraints()
    }
    
    ///Mark: - addSubViews()
    private func configureConstraints(){
        placeNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(8)
        }
        addressNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(placeNameLabel.snp.bottom).offset(6)
        }
        categoryNameLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.top.equalTo(addressNameLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    func configure(placeName: String, addressName: String, categoryName: String) {
        placeNameLabel.text = placeName
        addressNameLabel.text = addressName
        categoryNameLabel.text = categoryName
    }
}
