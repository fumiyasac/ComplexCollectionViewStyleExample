//
//  MainViewModel.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import Combine

// MARK: - Protocol

protocol MainViewModelInputs {
    var fetchFeaturedBannersTrigger: PassthroughSubject<Void, Never> { get }
    var fetchKeywordsTrigger: PassthroughSubject<Void, Never> { get }
    var fetchNewArrivalsTrigger: PassthroughSubject<Void, Never> { get }
    var fetchArticlesTrigger: PassthroughSubject<Void, Never> { get }

}

protocol MainViewModelOutputs {
    var featuredBanners: AnyPublisher<[FeaturedBanner], Never> { get }
    var keywords: AnyPublisher<[Keyword], Never> { get }
    var newArrivals: AnyPublisher<[NewArrival], Never> { get }
    var articles: AnyPublisher<[Article], Never> { get }
}

protocol MainViewModelType {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

final class MainViewModel: MainViewModelType, MainViewModelInputs, MainViewModelOutputs {

    // MARK: - MainViewModelType

    var inputs: MainViewModelInputs { return self }
    var outputs: MainViewModelOutputs { return self }
    
    // MARK: - MainViewModelInputs

    let fetchFeaturedBannersTrigger = PassthroughSubject<Void, Never>()
    let fetchKeywordsTrigger = PassthroughSubject<Void, Never>()
    let fetchNewArrivalsTrigger = PassthroughSubject<Void, Never>()
    let fetchArticlesTrigger = PassthroughSubject<Void, Never>()

    // MARK: - MainViewModelOutputs

    var featuredBanners: AnyPublisher<[FeaturedBanner], Never> {
        return $_featuredBanners.eraseToAnyPublisher()
    }
    var keywords: AnyPublisher<[Keyword], Never> {
        return $_keywords.eraseToAnyPublisher()
    }
    var newArrivals: AnyPublisher<[NewArrival], Never> {
        return $_newArrivals.eraseToAnyPublisher()
    }
    var articles: AnyPublisher<[Article], Never> {
        return $_articles.eraseToAnyPublisher()
    }

    private let api: APIRequestManagerProtocol

    private var cancellables: [AnyCancellable] = []
    
    // MARK: - @Published

    // MEMO: このコードではNSDiffableDataSourceSnapshotの差分更新部分で利用する
    @Published private var _featuredBanners: [FeaturedBanner] = []
    @Published private var _keywords: [Keyword] = []
    @Published private var _newArrivals: [NewArrival] = []
    @Published private var _articles: [Article] = []

    // MARK: - Initializer

    init(api: APIRequestManagerProtocol) {

        // MEMO: 適用するAPIリクエスト用の処理
        self.api = api

        // MEMO: InputTriggerとAPIリクエストをつなげる
        fetchFeaturedBannersTrigger
            .sink(
                receiveValue: { [weak self] in
                    self?.fetchFeaturedBanners()
                }
            )
            .store(in: &cancellables)
        fetchKeywordsTrigger
            .sink(
                receiveValue: { [weak self] in
                    self?.fetchKeywords()
                }
            )
            .store(in: &cancellables)
        fetchNewArrivalsTrigger
            .sink(
                receiveValue: { [weak self] in
                    self?.fetchNewArrivals()
                }
            )
            .store(in: &cancellables)
        fetchArticlesTrigger
            .sink(
                receiveValue: { [weak self] in
                    self?.fetchArticles()
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - deinit

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Privete Function

    private func fetchFeaturedBanners() {
        api.getFeatureBanners()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished fetchFeaturedBanners(): \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error fetchFeaturedBanners(): \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?._featuredBanners = hashableObjects
                }
            )
            .store(in: &cancellables)
    }

    private func fetchKeywords() {
        api.getKeywords()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished fetchKeywords(): \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error fetchKeywords(): \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?._keywords = hashableObjects
                }
            )
            .store(in: &cancellables)
    }

    private func fetchNewArrivals() {
        api.getNewArrivals()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished fetchNewArrivals(): \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error fetchNewArrivals(): \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?._newArrivals = hashableObjects
                }
            )
            .store(in: &cancellables)
    }

    private func fetchArticles() {
        api.getArticles()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished getArticles(): \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error getArticles(): \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?._articles = hashableObjects
                }
            )
            .store(in: &cancellables)
    }
}
