//
//  ImageCell.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/14.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib{
        return UINib(nibName: "ImageCell", bundle: nil)
    }
    static func resuseIde() -> String{
        return "ImageCell"
    }
}
