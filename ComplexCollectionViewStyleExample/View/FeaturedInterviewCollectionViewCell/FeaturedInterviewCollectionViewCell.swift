//
//  FeaturedInterviewCollectionViewCell.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import Nuke
import FontAwesome_swift
import ActiveLabel

// MEMO: FontAwesome_swift / ActiveLabelについては以前からもよく活用しているデザイン系のライブラリになります。

final class FeaturedInterviewCollectionViewCell: UICollectionViewCell {

    private let profileIconSize: CGSize = CGSize(width: 36.0, height: 36.0)
    
    // MARK: - @IBOutlet

    @IBOutlet weak private var profileIconImageView: UIImageView!
    @IBOutlet weak private var profileNameLabel: UILabel!
    @IBOutlet weak private var dateStringLabel: UILabel!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var hashTagsLabel: ActiveLabel!

    // MARK: - Initializer

    override func awakeFromNib() {
        super.awakeFromNib()

        setupFeaturedInterviewCollectionViewCell()
    }

    // MARK: - Function

    func setCell(_ featuredInterview: FeaturedInterview) {

        // MEMO: Nukeでの画像キャッシュと表示に関するオプション設定
        let imageDisplayOptions = ImageLoadingOptions(transition: .fadeIn(duration: 0.33))
        if let imageUrl = URL(string: featuredInterview.imageUrl) {
            Nuke.loadImage(with: imageUrl, options: imageDisplayOptions, into: thumbnailImageView)
        }

        profileNameLabel.text = featuredInterview.profileName
        dateStringLabel.text = featuredInterview.dateString

        titleLabel.attributedText = NSAttributedString(string: featuredInterview.title, attributes: UILabelDecorator.getLabelLineSpacingAttributes(4.0))
        descriptionLabel.attributedText = NSAttributedString(string: featuredInterview.description, attributes: UILabelDecorator.getLabelLineSpacingAttributes(6.0))

        let hashtagsArray = featuredInterview.tags.split(separator: ",")
        hashTagsLabel.text = hashtagsArray.map({ "#" + $0 + " " }).joined()
        hashTagsLabel.enabledTypes = [.hashtag]
        hashTagsLabel.handleHashtagTap { hashtag in
            print("押下されたハッシュタグ：\(hashtag)")
        }
    }

    // MARK: - Private Function

    private func setupFeaturedInterviewCollectionViewCell() {

        profileIconImageView.image = UIImage.fontAwesomeIcon(name: .grinStars, style: .solid, textColor: UIColor.gray, size: profileIconSize)
        hashTagsLabel.textColor = UIColor(code: "#ff9900")
    }
}
