//
//  LRLPBVideoView.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/18.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD

class LRLPBVideoView: LRLPBImageView {
    let statuKey            = "status"
    let loadTimeKey         = "loadedTimeRanges"
    let keepUpKey           = "playbackLikelyToKeepUp"
    let bufferEmptyKey      = "playbackBufferEmpty"
    let bufferFullKey       = "playbackBufferFull"
    let presentationSizeKey = "presentationSize"
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var playerUrl: URL?
    var videoSize: CGSize?
    lazy var player: AVPlayer = {
        let p = AVPlayer(playerItem: self.playerItem)
        p.actionAtItemEnd = .advance
        return p
    }()
    lazy var playerItem: AVPlayerItem? = {
        if let url = self.playerUrl{
            let item = AVPlayerItem(url: url)
            item.addObserver(self, forKeyPath: self.statuKey, options: [.new, .old], context: nil)
            item.addObserver(self, forKeyPath: self.loadTimeKey, options: [.new, .old], context: nil)
            item.addObserver(self, forKeyPath: self.keepUpKey, options: [.new, .old], context: nil)
            item.addObserver(self, forKeyPath: self.bufferEmptyKey, options: [.new, .old], context: nil)
            item.addObserver(self, forKeyPath: self.bufferFullKey, options: [.new, .old], context: nil)
            item.addObserver(self, forKeyPath: self.presentationSizeKey, options: [.new, .old], context: nil)
            return item
        }else{
            return nil
        }
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    func configUI(){
        let button = UIButton(frame: CGRect(x: bounds.size.width/2 - 25, y: bounds.size.height/2 - 25, width: 50, height: 50))
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        addSubview(button)
    }
    
    override func updateUI() {
        guard image != nil && self.bounds.size.width > 0 && self.bounds.size.height > 0 else {
            return
        }
        
        switch self.contentMode {
        case .scaleToFill:
            self.updateToScaleToFill()
        case .scaleAspectFit:
            if let inVideoSize = videoSize{
                updateToScaleAspectFit(showSize: inVideoSize, scale: 1.0)
            }else{
                updateToScaleAspectFit(showSize: image!.size, scale: image!.scale)
            }
        case .scaleAspectFill:
            if let inVideoSize = videoSize{
                updateToScaleAspectFill(showSize: inVideoSize, scale: 1.0)
            }else{
                updateToScaleAspectFill(showSize: image!.size, scale: image!.scale)
            }
        default:
            break
        }
        playerLayer.frame = self.imageView.bounds
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
    
    func setVideoUrlStr(url: URL, palceHolder: UIImage?) {
        image = palceHolder
        playerUrl = url
    }
    var progress: MBProgressHUD?
    
    func play() {
        playerLayer.player = player
        playerLayer.frame = self.imageView.bounds
        imageView.layer.addSublayer(playerLayer)
        progress = MBProgressHUD.showAdded(to: self, animated: true)
        progress?.mode = .indeterminate
        player.play()
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let inKeyPath = keyPath, let item = playerItem else {
            return
        }
        switch inKeyPath {
        case statuKey:
            print("statuKey")
            switch item.status {
            case .readyToPlay:
                print("readyToPlay")
                progress?.hide(animated: true)
            case .failed:
                progress?.hide(animated: true)
                print("failed")
            case .unknown:
                progress?.hide(animated: true)
                print("unknown")
            }
        case loadTimeKey:
            print("loadTimeKey")
        case keepUpKey:
            print("keepUpKey")
        case bufferEmptyKey:
            print("bufferEmptyKey")
        case bufferFullKey:
            print("bufferFullKey")
        case presentationSizeKey:
            print("presentationSizeKey")
            videoSize = item.presentationSize
            updateUI()
        default:
            print("statuKey")            
        }
    }
    
    
    override func endDisplay() {
        if zooming{
            outZoom()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
