//
//  KeywordCollectionViewCell.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class KeywordCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var titleLabel: UILabel!

    // MARK: - Initializer

    override func awakeFromNib() {
        super.awakeFromNib()

        setupKeywordCollectionViewCell()
    }

    // MARK: - Function

    func setCell(_ keyword: Keyword) {

        titleLabel.text = keyword.keyword
    }

    // MARK: - Private Function

    func setupKeywordCollectionViewCell() {

        titleLabel.textColor = UIColor(code: "ff9900")
        titleLabel.superview?.layer.masksToBounds = true
        titleLabel.superview?.layer.cornerRadius = 10.0
        titleLabel.superview?.layer.borderWidth = 2.5
        titleLabel.superview?.layer.borderColor = UIColor(code: "ff9900").cgColor
    }
}
