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
    let keepUpKey           = "playbackLikelyToKeepUp"
    let bufferEmptyKey      = "playbackBufferEmpty"
    let bufferFullKey       = "playbackBufferFull"
    let presentationSizeKey = "presentationSize"
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var playerUrl: URL?
    var videoSize: CGSize?
    
    private lazy var startButton: UIButton = {
        let button = UIButton(frame: CGRect(x: self.bounds.size.width/2 - 25, y:self.bounds.size.height/2 - 25, width: 50, height: 50))
        button.setImage(UIImage(named: "btn_play"), for: .normal)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        return button
    }()
    
    private var _player: AVPlayer?
    var player: AVPlayer?{
        get{
            if let inPlayer = _player{
                return inPlayer
            }else{
                _player = AVPlayer(playerItem: playerItem)
                return _player
            }
        }
        set{
            _player = newValue
        }
    }
    private var _playerItem: AVPlayerItem?
    var playerItem: AVPlayerItem?{
        get{
            if let inPlayerItem = _playerItem{
                return inPlayerItem
            }else{
                if let url = self.playerUrl{
                    _playerItem = AVPlayerItem(url: url)
                    _playerItem?.addObserver(self, forKeyPath: self.statuKey, options: [.new, .old], context: nil)
                    _playerItem?.addObserver(self, forKeyPath: self.keepUpKey, options: [.new, .old], context: nil)
                    _playerItem?.addObserver(self, forKeyPath: self.bufferEmptyKey, options: [.new, .old], context: nil)
                    _playerItem?.addObserver(self, forKeyPath: self.bufferFullKey, options: [.new, .old], context: nil)
                    _playerItem?.addObserver(self, forKeyPath: self.presentationSizeKey, options: [.new, .old], context: nil)
                    return _playerItem
                }else{
                    return nil
                }
            }
        }
        set{
            if newValue == nil{
                _playerItem?.removeObserver(self, forKeyPath: statuKey)
                _playerItem?.removeObserver(self, forKeyPath: keepUpKey)
                _playerItem?.removeObserver(self, forKeyPath: bufferEmptyKey)
                _playerItem?.removeObserver(self, forKeyPath: bufferFullKey)
                _playerItem?.removeObserver(self, forKeyPath: presentationSizeKey)
            }
            _playerItem = newValue
        }
        
        
    }
    
    override var frame: CGRect{
        set{
            super.frame = newValue
            scrollView.frame = super.bounds
            startButton.frame = CGRect(x: self.bounds.size.width/2 - 25, y:self.bounds.size.height/2 - 25, width: 50, height: 50)
            updateUI()
        }
        get{
            return super.frame
        }
    }
    
    deinit {
        player?.pause()
        player = nil
        playerItem = nil
        NotificationCenter.default.removeObserver(self)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(startButton)
        NotificationCenter.default.addObserver(self, selector: #selector(willInBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didInforeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
        progress?.removeFromSuperViewOnHide = false
        progress?.mode = .indeterminate
        progress?.show(animated: true)
        startButton.isHidden = true
        player?.play()
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let inKeyPath = keyPath, let item = playerItem else {
            return
        }
        switch inKeyPath {
        case statuKey:
            LRLDLog("statuKey")
            switch item.status {
            case .readyToPlay:
                LRLDLog("readyToPlay")
            case .failed:
                fallthrough
            case .unknown:
                 progress?.hide(animated: true)
                 let errorAlert = MBProgressHUD.showAdded(to: self, animated: true)
                 errorAlert.mode = .text
                 errorAlert.label.text = "播放失败"
                 errorAlert.hide(animated: true, afterDelay: 1.0)
                LRLDLog("unknown || error")
            }
        case keepUpKey:
            LRLDLog("keepUpKey")
            if item.isPlaybackLikelyToKeepUp {
                progress?.hide(animated: true)
            }
        case bufferEmptyKey:
            LRLDLog("bufferEmptyKey")
            progress?.show(animated: true)
        case bufferFullKey:
            LRLDLog("bufferFullKey")
            progress?.hide(animated: true)
        case presentationSizeKey:
            LRLDLog("presentationSizeKey")
            self.videoSize = item.presentationSize
            UIView.animate(withDuration: 0.3, animations: {
                self.updateUI()
            })
        default:
            break
        }
    }
    
    override func endDisplay() {
        if zooming{
            outZoom()
        }
        progress?.hide(animated: true)
        startButton.isHidden = false
        player?.pause()
        playerLayer.player = nil
        player = nil        
        playerItem = nil
    }
    
    override func updateUI() {
        if self.videoSize == nil{
            guard image != nil && self.bounds.size.width > 0 && self.bounds.size.height > 0 else {
                return
            }
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
    
    func willInBackground() {
        player?.pause()
    }
    func didInforeground() {
        player?.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
