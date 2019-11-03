//
//  FeaturedBanner.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

struct FeaturedBanner: Hashable, Decodable {
    
    let id: Int
    let title: String
    let dateString: String

    private let identifier = UUID()

    // MARK: - Enum

    private enum Keys: String, CodingKey {
        case id
        case title
        case dateString
    }

    // MARK: - Initializer

    init(id: Int, title: String, dateString: String) {
        self.id = id
        self.title = title
        self.dateString = dateString
    }

    // MARK: - Hashable

    // MEMO: Hashableプロトコルに適合させるための処理
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: FeaturedBanner, rhs: FeaturedBanner) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
