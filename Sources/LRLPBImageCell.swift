//
//  LRLImageCell.swift
//  FeelfelCode
//
//  Created by liuRuiLong on 17/6/5.
//  Copyright © 2017年 李策. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD


class LRLPBImageCell: UICollectionViewCell {
    let imageView = LRLPBImageView(frame: CGRect.zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.contentView.bounds
        self.contentView.addSubview(imageView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
    }
    
    func setData(imageUrl: String, placeHolder: UIImage?){
        let url = URL(string: imageUrl)
        imageView.setImage(with: url, placeholder:placeHolder)
    }
    
    func setData(imageName: String) {
        imageView.setImage(image: UIImage(named: imageName) ?? UIImage(named: "placeHolder.jpg")!)
    }
    func setData(image: UIImage) {
        imageView.setImage(image: image)
    }

    func changeTheImageViewLocationWithOffset(offset: CGFloat) {
        if !zooming{
            imageView.setImageTransform(transform: CGAffineTransform(translationX: self.bounds.width * offset - 150.0 * offset, y: 0))
        }
    }
    static func reuseIdentifier() -> String{
        return "LRLPBImageCell"
    }
    
    func outZoom() {
        imageView.outZoom()
    }
    
    
    func inZoom() {
        imageView.inZoom()
    }
    var zooming:Bool{
        get{
            return imageView.zooming
        }
    }
    var zoomToTop: Bool{
        get{
            return imageView.zoomToTop
        }
    }
    
}


