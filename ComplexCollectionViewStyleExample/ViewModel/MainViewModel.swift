//
//  MainViewModel.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import Combine

enum ArticlesRequestState {
    case loading
    case finishedLoading
    case error(Error)
}

final class MainViewModel {

    private var featuredBannersCancellable: AnyCancellable?
    private var keywordsCancellable: AnyCancellable?
    private var newArrivalsCancellable: AnyCancellable?
    private var articlesCancellable: AnyCancellable?

    // MARK: - @Published

    @Published private(set) var featuredBanners: [FeaturedBanner] = []
    @Published private(set) var keywords: [Keyword] = []
    @Published private(set) var newArrivals: [NewArrival] = []

    @Published private(set) var articles: [Article] = []
    @Published private(set) var state: ArticlesRequestState = .loading

    func fetchArticles() {
        articlesCancellable = APIRequestManager.shared.getArticles()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    // MEMO: 本当はエラーハンドリングを真面目にする...
                    case .finished:
                        print("finished: \(completion)")
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] result in
                    if let articles = result.first.map({ $0.articles }) {
                        self?.articles = articles
                    }
                }
            )
    }
}
