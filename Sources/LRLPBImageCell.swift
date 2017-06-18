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

protocol LRLPBContentViewProtocol{
    associatedtype ViewType: LRLPBImageView
    var showView: ViewType{set get}
    func outZoom()
    func configShowView()
    func inZoom()
    func endDisplay()
    var zooming:Bool{get}
    var zoomToTop: Bool{get}
    func changeTheImageViewLocationWithOffset(offset: CGFloat) 
}

extension LRLPBContentViewProtocol{
    func outZoom() {
        showView.outZoom()
    }
    
    func inZoom() {
        showView.inZoom()
    }
    var zooming:Bool{
        get{
            return showView.zooming
        }
    }
    var zoomToTop: Bool{
        get{
            return showView.zoomToTop
        }
    }
    func configShowView(){
        
    }
    func endDisplay(){
        showView.endDisplay()
    }
}

extension UICollectionViewCell{
    func cellEndDisplay(){
        if let imageCell = self as? LRLPBImageCell {
            imageCell.endDisplay()
        }else{
            let videoCell = self as! LRLPBVideoCell
            videoCell.endDisplay()
        }
    }
    func cellChangeTheImageViewLocationWithOffset(offset: CGFloat) {
        if let imageCell = self as? LRLPBImageCell {
            imageCell.changeTheImageViewLocationWithOffset(offset: offset)
        }else{
            let videoCell = self as! LRLPBVideoCell
            videoCell.changeTheImageViewLocationWithOffset(offset: offset)
        }

    }
}

class LRLPBImageCell: UICollectionViewCell, LRLPBContentViewProtocol{
    var showView: LRLPBImageView = LRLPBImageView(frame: CGRect.zero)
    typealias ViewType = LRLPBImageView
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView.frame = self.contentView.bounds
        self.contentView.addSubview(showView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setData(imageUrl: String, placeHolder: UIImage?){
        let url = URL(string: imageUrl)
        showView.setImage(with: url, placeholder:placeHolder)
    }
    
    func setData(imageName: String) {
        showView.setImage(image: UIImage(named: imageName) ?? UIImage(named: "placeHolder.jpg")!)
    }
    func setData(image: UIImage) {
        showView.setImage(image: image)
    }

    func changeTheImageViewLocationWithOffset(offset: CGFloat) {
        if !zooming{
            showView.setImageTransform(transform: CGAffineTransform(translationX: self.bounds.width * offset - 150.0 * offset, y: 0))
        }
    }
    class func reuseIdentifier() -> String{
        return "LRLPBImageCell"
    }
    
}


