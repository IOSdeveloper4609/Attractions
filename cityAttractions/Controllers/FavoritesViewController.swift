//
//  FavoritesViewController.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 15.06.2021.
//

import UIKit
import RealmSwift
import MapKit

final class FavoritesViewController: UIViewController {
    private var favoritesArray = [DescriptionPlace]()
    private var databaseManager: DatabaseManager {
        return DatabaseManager.shared
    }
    private var networkManager: NetworkManager {
        return NetworkManager()
    }
    var model: DescriptionPlace?
    
    private lazy var mainTableView: UITableView = {
        var tv = UITableView()
        tv.rowHeight = 160
        tv.register(FavoritesCell.self, forCellReuseIdentifier: FavoritesCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Private -
private extension FavoritesViewController {
    func setupUI() {
        navigationItem.title = "Избранное"
        setupMainTableView()
        fetchData()
    }
    
    func setupMainTableView() {
        view.addSubview(mainTableView)
        
        NSLayoutConstraint.activate([
            mainTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchData() {
        guard let objects = databaseManager.safeRealm?.objects(ShowPlaceObject.self) else {
            return
        }
        let ids = objects.map({ $0.id })
        for id in ids {
            networkManager.getDetailedDataPlaces(by: id) { [weak self] results in
                guard let result = results else {
                    return
                }
                self?.favoritesArray.append(result)
                DispatchQueue.main.async {
                    self?.mainTableView.reloadData()
                }
            }
        }
    }
    
    func openDetailedScreen(index: Int) {
        navigationController?.isHeroEnabled = true
        let detailViewController = DetailedViewController()
        detailViewController.model = favoritesArray[safe: index]
        detailViewController.heroModalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate -
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FavoritesCell {
            cell.avatarPlaceImageView.heroID = favoritesArray[safe: indexPath.row]?.xid
            openDetailedScreen(index: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource -
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.identifier, for: indexPath) as? FavoritesCell, let modelPlace = favoritesArray[safe: indexPath.row] else {
            assertionFailure("this cell is missing")
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setupCell(with: modelPlace)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let id = self.favoritesArray[indexPath.row].xid
            self.favoritesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManager.shared.remove(id: id)
        }
    }
}

// MARK: - ShareDataDelegate -
 extension FavoritesViewController: ShareDataDelegate {
    func shareDataButton(cell: FavoritesCell) {
        guard let indexPath = self.mainTableView.indexPath(for: cell),
              let result = favoritesArray[safe: indexPath.row]?.otm else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [result] , applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func sharingLocation(name: String?) {
        guard let latitude = model?.point.lat,
              let longitude = model?.point.lon else {
            return
        }

        let regionDistance: CLLocationDistance = 200
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
    
    func shareLocationButton(cell: FavoritesCell) {
        let alertController = UIAlertController(title: "Построение маршрута", message: "Построить маршрут в картах?", preferredStyle: .alert)
        
        let buildRouting = UIAlertAction(title: "построить", style: .default) { _ in
            self.sharingLocation(name: self.model?.name)
        }
        
        let cancelAction = UIAlertAction(title: "отмена", style: .default)
        alertController.addAction(cancelAction)
        alertController.addAction(buildRouting)
        self.present(alertController, animated: true, completion: nil)
    }
}


        
        
        
