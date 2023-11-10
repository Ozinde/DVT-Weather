//
//  FilterCell.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = 9
        thumbnailImageView.layer.masksToBounds = true
    }
}

extension FilterCell: ImageFiltering {
    func set(filterItem: ImageFilterItem, imageForThumbnail: UIImage) {
        nameLabel.text = filterItem.name
        if let filter = filterItem.filter {
            let filteredImage = apply(filter: filter, originalImage: imageForThumbnail)
            thumbnailImageView.image = filteredImage
        }
    }
}
