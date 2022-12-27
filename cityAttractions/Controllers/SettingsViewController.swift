//
//  SettingsViewController.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 03.06.2021.
//

import UIKit

protocol SortedPlacesDelegate {
    func sortedPlace(model: PlaceChoiceModel)
}

final class SettingsViewController: UIViewController {
    var delegate: SortedPlacesDelegate?
    private var placeChoice = PlaceChoiceModel()
    private var storage = UserDefaults.standard
    private var settingsPlaces: DescriptionPlace?
    private var segmentArray = ["Название",
                              "Координаты"]
    private let pickerElementsArray = ["все места",
                                     "религия",
                                     "культура",
                                     "архитектура",
                                     "музеи"]
    private var segmentControl = UISegmentedControl()
    
    lazy private var pickerPlace: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.dataSource = self
        pv.delegate = self
        
        return pv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        saveSegmentedControlState()
    }
}

// MARK: - Private -
private extension SettingsViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupNavigationController()
        setupPickerPlace()
        setupSegmentControll()
    }
    
    func setupPickerPlace() {
        view.addSubview(pickerPlace)
        
        view.addConstraints([
            pickerPlace.topAnchor.constraint(equalTo: view.topAnchor,constant: 250),
            pickerPlace.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerPlace.heightAnchor.constraint(equalToConstant: 250),
            pickerPlace.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func filterPlacesData() {
        let selectedRow = pickerPlace.selectedRow(inComponent: 0)
       
        if selectedRow == 0 {
            placeChoice.kind = .religion
            placeChoice.allKinds = .cultural
        } else if selectedRow == 1 {
            placeChoice.kind = .religion
        } else if selectedRow == 2 {
            placeChoice.kind = .cultural
        } else if selectedRow == 3 {
            placeChoice.kind = .architecture
        } else if selectedRow == 4 {
            placeChoice.kind = .museum
        }
    }
    
    func setupSegmentControll() {
        segmentControl = UISegmentedControl(items: segmentArray)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        view.addSubview(segmentControl)
        
        view.addConstraints([
            segmentControl.topAnchor.constraint(equalTo: view.topAnchor,constant: 150),
            segmentControl.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 50),
            segmentControl.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -50),
        ])
    }
    
    func setupNavigationController() {
        navigationItem.title = "Настройки"
        view.backgroundColor = .systemGray6
        let saveBarBtn = UIBarButtonItem(title: "Сохранить",style: .done, target: self, action: #selector(save))
        let cancelBarBtn = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = saveBarBtn
        navigationItem.leftBarButtonItem = cancelBarBtn
    }
    
    @objc func save() {
        let segmentControlValue = segmentControl.selectedSegmentIndex
        let visibleType = VisibleType(index: segmentControlValue)
        SettingManager.shared.saveVisibleType(with: visibleType)
        storage.set(segmentControl.selectedSegmentIndex, forKey: "selectedSegmentIndex")
        filterPlacesData()
        delegate?.sortedPlace(model: placeChoice)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func saveSegmentedControlState() {
        if let value = UserDefaults.standard.value(forKey: "selectedSegmentIndex") {
            let selectedIndex = value as? Int
            segmentControl.selectedSegmentIndex = selectedIndex ?? 0
        }
    }
}

// MARK: - UIPickerViewDataSource -
extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerElementsArray.count
    }
}

// MARK: - UIPickerViewDelegate -
extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerElementsArray[safe: row]
    }
}
