//
//  ViewModel.swift
//  combine_samle
//
//  Created by masuyama on 2022/10/31.
//

import Combine
import Foundation

protocol ViewModelable {
  var list: AnyPublisher<[GitHubRepository], Never> { get }
  var isLoading: AnyPublisher<Bool, Never> { get }
  var showSafariView: AnyPublisher<URL, Never> { get }
  var showAlert: AnyPublisher<String, Never> { get }
  func fetch(query: String?) async
  func handleDidSelectRowAt(_ index: Int)
}

class ViewModel: ViewModelable {
  var list: AnyPublisher<[GitHubRepository], Never>
  var isLoading: AnyPublisher<Bool, Never>
  var showSafariView: AnyPublisher<URL, Never>
  var showAlert: AnyPublisher<String, Never>

  private let listSubject = CurrentValueSubject<[GitHubRepository], Never>([])
  private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
  private let showSafariViewSubject = PassthroughSubject<URL, Never>()
  private let showAlertSubject = PassthroughSubject<String, Never>()
  private let apiClient: APIClientable

  init(apiClient: APIClientable = APIClient()) {
    list = listSubject.eraseToAnyPublisher()
    isLoading = isLoadingSubject.eraseToAnyPublisher()
    showSafariView = showSafariViewSubject.eraseToAnyPublisher()
    showAlert = showAlertSubject.eraseToAnyPublisher()
    self.apiClient = apiClient
  }

  func fetch(query: String?) async {
    do {
      guard let _query = query, let url = GitHubRepositoryRequest(query: _query).url else { return }
      await notifyIsLoading(true)
      let response: GitHubRepositoryResponse = try await apiClient.fetch(url: url)
      await notifyList(response.items)
      await notifyIsLoading(false)
    } catch {
      await notifyIsLoading(false)
      await notifyErrorMessage(error.localizedDescription)
    }
  }

  func handleDidSelectRowAt(_ index: Int) {
    let githubRepository = listSubject.value[index]
    guard let url = URL(string: githubRepository.htmlUrl) else { return }
    showSafariViewSubject.send(url)
  }

  @MainActor private func notifyList(_ list: [GitHubRepository]) {
    listSubject.send(list)
  }

  @MainActor private func notifyIsLoading(_ isLoading: Bool) {
    isLoadingSubject.send(isLoading)
  }

  @MainActor private func notifyErrorMessage(_ message: String) {
    showAlertSubject.send(message)
  }
}
