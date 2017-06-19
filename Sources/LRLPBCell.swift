//
//  LRLPBCell.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/19.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

class LRLPBCell: UICollectionViewCell{
    lazy var showView: LRLPBImageView = self.initialShowView()
    func initialShowView() -> LRLPBImageView{
        return LRLPBImageView(frame: CGRect.zero)
    }
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
    func endDisplay(){
        showView.endDisplay()
    }
    func changeTheImageViewLocationWithOffset(offset: CGFloat) {
        if !zooming{
            showView.setImageTransform(transform: CGAffineTransform(translationX: self.bounds.width * offset - 150.0 * offset, y: 0))
        }
    }
}

extension UICollectionViewCell{
    class func reuseIdentifier() -> String{
        return NSStringFromClass(self)
    }
}


class LRLPBImageCell: LRLPBCell{
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
}

class LRLPBVideoCell: LRLPBCell{
    override func initialShowView() -> LRLPBImageView {
        return LRLPBVideoView(frame: CGRect.zero)
    }
    var inShowView: LRLPBVideoView{
        get{
            return showView as! LRLPBVideoView
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView.frame = self.contentView.bounds
        self.contentView.addSubview(showView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(videoUrl: URL, placeHolder: UIImage?){
        inShowView.setVideoUrlStr(url: videoUrl, palceHolder: placeHolder)
    }
}

