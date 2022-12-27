//
//  ShowPlaceCell.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import UIKit
import SDWebImage
import Hero

protocol AddToFavoritesDelegate {
    func addToFavoritesButton(cell: ShowPlaceCell)
}

final class ShowPlaceCell: BaseCell {
    var delegate: AddToFavoritesDelegate?
    private var model: DescriptionPlace?
    
    private var settingManager: SettingManager {
        return SettingManager.shared
    }
    private var databaseManager: DatabaseManager {
        return DatabaseManager.shared
    }
    
    private lazy var favoriteButton: UIButton = {
        let b = UIButton()
        b.setTitleColor(UIColor(named: "systemBlack"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        
        return b
    }()
    
    // MARK: - Private Properties -
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
    
    private lazy var avatarPlaceImageView: UIImageView = {
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
        switch settingManager.visibleType {
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
        
        if databaseManager.containsID(id: model.xid) {
            favoriteButton.setImage(#imageLiteral(resourceName: "redHeart"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        }
    }
    
    func setupAnimationAvatar(param: String) {
        avatarPlaceImageView.heroID = param
    }
    
    func setupFavoriteButton(sender: UIImage) {
        favoriteButton.setImage(sender, for: .normal)
    }
}

// MARK: - Private -
private extension ShowPlaceCell {
    func setupUI() {
        setupAvatarImageView()
        setupNamePlaceLabel()
        setupDescriptionLabel()
        setupDistrictPlaceLabel()
        setupTypePlaceLabel()
        setupFavoriteButton()
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
            typePlaceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            typePlaceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func setupFavoriteButton() {
        contentView.addSubview(favoriteButton)
        
        contentView.addConstraints([
            favoriteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            favoriteButton.heightAnchor.constraint(equalToConstant: 23),
            favoriteButton.widthAnchor.constraint(equalToConstant: 23),
            favoriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
    
    @objc func addToFavorites() {
        delegate?.addToFavoritesButton(cell: self)
    }
}


