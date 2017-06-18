//
//  LRLImageView.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/14.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD


class LRLPBImageView: UIView, UIScrollViewDelegate{
    private(set) var imageView: UIImageView
    private var scrollView: UIScrollView
    var zooming: Bool{
        get{
            return scrollView.zoomScale != scrollView.minimumZoomScale
        }
    }
    var zoomToTop: Bool{
        get{
            if zooming{
                print(scrollView.contentOffset.y)
                return scrollView.contentOffset.y <= 0
            }else{
                return false
            }
        }
    }

    var image: UIImage?{
        set{
            imageView.image = newValue
            updateUI()
        }
        get{
            return imageView.image
        }
    }
    
    override var isUserInteractionEnabled: Bool{
        set{
            super.isUserInteractionEnabled = newValue
            imageView.isUserInteractionEnabled = newValue
        }
        get{
            return imageView.isUserInteractionEnabled
        }
        
    }
    
    override var frame: CGRect{
        set{
            super.frame = newValue
            scrollView.frame = super.bounds
            updateUI()
        }
        get{
            return super.frame
        }
    }
    
    override var contentMode: UIViewContentMode{
        set{
            super.contentMode = newValue
            updateUI()
        }
        get{
            return super.contentMode
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        scrollView = UIScrollView(frame: frame)
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        scrollView = UIScrollView(frame: CGRect.zero)
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    init(image:UIImage) {
        imageView = UIImageView(image: image)
        scrollView = UIScrollView(frame: CGRect.zero)
        super.init(frame: CGRect.zero)
        commonInit()
    }

    func setImageTransform( transform: CGAffineTransform){
        var inTransform = transform
        let originTransform = imageView.transform
        inTransform.a = originTransform.a
        inTransform.d = originTransform.d
        self.imageView.transform = transform
    }
    private func updateUI() {
        guard image != nil && self.bounds.size.width > 0 && self.bounds.size.height > 0 else {
            return
        }
        
        switch self.contentMode {
        case .scaleToFill:
            self.updateToScaleToFill()
        case .scaleAspectFit:
            updateToScaleAspectFit()
        case .scaleAspectFill:
            updateToScaleAspectFill()
        default:
            break
        }
        
        if imageView.bounds.height < scrollView.bounds.height/2{
            scrollView.maximumZoomScale = scrollView.bounds.height/imageView.bounds.height
        }else{
            if scrollView.bounds.width < scrollView.bounds.width {
                scrollView.maximumZoomScale = scrollView.bounds.width/imageView.bounds.width
            }else{
                scrollView.maximumZoomScale = 2.0
            }
        }
    }
    
    private func updateToScaleToFill(){
        imageView.frame = self.bounds
    }
    
    private func updateToScaleAspectFit(){
        var imageSize = CGSize(width: image!.size.width/image!.scale, height: image!.size.height/image!.scale)
        let widthdRatio = imageSize.width/bounds.size.width
        let heigthRation = imageSize.height/bounds.size.height
        if (widthdRatio > heigthRation){
            imageSize = CGSize(width: imageSize.width/widthdRatio, height: imageSize.height/widthdRatio)
        }else{
            imageSize = CGSize(width: imageSize.width/heigthRation, height: imageSize.height/heigthRation)
        }
        imageView.bounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        imageView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    }
    
    private func updateToScaleAspectFill(){
        var imageSize = CGSize(width: image!.size.width/image!.scale, height: image!.size.height/image!.scale)
        let widthdRatio = imageSize.width/bounds.size.width
        let heigthRation = imageSize.height/bounds.size.height
        if (widthdRatio > heigthRation){
            imageSize = CGSize(width: imageSize.width/heigthRation, height: imageSize.height/heigthRation)
        }else{
            imageSize = CGSize(width: imageSize.width/widthdRatio, height: imageSize.height/widthdRatio)
        }
        imageView.bounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        imageView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    }
    
    private func commonInit(){
        scrollView.frame = self.bounds
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        self.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleToFill
    }
    
    @discardableResult
    func setImage(with resource: Resource?,
                         placeholder: Image? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask?{
        guard let inResource = resource else {
            image = placeholder
            return nil
        }
        
        var progress: MBProgressHUD?
        if !KingfisherManager.shared.cache.isImageCached(forKey: inResource.cacheKey).cached{
            progress = MBProgressHUD.showAdded(to: self, animated: true)
            progress?.mode = .annularDeterminate
        }else{
            image = placeholder
        }
        return imageView.kf.setImage(with: resource, placeholder: placeholder, options: options, progressBlock:{
            (receivedSize, totalSize) in
            progress?.progress = Float(receivedSize)/Float(totalSize)
        }, completionHandler: {[weak self](image, error, cacheType, imageUrl) -> () in
            completionHandler?(image, error, cacheType, imageUrl)
            progress?.hide(animated: true)
            if let inImage = image {
                self?.image = inImage
            }else{
                print("load image error: \(error?.description ?? "")")
            }
            
        })
    }
    
    func setImage(image:UIImage){
        self.image = image;
    }
    
    //MARK: zoom
    func setZoomScale(scale: CGFloat) {
        scrollView.zoomScale = scale
    }
    
    func outZoom() {
        scrollView.setZoomScale(1.0, animated: true)
    }
    
    func inZoom() {
        scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xcenter = scrollView.center.x
        var ycenter = scrollView.center.y;
        //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
        if scrollView.contentSize.width > scrollView.frame.size.width {
            xcenter = scrollView.contentSize.width/2
        }
        if scrollView.contentSize.height > scrollView.frame.size.height{
            ycenter = scrollView.contentSize.height/2
        }
        imageView.center = CGPoint(x: xcenter, y: ycenter)
        print("---- \(imageView.frame) -- offset: \(scrollView.contentOffset) \(scrollView.contentSize)")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
