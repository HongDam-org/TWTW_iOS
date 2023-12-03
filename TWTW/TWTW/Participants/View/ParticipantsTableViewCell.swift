//
//  ParticipantsTableViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import RxSwift
import SnapKit
import UIKit

final class ParticipantsTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    let participantImageView = UIImageView()
    let nameLabel = UILabel()

    var callBtnTapObservable: Observable<Void> {
        return callButton.rx.tap.asObservable()
    }
    
    var locationBtnTapObservable: Observable<Void> {
        return locationButton.rx.tap.asObservable()
    }
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    private lazy var callButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .black
        return btn
    }()
    private lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.tintColor = .black
        return btn
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// addSubViews()
    private func addSubViews() {
        contentView.addSubview(participantImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(callButton)
        buttonStackView.addArrangedSubview(locationButton)

        configureConstraints()
    }
    
    /// addSubViews()
    private func configureConstraints() {
        participantImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(participantImageView.snp.height)
            
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(participantImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(buttonStackView.snp.height).multipliedBy(2)
        }
        callButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(callButton.snp.height)
        }
        
        locationButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(callButton.snp.height)
        }
    }
    
    /// configure
    func configure(participant: Participant) {
            self.participantImageView.image = participant.participantsimage
            self.nameLabel.text = participant.name
            self.callButton.setImage(participant.callImage, for: .normal)
            self.locationButton.setImage(participant.locationImage, for: .normal)
        }
}
