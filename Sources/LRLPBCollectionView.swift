//
//  LRLPBCollectionView.swift
//  FeelfelCode
//
//  Created by liuRuiLong on 17/6/6.
//  Copyright © 2017年 李策. All rights reserved.
//

import UIKit
import MBProgressHUD

class LRLPBCollectionView: UICollectionView, UIGestureRecognizerDelegate, UIScrollViewDelegate{
    var panning: Bool{
        get{
            if let p = pan{
                return p.state == .began || p.state == .changed
            }else{
                return false
            }
        }
    }
    var panEnable = false{
        didSet{
            if pan == nil && (panEnable == true){
                self.pan = UIPanGestureRecognizer(target: self, action: #selector(panAct))
                pan!.delegate = self
                self.addGestureRecognizer(pan!)
            }
        }
    }
    var pan: UIPanGestureRecognizer?
    var beginPoint: CGPoint?
    var movePoint: CGPoint?
     var currentCell: LRLPBCell?{
        get{
            return self.visibleCells.first as? LRLPBCell
        }
    }
    var beginTransform: CGAffineTransform = CGAffineTransform()
    var movingTransform: CGAffineTransform = CGAffineTransform()
    lazy var imageBeginFrame: CGRect = {
       return CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height
        )}()
    var scale: CGFloat = 1.0
    
    var dismissBlock: ((_ imageView: LRLPBCell) -> ())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        let twiceTap = UITapGestureRecognizer(target: self, action: #selector(tapAct))
        twiceTap.delegate = self
        twiceTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(twiceTap)
        
        let onceTap = UITapGestureRecognizer(target: self, action: #selector(tapAct))
        onceTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(onceTap)
        onceTap.require(toFail: twiceTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAct))
        self.addGestureRecognizer(longPress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    @objc func didFinishSaved(image:UIImage, error:Error?, contextInfo: UnsafeMutableRawPointer){
        var result = "保存成功"
        if let _ = error {
            result = "保存失败"
        }
        
        let progress = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow ?? self, animated: true)
        progress.mode = .customView
        progress.label.text = result
        progress.hide(animated: true, afterDelay: 1.0)
    }
    

    @objc private func longPressAct(longPress: UILongPressGestureRecognizer){
        switch longPress.state {
        case .began:
            if let currentImage = currentCell?.showView.image {
                let sheetView = LRLPBActionSheetView(otherTitle: ["保存到相册"], selectedBlock: { (index) in
                    if index == 0{
                    }else{
                        UIImageWriteToSavedPhotosAlbum(currentImage, self, #selector(self.didFinishSaved(image:error:contextInfo:)), nil)
                    }
                })
                sheetView.show(to: self.superview!)
            }
        default:
            break
        }
    }
    
    @objc private func tapAct(tap: UITapGestureRecognizer){
        if let cell = currentCell {
            if tap.numberOfTapsRequired == 1 {
                self.dismissBlock?(cell)

            }else{
                if cell.zooming {
                    cell.outZoom()
                }else{
                    cell.inZoom()
                }
                
            }

        }
    }
    

    //MARK: pan
    @objc private func panAct(pan: UIPanGestureRecognizer) {
        func setPanBackColor(color: UIColor){
            
            self.superview?.backgroundColor = color
            self.backgroundColor = color
            self.currentCell?.backgroundColor = color
            self.currentCell?.contentView.backgroundColor = color
        }
        func beganPanning(){
            beginPoint = pan.location(in: currentCell)
            guard let currCell = currentCell else {
                return
            }
            
            beginTransform = currCell.showView.transform
            movingTransform = beginTransform
            imageBeginFrame = currCell.showView.frame
        }
        func panning(){

            guard let curCell = currentCell, let begPoint = beginPoint else {
                return
            }
            let offset = pan.translation(in: currentCell)
            scale = 1.0 - offset.y/curCell.bounds.size.height > 1.0 ? 1.0 : (1.0 - offset.y/curCell.bounds.size.height)
            let movingTransform = beginTransform.translatedBy(x: offset.x - (1 - scale) * (imageBeginFrame.width/2 - begPoint.x), y: offset.y - (1 - scale) * (imageBeginFrame.height/2 - begPoint.y))
            
            curCell.showView.transform = movingTransform
            
            if offset.y > 0{
                curCell.showView.transform = movingTransform.scaledBy(x: scale, y: scale)
            }else{
                curCell.showView.transform = movingTransform
            }
            
            let alpha:CGFloat = 0.4
            let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: scale - alpha)
            setPanBackColor(color: color)
        }
        
        func endPanning(){
            if scale < 1.0, let cCell = currentCell{
                dismissBlock?(cCell)
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.currentCell?.showView.transform = self.beginTransform
//                    self.currentCell?.showView.frame = self.imageBeginFrame
                    let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
                    setPanBackColor(color: color)
                })
            }
        }
        
        switch pan.state {
        case .began:
            beganPanning()
        case .changed:
            panning()
        case .ended:
            endPanning()
        default:
            break
        }
    }
    var tapCount: Int = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        tapCount = tapCount + 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if let cell = self.currentCell {
                if self.tapCount == 1 {
                    self.dismissBlock?(cell)
                }else{
                    if cell.zooming {
                        cell.outZoom()
                    }else{
                        cell.inZoom()
                    }
                }
            }
            self.tapCount = 0
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    //MARK: UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        if pan == gestureRecognizer{
            let velocity = pan!.velocity(in: self)
            if abs(velocity.x) >= abs(velocity.y){
               return false
            }
            return true
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cell = currentCell, let p = pan, p === gestureRecognizer{
            if cell.zoomToTop{
                return true
            }
        }
        return false
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
}
