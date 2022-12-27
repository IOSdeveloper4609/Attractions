//
//  BaseCell.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import UIKit

class BaseCell: UITableViewCell {
    static var identifier: String {
        String(describing: type(of: self))
    }
}
