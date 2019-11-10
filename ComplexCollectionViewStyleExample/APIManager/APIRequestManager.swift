//
//  APIRequestManager.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/04.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import Combine

// MARK: - Protocol

enum APIError : Error {
    case error(String)
}

protocol APIRequestManagerProtocol {
    func getFeaturedBanners() -> Future<[FeaturedBanner], APIError>
    func getFeaturedInterviews() -> Future<[FeaturedInterview], APIError>
    func getKeywords() -> Future<[Keyword], APIError>
    func getNewArrivals() -> Future<[NewArrival], APIError>
    func getArticles() -> Future<[Article], APIError>
}

class APIRequestManager {

    // MEMO: MockサーバーへのURLに関する情報
    private static let host = "http://localhost:3000/api/mock"
    private static let version = "v1"
    private static let path = "gourmet"

    private let session = URLSession.shared

    // MARK: - Singleton Instance

    static let shared = APIRequestManager()

    private init() {}

    // MARK: - Enum

    private enum EndPoint: String {

        case featuredBanner = "featured_banners"
        case featuredInterview = "featured_interviews"
        case keyword = "keywords"
        case newArrival = "new_arrivals"
        case article = "articles"

        func getBaseUrl() -> String {
            return [host, version, path, self.rawValue].joined(separator: "/")
        }
    }
}

// MARK: - APIRequestManagerProtocol

extension APIRequestManager: APIRequestManagerProtocol {

    // MARK: - Function

    func getFeaturedBanners() -> Future<[FeaturedBanner], APIError> {
        let featuresdBannersAPIRequest = makeUrlForGetRequest(EndPoint.featuredBanner.getBaseUrl())
        return handleSessionTask(FeaturedBanner.self, request: featuresdBannersAPIRequest)
    }

    func getFeaturedInterviews() -> Future<[FeaturedInterview], APIError> {
        let featuredInterviewsAPIRequest = makeUrlForGetRequest(EndPoint.featuredInterview.getBaseUrl())
        return handleSessionTask(FeaturedInterview.self, request: featuredInterviewsAPIRequest)
    }

    func getKeywords() -> Future<[Keyword], APIError> {
        let keywordsAPIRequest = makeUrlForGetRequest(EndPoint.keyword.getBaseUrl())
        return handleSessionTask(Keyword.self, request: keywordsAPIRequest)
    }

    func getNewArrivals() -> Future<[NewArrival], APIError> {
        let newArrivalsAPIRequest = makeUrlForGetRequest(EndPoint.newArrival.getBaseUrl())
        return handleSessionTask(NewArrival.self, request: newArrivalsAPIRequest)
    }

    func getArticles() -> Future<[Article], APIError> {
        let articlesAPIRequest = makeUrlForGetRequest(EndPoint.article.getBaseUrl())
        return handleSessionTask(Article.self, request: articlesAPIRequest)
    }

    // MARK: - Private Function

    private func handleSessionTask<T: Decodable & Hashable>(_ dataType: T.Type, request: URLRequest) -> Future<[T], APIError> {
        return Future { promise in

            let task = self.session.dataTask(with: request) { data, response, error in
                // MEMO: レスポンス形式やステータスコードを元にしたエラーハンドリングをする
                if let error = error {
                    promise(.failure(APIError.error(error.localizedDescription)))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    promise(.failure(APIError.error("Error: invalid HTTP response code")))
                    return
                }
                guard let data = data else {
                    promise(.failure(APIError.error("Error: missing response data")))
                    return
                }
                // MEMO: 取得できたレスポンスを引数で指定した型の配列に変換して受け取る
                do {
                    let hashableObjects = try JSONDecoder().decode([T].self, from: data)
                    promise(.success(hashableObjects))
                } catch {
                    promise(.failure(APIError.error(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }

    private func makeUrlForGetRequest(_ urlString: String) -> URLRequest {
        guard let url = URL(string: urlString) else {
            fatalError()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
