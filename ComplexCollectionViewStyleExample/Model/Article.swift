//
//  Article.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/04.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

struct Article: Hashable, Decodable {

    let id: Int
    let categoryNumber: Int
    let title: String
    let summary: String
    let imageUrl: String

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
        hasher.combine(id)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
}