//
//  TableViewCell.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import UIKit

class TableViewCell: UITableViewCell {

  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var stargazersCountLabel: UILabel!

  private let apiClient: APIClientable = APIClient()

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  func render(with githubRepository: GitHubRepository) {
    nameLabel.text = githubRepository.fullName
    stargazersCountLabel.text = githubRepository.stargazersCountText

    guard let url = URL(string: githubRepository.owner.avatarUrl) else { return }
    Task {
      do {
        let data = try await apiClient.fetchData(url: url)
        iconImageView.image = UIImage(data: data)
      } catch {
        print("🔴 \(error.localizedDescription)")
      }
    }
  }
}

extension TableViewCell: NibLoadable {}
