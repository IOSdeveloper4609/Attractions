//
//  ShowPlaceViewController.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import UIKit
import Hero

final class ShowPlaceViewController: UIViewController {
    private var ids = [String]()
    private var networkManager: NetworkManager {
        return NetworkManager()
    }
    private var databaseManager: DatabaseManager {
        return DatabaseManager.shared
    }
    private var detailedDataPlaces = [DescriptionPlace]()
    private var filteredPlaceChoice = [DescriptionPlace]()
    private var placeChoice = PlaceChoiceModel()
    private var isLoading = false
    
    private lazy var mainTableView: UITableView = {
        var tv = UITableView()
        tv.rowHeight = 160
        tv.register(ShowPlaceCell.self, forCellReuseIdentifier: ShowPlaceCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        
        return tv
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .red
        
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainTableView.reloadData()
    }
}

// MARK: - Private -
private extension ShowPlaceViewController {
    func setupUI() {
        navigationItem.title = "Достопримечательности"
        view.backgroundColor = .white
        setupMainTableView()
        fetchPlacesData()
        setupActivityIndicator()
        startActivityIndicator()
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
    
    func setupActivityIndicator() {
        mainTableView.addSubview(activityIndicator)
        
        view.addConstraints([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func addBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(openSettingsScreen))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "love"), style: .done, target: self, action: #selector(openFavoritesScreen))
    }
    
    func sortedPlaceChoiceData() {
        if placeChoice.kind != nil {
            
            detailedDataPlaces = filteredPlaceChoice.filter { PlaceType(kinds: $0.kinds) == placeChoice.kind || placeChoice.allKinds != nil }
            mainTableView.reloadData()
        } 
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func getShowPlaceWithPagination() {
        if isLoading {
            return
        }
        isLoading = true
        let group = DispatchGroup()
        
        let minCount = min(ids.count, 5)
        let ids = Array(self.ids[..<minCount])
        self.ids.removeFirst(minCount)
        var places = [DescriptionPlace]()
        print(ids)
        for id in ids {
            group.enter()
            networkManager.getDetailedDataPlaces(by: id) { results in
                if let result = results  {
                    places.append(result)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.detailedDataPlaces.append(contentsOf: places)
            self.filteredPlaceChoice.append(contentsOf: places)
            self.mainTableView.reloadData()
            self.mainTableView.tableFooterView = self.hideSpinnerFooter()
            self.stopActivityIndicator()
            self.isLoading = false
        }
    }
    
    func fetchDetailedDataPlaces(by id: String) {
        networkManager.getDetailedDataPlaces(by: id) { [weak self] results in
            guard let result = results else {
                return
            }
            self?.detailedDataPlaces.append(result)
            self?.filteredPlaceChoice.append(result)
        }
    }
    
    func fetchPlacesData() {
        networkManager.getIdShowPlaces { [weak self] results in
            self?.ids = results?.arrayId.compactMap({ $0.xid }) ?? []
            self?.getShowPlaceWithPagination()
            DispatchQueue.main.async {
                self?.mainTableView.reloadData()
            }
        }
    }
    
    func setupSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.backgroundColor = .black
        spinner.startAnimating()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        return footerView
    }
    
    func hideSpinnerFooter() -> UIView {
        let spinner = UIActivityIndicatorView()
        spinner.stopAnimating()
        return spinner
    }
    
    func openDetailedScreen(index: Int) {
        navigationController?.isHeroEnabled = true
        let detailViewController = DetailedViewController()
        detailViewController.model = detailedDataPlaces[safe: index]
        detailViewController.heroModalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - Actions -
extension ShowPlaceViewController {
    @objc func openFavoritesScreen() {
        let favoritesVC = FavoritesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    @objc func openSettingsScreen() {
        let settingsVC = SettingsViewController()
        let controllerNav = UINavigationController(rootViewController: settingsVC)
        settingsVC.delegate = self
        self.navigationController?.present(controllerNav, animated: true, completion: nil)
    }
}
 
// MARK: - UITableViewDataSource -
extension ShowPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedDataPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowPlaceCell.identifier, for: indexPath) as? ShowPlaceCell, let modelPlace = detailedDataPlaces[safe: indexPath.row] else {
            assertionFailure("this cell is missing")
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setupCell(with: modelPlace)
        return cell
    }
}

// MARK: - AddToFavoritesDelegate -
extension ShowPlaceViewController: AddToFavoritesDelegate {
    func addToFavoritesButton(cell: ShowPlaceCell) {
        guard let indexPath = self.mainTableView.indexPath(for: cell),
              let id = detailedDataPlaces[safe: indexPath.row]?.xid else {
            return
        }
        if !databaseManager.containsID(id: id) {
            cell.setupFavoriteButton(sender: #imageLiteral(resourceName: "redHeart"))
            databaseManager.add(id: id)
        } else {
            cell.setupFavoriteButton(sender: #imageLiteral(resourceName: "heart"))
            databaseManager.remove(id: id)
        }
    }
}

// MARK: - UIScrollViewDelegate -
extension ShowPlaceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !ids.isEmpty else {
            return
        }
        let position = scrollView.contentOffset.y
        if position > mainTableView.contentSize.height - scrollView.frame.size.height {
            mainTableView.tableFooterView = setupSpinnerFooter()
            getShowPlaceWithPagination()
        }
    }
}

// MARK: - UITableViewDelegate -
extension ShowPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = tableView.cellForRow(at: indexPath) as? ShowPlaceCell {
            cell.setupAnimationAvatar(param: detailedDataPlaces[safe: indexPath.row]?.xid ?? "")
            openDetailedScreen(index: indexPath.row)
        }
    }
}

// MARK: - SortedPlacesDelegate -
extension ShowPlaceViewController: SortedPlacesDelegate {
    func sortedPlace(model: PlaceChoiceModel) {
        placeChoice = model
        sortedPlaceChoiceData()
    }
}
