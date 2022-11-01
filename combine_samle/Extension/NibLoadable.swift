//
//  NibLoadable.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import UIKit

protocol NibLoadable {
  static var nibName: String { get }
  static func loadNib(_ bundle: Bundle?) -> UINib
}

extension NibLoadable {
  static var nibName: String {
    return String(describing: self)
  }

  static func loadNib(_ bundle: Bundle? = nil) -> UINib {
    return UINib(nibName: nibName, bundle: bundle)
  }
}
