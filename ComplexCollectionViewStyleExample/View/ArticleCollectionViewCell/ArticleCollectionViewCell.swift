//
//  ArticleCollectionViewCell.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/02.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import Nuke

final class ArticleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var summaryLabel: UILabel!
    
    // MARK: - Function

    func setCell(_ article: Article) {

        // MEMO: Nukeでの画像キャッシュと表示に関するオプション設定
        let imageDisplayOptions = ImageLoadingOptions(transition: .fadeIn(duration: 0.33))
        if let imageUrl = URL(string: article.imageUrl) {
            Nuke.loadImage(with: imageUrl, options: imageDisplayOptions, into: thumbnailImageView)
        }

        titleLabel.attributedText = NSAttributedString(string: article.title, attributes: UILabelDecorator.getLabelLineSpacingAttributes(2.0))
        summaryLabel.attributedText = NSAttributedString(string: article.summary, attributes: UILabelDecorator.getLabelLineSpacingAttributes(3.0))
    }

    // MARK: - Private Function

    // 該当のUILabelに付与する属性を設定する
    private func getLabelLineSpacingAttributes(_ lineSpacing: CGFloat) -> [NSAttributedString.Key : Any] {

        // 行間に関する設定をする
        // MEMO: lineBreakModeの指定しないとはみ出た場合の「...」が出なくなる
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail

        // 上記で定義した行間・フォント・色を属性値として設定する
        var attributes: [NSAttributedString.Key : Any] = [:]
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle

        return attributes
    }
}
