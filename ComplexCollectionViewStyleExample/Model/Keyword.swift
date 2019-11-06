//
//  Keyword.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

struct Keyword: Hashable, Decodable {

    let id: Int
    let keyword: String

    // MARK: - Enum

    /*
    private enum Keys: String, CodingKey {
        case id
        case keyword
    }
    */

    // MARK: - Initializer

    init(id: Int, keyword: String) {
        self.id = id
        self.keyword = keyword
    }

    /*
    init(from decoder: Decoder) throws {

        // JSONの配列内の要素を取得する
        let container = try decoder.container(keyedBy: Keys.self)

        // JSONの配列内の要素にある値をDecodeして初期化する
        self.id = try container.decode(Int.self, forKey: .id)
        self.keyword = try container.decode(String.self, forKey: .keyword)
    }
    */

    // MARK: - Hashable

    // MEMO: Hashableプロトコルに適合させるための処理
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Keyword, rhs: Keyword) -> Bool {
        return lhs.id == rhs.id
    }
}
