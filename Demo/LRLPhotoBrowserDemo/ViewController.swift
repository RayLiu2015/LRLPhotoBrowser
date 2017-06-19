//
//  ViewController.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/13.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LRLPhotoBrowserDelegate{
    var dataSource:[LRLPhotoBrowserModel] = []
    @IBOutlet weak var collectionView: UICollectionView!
    var imageView: AnimatedImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.append(LRLPhotoBrowserModel.imageUrl(ur: "http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif", placeHolder: UIImage(named: "placeHolder.jpg")))
        for i in 1...7{
            dataSource.append(LRLPhotoBrowserModel.imageName("\(i).jpg"))
        }
        dataSource.append(LRLPhotoBrowserModel.imageUrl(ur: "http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/08/0A/ChMkJ1i9XJmIJnFtABXosJGWaOkAAae8QGrHE8AFejI057.jpg", placeHolder: UIImage(named: "placeHolder.jpg")))
        if let image = UIImage(named: "hehe.JPG"){
            dataSource.append(LRLPhotoBrowserModel.image(image))
        }
        
        dataSource.append(LRLPhotoBrowserModel.videoUrl(url: URL(string: "http://baobab.wdjcdn.com/1463028607774b.mp4")!, placeHolder: UIImage(named: "videoPlaceHolder.png")))

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.register(ImageCell.nib(), forCellWithReuseIdentifier: ImageCell.resuseIde())
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.resuseIde(), for: indexPath) as! ImageCell
        switch dataSource[indexPath.item] {
        case .imageName(let imageName):
            cell.imageView.image = UIImage(named: imageName)
        case .imageUrl(ur: let imageUrl, placeHolder: let placeHolder):
            cell.imageView.kf.setImage(with: URL(string: imageUrl) , placeholder: placeHolder)
        case .image(let image):
            cell.imageView.image = image
        case .videoUrl(url: _, placeHolder: let placeHolder):
            cell.imageView.image = placeHolder
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageCell = collectionView.cellForItem(at: indexPath) as? ImageCell else{
            return
        }
        
        let photoBrowser = LRLPhotoBrowser(dataSource: dataSource, initialIndex: indexPath.item, selectedImageView: imageCell.imageView, delegate: self)

        photoBrowser.show()
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/2 - 1, height: view.bounds.width/2 - 1)
    }
    
    //LRLPhotoBrowserDelegate
    func imageDidScroll(index: Int) -> UIImageView?{
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell{
            return cell.imageView
        }else{
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            return (collectionView.cellForItem(at: indexPath) as? ImageCell)?.imageView
        }
    }
    func imageSwipViewDismiss(imageView: UIImageView?) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
    }
}



