//
//  GitHubRepository.swift
//  combine_samle
//
//  Created by masuyama on 2022/11/01.
//

import Foundation

struct GitHubRepositoryResponse: Codable {
  let items: [GitHubRepository]
}

struct GitHubRepository: Codable {
  let fullName: String
  let stargazersCount: Int
  let htmlUrl: String
  let owner: GitHubOwner

  var stargazersCountText: String {
    return "☆ \(stargazersCount)"
  }
}

struct GitHubOwner: Codable {
  let avatarUrl: String
}
