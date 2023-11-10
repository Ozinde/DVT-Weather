//
//  PhotoViewCell.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/10.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func setPhoto(displaying data: Data) {
        let image = UIImage(data: data)
        imageView.image = image
    }
    
}
