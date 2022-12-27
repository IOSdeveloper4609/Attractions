//
//  DetailedViewController.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 31.05.2021.
//

import UIKit
import Hero
import SDWebImage
import MapKit

final class DetailedViewController: UIViewController {
    var model: DescriptionPlace?
    
    private lazy var shareDataButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "share"), for: .normal)
        b.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(sharingData), for: .touchUpInside)
        
        return b
    }()
    
    private lazy var shareLocationDataButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "route"), for: .normal)
        b.contentMode = .scaleToFill
        b.addTarget(self, action: #selector(performSharingLocation), for: .touchUpInside)
        
        return b
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    private lazy var placeDescriptionLabel: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.numberOfLines = 0
        l.font = UIFont(name: "Copperplate", size: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Private -
private extension DetailedViewController {
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Описание"
        setupPlaceData()
        setupAvatarImageView()
        setupPlaceDescriptionLabel()
        setupShareButton()
        setupLocationButton()
    }
    
    func setupPlaceDescriptionLabel() {
        view.addSubview(placeDescriptionLabel)
        
        view.addConstraints([
            placeDescriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 30),
            placeDescriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            placeDescriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }
    
    func setupAvatarImageView() {
        view.addSubview(avatarImageView)
        
        view.addConstraints([
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 155),
            avatarImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            avatarImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            avatarImageView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func setupShareButton() {
        view.addSubview(shareDataButton)
        
        view.addConstraints([
            shareDataButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 110),
            shareDataButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            shareDataButton.heightAnchor.constraint(equalToConstant: 23),
            shareDataButton.widthAnchor.constraint(equalToConstant: 23)
        ])
    }
    
    func setupLocationButton() {
        view.addSubview(shareLocationDataButton)
        
        view.addConstraints([
            shareLocationDataButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 107),
            shareLocationDataButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            shareLocationDataButton.heightAnchor.constraint(equalToConstant: 30),
            shareLocationDataButton.widthAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    func setupPlaceData() {
        let idPlace = model?.xid
        let avatarPlace = model?.preview?.source
        avatarImageView.heroID = idPlace
        avatarImageView.sd_setImage(with: avatarPlace, completed: nil)
        placeDescriptionLabel.text = model?.wikipediaExtracts?.text
    }
    
    func sharingLocation(name: String?) {
        guard let latitude = model?.point.lat,
              let longitude = model?.point.lon else {
            return
        }
        
        let regionDistance: CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]
        
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
}

// MARK: - Actions -
private extension DetailedViewController {
    @objc func performSharingLocation() {
        let alertController = UIAlertController(title: "Построение маршрута", message: "Построить маршрут в картах?", preferredStyle: .alert)
        
        let buildRouting = UIAlertAction(title: "построить", style: .default) { _ in
            self.sharingLocation(name: self.model?.name)
            
        }
        let cancelAction = UIAlertAction(title: "отмена", style: .default)
        alertController.addAction(cancelAction)
        alertController.addAction(buildRouting)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func sharingData() {
        guard let result = model?.otm else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [result], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
