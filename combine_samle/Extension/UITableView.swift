//
//  UITableView.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import UIKit

extension UITableView {
  func register<T>(_: T.Type) where T: UITableViewCell, T: NibLoadable {
    register(T.loadNib(), forCellReuseIdentifier: T.defaultReuseIdentifier)
  }

  func items<Element>(_ builder: @escaping (UITableView, IndexPath, Element) -> UITableViewCell) -> ([Element]) -> Void {
    let dataSource = CombineTableViewDataSource(builder: builder)
    return { items in
      dataSource.pushElements(items, to: self)
    }
  }

  func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
    return dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as! T
  }
}

class CombineTableViewDataSource<T>: NSObject, UITableViewDataSource {

  private let build: (UITableView, IndexPath, T) -> UITableViewCell
  private var items = [T]()

  init(builder: @escaping (UITableView, IndexPath, T) -> UITableViewCell) {
    build = builder
    super.init()
  }

  func pushElements(_ items: [T], to tableView: UITableView) {
    tableView.dataSource = self
    self.items = items
    tableView.reloadData()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    build(tableView, indexPath, items[indexPath.row])
  }
}
