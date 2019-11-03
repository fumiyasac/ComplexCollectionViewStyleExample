//
//  NewArrival.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

struct NewArrival: Hashable, Decodable {

    let id: Int

    private let identifier = UUID()

    // MARK: - Enum

    /*
    private enum Keys: String, CodingKey {
        case id
    }
    */

    // MARK: - Initializer

    init(id: Int) {
        self.id = id
    }

    /*
    init(from decoder: Decoder) throws {

        // JSONの配列内の要素を取得する
        let container = try decoder.container(keyedBy: Keys.self)

        // JSONの配列内の要素にある値をDecodeして初期化する
        self.id = try container.decode(Int.self, forKey: .id)
    }
    */

    // MARK: - Hashable

    // MEMO: Hashableプロトコルに適合させるための処理
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: NewArrival, rhs: NewArrival) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
