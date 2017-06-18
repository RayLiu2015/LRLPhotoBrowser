//
//  LRLPBVideoCell.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/18.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit

class LRLPBVideoCell:  UICollectionViewCell, LRLPBContentViewProtocol{
    var showView: LRLPBVideoView = LRLPBVideoView(frame: CGRect.zero)
    typealias ViewType = LRLPBVideoView
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView.frame = self.contentView.bounds
        self.contentView.addSubview(showView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     class func reuseIdentifier() -> String{
        return "LRLPBVideoCell"
    }
    
    func setData(videoUrl: URL, placeHolder: UIImage?){
        showView.setVideoUrlStr(url: videoUrl, palceHolder: placeHolder)
    }
    
    func changeTheImageViewLocationWithOffset(offset: CGFloat) {
        if !zooming{
            showView.setImageTransform(transform: CGAffineTransform(translationX: self.bounds.width * offset - 150.0 * offset, y: 0))
        }
    }

}
