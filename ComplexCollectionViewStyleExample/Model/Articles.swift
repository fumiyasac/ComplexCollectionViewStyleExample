//
//  Articles.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/04.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

struct Articles: Hashable, Codable {

    let page: Int
    let hasNextPage: Bool
    let articles: [Article]

    private let identifier = UUID()
    
    // MARK: - Enum

    private enum Keys: String, CodingKey {
        case page
        case hasNextPage = "has_next_page"
        case articles
    }

    // MARK: - Initializer

    init(from decoder: Decoder) throws {

        // JSONの配列内の要素を取得する
        let container = try decoder.container(keyedBy: Keys.self)

        // JSONの配列内の要素にある値をDecodeして初期化する
        self.page = try container.decode(Int.self, forKey: .page)
        self.hasNextPage = try container.decode(Bool.self, forKey: .hasNextPage)
        self.articles = try container.decode([Article].self, forKey: .articles)
    }

    // MARK: - Hashable

    // MEMO: Hashableプロトコルに適合させるための処理
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Articles, rhs: Articles) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct Article: Hashable, Codable {

    let id: Int
    let categoryNumber: Int
    let title: String
    let summary: String
    let imageUrl: String

    private let identifier = UUID()

    // MARK: - Enum

    private enum Keys: String, CodingKey {
        case id
        case categoryNumber = "category_number"
        case title
        case summary
        case imageUrl = "image_url"
    }

    // MARK: - Initializer

    init(from decoder: Decoder) throws {

        // JSONの配列内の要素を取得する
        let container = try decoder.container(keyedBy: Keys.self)

        // JSONの配列内の要素にある値をDecodeして初期化する
        self.id = try container.decode(Int.self, forKey: .id)
        self.categoryNumber = try container.decode(Int.self, forKey: .categoryNumber)
        self.title = try container.decode(String.self, forKey: .title)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }

    // MARK: - Hashable

    // MEMO: Hashableプロトコルに適合させるための処理
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
