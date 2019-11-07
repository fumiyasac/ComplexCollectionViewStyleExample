//
//  MainViewModel.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import Combine

final class MainViewModel {

    private let api: APIRequestManagerProtocol
    
    private var featuredBannersCancellable: AnyCancellable?
    private var keywordsCancellable: AnyCancellable?
    private var newArrivalsCancellable: AnyCancellable?
    private var articlesCancellable: AnyCancellable?

    // MARK: - @Published
    
    // MEMO: このコードではNSDiffableDataSourceSnapshotの差分更新部分で利用する
    @Published private(set) var featuredBanners: [FeaturedBanner] = []
    @Published private(set) var keywords: [Keyword] = []
    @Published private(set) var newArrivals: [NewArrival] = []
    @Published private(set) var articles: [Article] = []

    // MARK: - Initializer

    init(api: APIRequestManagerProtocol) {
        self.api = api
    }

    // MARK: - deinit

    deinit {
        articlesCancellable?.cancel()
        keywordsCancellable?.cancel()
    }

    // MARK: - Function

    func fetchKeywords() {
        keywordsCancellable = api.getKeywords()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished: \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?.keywords = hashableObjects
                }
            )
    }

    func fetchArticles() {
        articlesCancellable = api.getArticles()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 値取得成功時（※本当は厳密にエラーハンドリングする必要がある）
                    case .finished:
                        print("finished: \(completion)")
                    // MEMO: エラー時（※本当は厳密にエラーハンドリングする必要がある）
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] hashableObjects in
                    print(hashableObjects)
                    self?.articles = hashableObjects
                }
            )
    }
}
