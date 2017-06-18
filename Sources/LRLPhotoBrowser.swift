//
//  LRLPhotoBrowser.swift
//  FeelfelCode
//
//  Created by liuRuiLong on 17/5/17.
//  Copyright © 2017年 李策. All rights reserved.
//

import UIKit
import SnapKit

public enum LRLPhotoBrowserModel{
    case imageName(String)
    case image(UIImage)
    case imageUrl(ur: String, placeHolder: UIImage?)
    //    case videoUrl(url: URL, placeHolder: UIImage?)

}

public enum LRLPBCollectionViewPageType {
    case common
    case slide
}

public protocol LRLPhotoBrowserDelegate: class{
    func imageDidScroll(index: Int) -> UIImageView?
    func imageSwipViewDismiss(imageView: UIImageView?)
}

public class LRLPhotoBrowser: UIView, LRLPBCollectionDelegate{
    /// 所点击的 imageView
    public var selectedImageView: UIImageView?
    /// 当前所选中ImageView 相对于 pbSuperView 的位置
    public var selectedFrame: CGRect?
    public weak var delegate: LRLPhotoBrowserDelegate?
    /// 是否开启拖动
    public var animition = false{
        didSet{
            self.collectionView?.panEnable = animition
        }
    }
    
    /// 相册的实例化方法
    ///
    /// - Parameters:
    ///   - frame: 相册视图尺寸, 默认为屏幕尺寸
    ///   - dataSource: 数据源
    ///   - initialIndex: 初始位置
    ///   - selectedImageView: 所点击的imageView 根据这个imageView 内部进行动画
    ///   - delegate: 代理
    ///   - animition: 是否开启拖拽和动画
    public init(frame: CGRect = UIScreen.main.bounds, dataSource: [LRLPhotoBrowserModel], initialIndex: Int, selectedImageView: UIImageView?, delegate: LRLPhotoBrowserDelegate?, animition: Bool = true, pageType: LRLPBCollectionViewPageType = .slide) {
        self.pageType = pageType
        super.init(frame:frame)
        self.dataSource = dataSource
        self.delegateHolder = LRLPBCollectionDelegateHolder(delegate: self)
        self.imgContentMode = contentMode
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.selectedImageView = selectedImageView
        self.delegate = delegate
        self.animition = animition
        configUI()
    }

    /// 显示相册
    public func show(){
        guard let window = pbSuperView else{
            fatalError("no superView")
        }
        
        if  let inImageView = selectedImageView, let initialFrame = inImageView.superview?.convert(inImageView.frame, to: window){
            selectedFrame = initialFrame
            let imageView = LRLPBImageView(frame: initialFrame)
            imageView.contentMode = .scaleAspectFill
            imageView.image = inImageView.image
            
            window.addSubview(imageView)
            window.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                imageView.contentMode = .scaleAspectFit
                imageView.frame = self.frame
                imageView.backgroundColor = UIColor.black
            }, completion: { (complete) in
                window.isUserInteractionEnabled = true
                imageView.removeFromSuperview()
                window.addSubview(self)
            })
        }else{
            window.addSubview(self)
        }
    }
    public func dismiss(){
        if let cell = collectionView?.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? LRLPBImageCell{
            dismissCell(cell)
        }else{
            self.removeFromSuperview()
            self.delegate?.imageSwipViewDismiss(imageView: nil)
        }
    }

    private var dataSource:[LRLPhotoBrowserModel]?
    private var imgContentMode: UIViewContentMode = .scaleAspectFill
    private var initialIndex: Int?
    private var collectionView: LRLPBCollectionView?
    private var pageControl: UIPageControl?
    private var collectionDelegate: LRLPBCollectionDelegate?
    private var delegateHolder: LRLPBCollectionDelegateHolder?
    private var currentIndex:Int = 0
    private var pageType: LRLPBCollectionViewPageType = .slide
    private var pbSuperView: UIWindow?{
        get{
            return UIApplication.shared.keyWindow
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func configUI() {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.scrollDirection = .horizontal
        myLayout.minimumLineSpacing = 0
        myLayout.minimumInteritemSpacing = 0
        
        collectionView = LRLPBCollectionView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), collectionViewLayout: myLayout)
        collectionView?.dismissBlock = dismissCell
        collectionView?.register(LRLPBImageCell.self, forCellWithReuseIdentifier: LRLPBImageCell.reuseIdentifier())
        collectionView?.register(LRLPBVideoCell.self, forCellWithReuseIdentifier: LRLPBVideoCell.reuseIdentifier())
        collectionView?.panEnable = self.animition
        collectionView?.isPagingEnabled = true
        collectionView?.delegate = delegateHolder
        collectionView?.dataSource = delegateHolder
        addSubview(collectionView!)
        
        if let index = initialIndex{
            let index = IndexPath(item: index, section: 0)
            collectionView?.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            collectionView?.reloadData()
        }

        pageControl = UIPageControl()
        pageControl?.numberOfPages = self.dataSource?.count ?? 0
        addSubview(pageControl!)
        pageControl?.addTarget(self, action: #selector(LRLPhotoBrowser.pageControlAct), for: .touchUpInside)
        pageControl?.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-20.0)
        }
        if let index = self.initialIndex {
            pageControl?.currentPage = index
        }        
    }
    
    lazy private var dismissCell: (LRLPBImageCell) -> Void = { [weak self] (dissMissCell) in
        guard let s = self else{
            return
        }
        let imageView = dissMissCell.showView
        func dismiss(){
            imageView.removeFromSuperview()
            s.removeFromSuperview()
            s.delegate?.imageSwipViewDismiss(imageView: imageView.imageView)
        }
        
        imageView.removeFromSuperview()
        if let localView = UIApplication.shared.keyWindow, let loc = s.selectedFrame, s.animition{
            localView.addSubview(imageView)
            UIView.animate(withDuration: 0.3, animations: {
                imageView.setZoomScale(scale: 1.0)
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.frame = loc
                s.alpha = 0.0
            }, completion: { (success) in
                dismiss()
            })
        }else{
            dismiss()
        }
    }
    @objc private func pageControlAct(page: UIPageControl){
        if !(collectionView?.panning ?? true){
            let indexPath = IndexPath(item: page.currentPage, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            hasScrollTo(index: page.currentPage)
        }else{
            page.currentPage = currentIndex
        }
    }
    
    private func hasScrollTo(index:Int){
        if let inImageView = self.delegate?.imageDidScroll(index: index){
            self.selectedFrame = inImageView.superview?.convert(inImageView.frame, to: pbSuperView)
        }
        currentIndex = index
    }
    
    //MARK: UICollectionViewDataSource
     public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = dataSource?[indexPath.row] else { return UICollectionViewCell() }
        let cell:UICollectionViewCell
        switch data {
        //case .videoUrl(url: _, placeHolder: _):
            //cell = collectionView.dequeueReusableCell(withReuseIdentifier: LRLPBVideoCell.reuseIdentifier(), for: indexPath) as! LRLPBVideoCell
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: LRLPBImageCell.reuseIdentifier(), for: indexPath) as! LRLPBImageCell
        }
        switch data {
        case .imageName(let name):
            (cell as! LRLPBImageCell).setData(imageName: name)
        case .imageUrl(let imageUrl, let placeHolder):
            (cell as! LRLPBImageCell).setData(imageUrl: imageUrl, placeHolder: placeHolder)
        case .image(let image):
            (cell as! LRLPBImageCell).setData(image: image)
        //case .videoUrl(url: let videoUrl, placeHolder: let image):
            //(cell as! LRLPBVideoCell).setData(videoUrl: videoUrl, placeHolder: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LRLPBImageCell{
            dismissCell(cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.cellEndDisplay()
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
    }
    
    //MARK: 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pageType == .slide else {
            return
        }
        var offset = scrollView.contentOffset.x/scrollView.bounds.width
        if offset >= 0  && offset < CGFloat(self.dataSource?.count ?? 0){
            let i = floor(offset)
            let j = ceil(offset)
            if i != offset  || j != offset{
                offset = offset - floor(offset)
            }else{
                offset = 1.0
            }
            if self.collectionView?.visibleCells.count ?? 0 == 2 {
                let cell1 = collectionView?.cellForItem(at: IndexPath(item: Int(i), section: 0))
                cell1?.cellChangeTheImageViewLocationWithOffset(offset: offset)
                let cell2 = collectionView?.cellForItem(at: IndexPath(item: Int(j), section: 0))
                cell2?.cellChangeTheImageViewLocationWithOffset(offset: offset - 1.0)
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.bounds.size.width)
        self.pageControl?.currentPage = index
        hasScrollTo(index: index)
    }

    fileprivate class LRLPBCollectionDelegateHolder: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        private override init() {
            fatalError()
        }
        init(delegate: LRLPBCollectionDelegate) {
            collectionDelegate = delegate
        }
        
        fileprivate weak var collectionDelegate: LRLPBCollectionDelegate?
        
        //MARK: UICollectionViewDataSource
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return collectionDelegate?.collectionView(collectionView, cellForItemAt: indexPath) ?? UICollectionViewCell()
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return collectionDelegate?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        }
        
        //MARK: UICollectionViewDelegate
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            collectionDelegate?.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
        
        //MARK: UICollectionViewDelegateFlowLayout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionDelegate?.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
        }
        
        //MARK: UIScrollViewDelegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            collectionDelegate?.scrollViewDidScroll(scrollView)
        }
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
            collectionDelegate?.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
}



fileprivate protocol LRLPBCollectionDelegate: NSObjectProtocol{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
}

