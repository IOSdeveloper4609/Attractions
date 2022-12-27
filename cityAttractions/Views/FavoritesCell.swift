//
//  FavoritesCell.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 15.06.2021.
//

import UIKit
import SDWebImage

protocol ShareDataDelegate {
    func shareDataButton(cell: FavoritesCell)
    func shareLocationButton(cell: FavoritesCell)
}

final class FavoritesCell: BaseCell {
    var delegate: ShareDataDelegate?
    
    private lazy var shareDataButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "sharing"), for: .normal)
        b.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(sharingData), for: .touchUpInside)
        
        return b
    }()
    
    private lazy var shareLocationDataButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "route"), for: .normal)
        b.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(sharingLocation), for: .touchUpInside)
        
        return b
    }()
    
    private lazy var namePlaceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(named: "systemBlack")
        l.font = .boldSystemFont(ofSize: 16)
        l.numberOfLines = 2
        
        return l
    }()
    
    private lazy var districtPlaceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .systemBlue
        l.font = .boldSystemFont(ofSize: 15)
        l.numberOfLines = 0
        
        return l
    }()
    
    private lazy var typePlaceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(named: "systemBlack")
        l.font = .boldSystemFont(ofSize: 16)
        l.numberOfLines = 0
        
        return l
    }()
    
    private lazy var descriptionPlaceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(named: "systemBlack")
        l.font = .boldSystemFont(ofSize: 13)
        l.numberOfLines = 3
        
        return l
    }()
    
    lazy var avatarPlaceImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = (frame.height * 0.72) / 2
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods -
    func setupCell(with model: DescriptionPlace) {
        switch SettingManager.shared.visibleType {
        case .name:
            namePlaceLabel.text = model.name
        case .coordinates:
            namePlaceLabel.text = "\(model.point.lat)  \(model.point.lon)"
        default:
            break
        }
        descriptionPlaceLabel.text = model.wikipediaExtracts?.text
        districtPlaceLabel.text = model.address.county
        avatarPlaceImageView.sd_setImage(with: model.preview?.source, completed: nil)
        let kind = PlaceType(kinds: model.kinds)
        typePlaceLabel.text = kind.rawValue
    }
}

// MARK: - Private -
private extension FavoritesCell {
    func setupUI() {
        setupAvatarImageView()
        setupNamePlaceLabel()
        setupDescriptionLabel()
        setupDistrictPlaceLabel()
        setupTypePlaceLabel()
        setupLocationButton()
        setupShareButton()
    }
    
    func setupNamePlaceLabel() {
        contentView.addSubview(namePlaceLabel)
        
        contentView.addConstraints([
            namePlaceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            namePlaceLabel.leftAnchor.constraint(equalTo: avatarPlaceImageView.rightAnchor, constant: 13),
            namePlaceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarPlaceImageView)
        
        contentView.addConstraints([
            avatarPlaceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            avatarPlaceImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 7),
            avatarPlaceImageView.heightAnchor.constraint(equalToConstant: 110),
            avatarPlaceImageView.widthAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    func setupDescriptionLabel() {
        contentView.addSubview(descriptionPlaceLabel)
        
        contentView.addConstraints([
            descriptionPlaceLabel.topAnchor.constraint(equalTo: namePlaceLabel.bottomAnchor, constant: 10),
            descriptionPlaceLabel.leftAnchor.constraint(equalTo: avatarPlaceImageView.rightAnchor, constant: 10),
            descriptionPlaceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
    }
    
    func setupDistrictPlaceLabel() {
        contentView.addSubview(districtPlaceLabel)
        
        contentView.addConstraints([
            districtPlaceLabel.topAnchor.constraint(equalTo: descriptionPlaceLabel.bottomAnchor, constant: 8),
            districtPlaceLabel.leftAnchor.constraint(equalTo: avatarPlaceImageView.rightAnchor, constant: 10),
        ])
    }
    
    func setupTypePlaceLabel() {
        contentView.addSubview(typePlaceLabel)
        
        contentView.addConstraints([
            typePlaceLabel.leftAnchor.constraint(equalTo: avatarPlaceImageView.rightAnchor, constant: 10 ),
            typePlaceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -150),
            typePlaceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func setupLocationButton() {
        contentView.addSubview(shareLocationDataButton)
        
        contentView.addConstraints([
            shareLocationDataButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            shareLocationDataButton.heightAnchor.constraint(equalToConstant: 30),
            shareLocationDataButton.widthAnchor.constraint(equalToConstant: 30),
            shareLocationDataButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
    
    func setupShareButton() {
        contentView.addSubview(shareDataButton)
        
        contentView.addConstraints([
            shareDataButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            shareDataButton.heightAnchor.constraint(equalToConstant: 23),
            shareDataButton.widthAnchor.constraint(equalToConstant: 23),
            shareDataButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }
    
    @objc func sharingData() {
        delegate?.shareDataButton(cell: self)
    }
    
    @objc func sharingLocation() {
        delegate?.shareLocationButton(cell: self)
    }
}


