//
//  SearchPlacesTableViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import UIKit

/// 서치테이블 정보talbeViewCell
final class SearchPlacesTableViewCell: UITableViewCell {
    
    // MARK: - UI Property

    /// 장소이름과 주소
    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    /// 주소명
    private lazy var addressNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// addSubViews()
    private func addSubViews() {
        contentView.addSubview(placeNameLabel)
        contentView.addSubview(addressNameLabel)
        configureConstraints()
    }
    
    /// addSubViews()
    private func configureConstraints() {
        placeNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(8)
        }
        addressNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(placeNameLabel.snp.bottom).offset(6)
        }
    }
    
    /// configure
    func configure(placeName: String, addressName: String) {
        placeNameLabel.text = placeName
        addressNameLabel.text = addressName
    }
}
