//
//  APIClient.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import Foundation

enum APIClientError: Error {
  case invalidUrl
  case responseError
  case badStatus(code: Int)
  case unknownError
}

protocol APIClientable {
  func fetch<T>(url: URL) async throws -> T where T: Decodable
  func fetchData(url: URL) async throws -> Data
}

class APIClient: APIClientable {
  func fetch<T>(url: URL) async throws -> T where T: Decodable {
    let (data, urlResponse) = try await URLSession.shared.data(from: url)
    guard let httpStatus = urlResponse as? HTTPURLResponse else {
      throw APIClientError.responseError
    }
    switch httpStatus.statusCode {
    case 200..<400:
      let jsonDecoder = JSONDecoder()
      jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
      return try jsonDecoder.decode(T.self, from: data)
    case 400...:
      throw APIClientError.badStatus(code: httpStatus.statusCode)
    default:
      throw APIClientError.unknownError
    }
  }

  func fetchData(url: URL) async throws -> Data {
    let (data, urlResponse) = try await URLSession.shared.data(from: url)
    guard let httpStatus = urlResponse as? HTTPURLResponse else {
      throw APIClientError.responseError
    }
    switch httpStatus.statusCode {
    case 200..<400:
      return data
    case 400...:
      throw APIClientError.badStatus(code: httpStatus.statusCode)
    default:
      throw APIClientError.unknownError
    }
  }
}
