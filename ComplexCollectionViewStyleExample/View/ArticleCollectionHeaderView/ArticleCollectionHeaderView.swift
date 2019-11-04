//
//  ArticleCollectionHeaderView.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/04.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class ArticleCollectionHeaderView: UICollectionReusableView {

    // MARK: - @IBOutlet

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Initializer

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
