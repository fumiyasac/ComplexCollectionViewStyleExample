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
    func getArticles() -> Future<[Article], APIError>
}

class APIRequestManager {
    // MEMO: MockサーバーへのURLに関する情報
    private static let host = "http://localhost:3000/api/mock"
    private static let version = "v1"
    private static let path = "meals"

    private let session = URLSession.shared

    // MARK: - Singleton Instance

    static let shared = APIRequestManager()

    private init() {}

    // MARK: - Enum

    enum EndPoint: String {

        case featureBanner = "feature_banner"
        case keyword = "keyword"
        case newArrival = "new_arrival"
        case article = "articles"

        func getBaseUrl() -> String {
            return [host, version, path, self.rawValue].joined(separator: "/")
        }
    }
}

// MARK: - APIRequestManagerProtocol

extension APIRequestManager: APIRequestManagerProtocol {

    // MARK: - Function

    func getArticles() -> Future<[Article], APIError> {
        let articleAPIRequest = self.makeUrlRequest(EndPoint.article.getBaseUrl())
        return handleSessionTask(Article.self, request: articleAPIRequest)
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

                // MEMO: 取得できたレスポンスを引数で指定した型の配列で受け取る
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

    private func makeUrlRequest(_ urlString: String) -> URLRequest {
        guard let url = URL(string: urlString) else {
            fatalError()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
