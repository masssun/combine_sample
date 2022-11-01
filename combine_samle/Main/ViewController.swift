//
//  ViewController.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import Combine
import SafariServices
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.register(TableViewCell.self)
      tableView.delegate = self

      viewModel.list
        .sink(
          receiveValue: tableView.items { tableView, indexPath, item in
            let cell: TableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.render(with: item)
            return cell
          }
        )
        .store(in: &subscriptions)
    }
  }

  private lazy var searchController: UISearchController = {
    let controller = UISearchController()
    controller.searchBar.placeholder = "Please type a query"
    controller.searchBar.delegate = self
    return controller
  }()

  private lazy var indicatorView: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.frame = .init(x: 0, y: 0, width: 64, height: 64)
    indicator.center = view.center
    indicator.isHidden = true
    return indicator
  }()

  private let viewModel: ViewModelable = ViewModel()
  private var subscriptions = [AnyCancellable]()

  deinit {
    subscriptions.forEach { $0.cancel() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.searchController = searchController
    view.addSubview(indicatorView)

    viewModel.isLoading
      .sink { [weak self] isLoading in
        isLoading ? self?.indicatorView.startAnimating() : self?.indicatorView.stopAnimating()
        self?.indicatorView.isHidden = !isLoading
      }
      .store(in: &subscriptions)

    viewModel.showSafariView
      .sink { [weak self] url in
        let safariViewController = SFSafariViewController(url: url)
        self?.present(safariViewController, animated: true) {
        }
      }
      .store(in: &subscriptions)

    viewModel.showAlert
      .sink { [weak self] message in
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        self?.present(alertController, animated: true)
      }
      .store(in: &subscriptions)
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.handleDidSelectRowAt(indexPath.row)
  }
}

extension ViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    Task { await viewModel.fetch(query: searchBar.text) }
  }
}
