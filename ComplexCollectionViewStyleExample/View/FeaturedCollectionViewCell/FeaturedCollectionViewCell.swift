//
//  FeaturedCollectionViewCell.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import Nuke

final class FeaturedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var dateStringLabel: UILabel!

    // MARK: - Function

    func setCell(_ featuredBanner: FeaturedBanner) {
        // MEMO: Nukeでの画像キャッシュと表示に関するオプション設定
        let imageDisplayOptions = ImageLoadingOptions(transition: .fadeIn(duration: 0.33))
        if let imageUrl = URL(string: featuredBanner.imageUrl) {
            Nuke.loadImage(with: imageUrl, options: imageDisplayOptions, into: thumbnailImageView)
        }
        titleLabel.text = featuredBanner.title
        dateStringLabel.text = featuredBanner.dateString
    }
}
