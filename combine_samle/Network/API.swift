//
//  API.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import Foundation

protocol APIRequestable {
  var url: URL? { get }
}

protocol GitHubAPI {
  static var scheme: String { get }
  static var host: String { get }
  static var path: String { get }
}

extension GitHubAPI {
  static var scheme: String { return "https" }
  static var host: String { return "api.github.com" }
  static var path: String { return "/search/repositories" }
}

class GitHubRepositoryRequest: APIRequestable, GitHubAPI {
  let url: URL?

  init(query: String) {
    var urlComponents = URLComponents()
    urlComponents.scheme = GitHubRepositoryRequest.scheme
    urlComponents.host = GitHubRepositoryRequest.host
    urlComponents.path = GitHubRepositoryRequest.path
    urlComponents.queryItems = [URLQueryItem(name: "q", value: query)]
    url = urlComponents.url
  }
}
