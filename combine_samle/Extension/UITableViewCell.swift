//
//  UITableViewCell.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import UIKit

extension UITableViewCell {
  class var defaultReuseIdentifier: String {
    return String(describing: self)
  }
}
