//
//  NewArrivalCollectionHeaderView.swift
//  ComplexCollectionViewStyleExample
//
//  Created by 酒井文也 on 2019/11/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class NewArrivalCollectionHeaderView: UICollectionReusableView {

    // MARK: - @IBOutlet

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!

    // MARK: - Function

    func setHeader(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
