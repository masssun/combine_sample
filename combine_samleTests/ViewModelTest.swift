//
//  ViewModelTest.swift
//  combine_samleTests
//
//  Created by masuyama on 2022/11/01.
//

import Combine
import XCTest

@testable import combine_samle

class APIClientStub: APIClientable {
  private let isFailure: Bool

  init(isFailure: Bool = false) {
    self.isFailure = isFailure
  }

  func fetch<T>(url: URL) async throws -> T where T: Decodable {
    if isFailure {
      throw APIClientError.badStatus(code: 503)
    }
    let data = try JSONEncoder().encode(
      GitHubRepositoryResponse(items: [
        GitHubRepository(
          fullName: "apple/swift",
          stargazersCount: 1234,
          htmlUrl: "https://github.com/apple/swift",
          owner: GitHubOwner(avatarUrl: "https://avatars.githubusercontent.com/u/10639145?s=200&v=4")
        )
      ])
    )
    return try JSONDecoder().decode(T.self, from: data)
  }

  func fetchData(url: URL) async throws -> Data {
    return Data()
  }
}

final class ViewModelTest: XCTestCase {

  private var subscriptions = [AnyCancellable]()

  override func tearDownWithError() throws {
    subscriptions.forEach { $0.cancel() }
  }

  func testFetchWithSuccess() async throws {
    let viewModel = ViewModel(apiClient: APIClientStub())

    var isLoadings = [Bool]()
    viewModel.isLoading
      .sink {
        isLoadings.append($0)
      }
      .store(in: &subscriptions)

    var listCounts = [Int]()
    viewModel.list
      .sink {
        listCounts.append($0.count)
      }
      .store(in: &subscriptions)

    await viewModel.fetch(query: "Swift")
    XCTAssertEqual(isLoadings, [false, true, false])
    XCTAssertEqual(listCounts, [0, 1])
  }

  func testFetchWithFailure() async throws {
    let viewModel = ViewModel(apiClient: APIClientStub(isFailure: true))

    var isLoadings = [Bool]()
    viewModel.isLoading
      .sink {
        isLoadings.append($0)
      }
      .store(in: &subscriptions)

    var listCounts = [Int]()
    viewModel.list
      .sink {
        listCounts.append($0.count)
      }
      .store(in: &subscriptions)

    var errorMessages = [String]()
    viewModel.showAlert
      .sink {
        errorMessages.append($0)
      }
      .store(in: &subscriptions)

    await viewModel.fetch(query: "Swift")
    XCTAssertEqual(isLoadings, [false, true, false])
    XCTAssertEqual(listCounts, [0])
    XCTAssertEqual(errorMessages.count, 1)
  }

  func testHandleDidSelectRowAt() async throws {
    let viewModel = ViewModel(apiClient: APIClientStub())

    var urls = [URL]()
    viewModel.showSafariView
      .sink {
        urls.append($0)
      }
      .store(in: &subscriptions)

    await viewModel.fetch(query: "Swift")
    viewModel.handleDidSelectRowAt(0)
    XCTAssertEqual(urls.count, 1)
  }
}
