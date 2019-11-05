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
    func getArticles(page: Int) -> Future<[Articles], APIError>
}

class APIRequestManager {

    // MEMO: MockサーバーへのURLに関する情報
    private static let host = "http://localhost:3000/api/mock"
    private static let version = "v1"
    private static let path = "meals"

    // MARK: - Singleton Instance

    static let shared = APIRequestManager()

    private init() {}

    // MARK: - Enum

    enum EndPoint: String {
        case featureBanner = "feature_banner"
        case keyword = "keyword"
        case newArrival = "new_arrival"
        case article = "articles"

        // MARK: - Function

        func getBaseUrl() -> String {
            return [host, version, path, self.rawValue].joined(separator: "/")
        }
    }
}

// MARK: - APIRequestManagerProtocol

extension APIRequestManager: APIRequestManagerProtocol {

    // MARK: - Function

    func getArticles(page: Int = 1) -> Future<[Articles], APIError> {
        return Future { promise in
            let urlString = [EndPoint.article.getBaseUrl(), "page", String(page)].joined(separator: "/")
            let url = URL(string: urlString)!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                if let error = error {
                    promise(.failure(APIError.error(error.localizedDescription)))
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    promise(.failure(APIError.error("Error: invalid HTTP response code")))
                    return
                }
                guard let data = data else {
                    promise(.failure(APIError.error("Error: missing response data")))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let articles = try decoder.decode([Articles].self, from: data)
                    print(articles)
                    promise(.success(articles))
                } catch {
                    print(error.localizedDescription)
                    promise(.failure(APIError.error(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
}
