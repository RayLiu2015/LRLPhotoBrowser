//
//  LRLPBTool.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/19.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit

func LRLDLog(_ content: @autoclosure () -> Any){
//    print(content())
}

class LRLPBAssetManager {
    static func getImage(named: String) -> UIImage?{
        if let bundlePath = Bundle(for: self).path(forResource: "LRLPhotoBrowser", ofType: "bundle"){
            let bundle = Bundle(path: bundlePath)
            let image = UIImage(contentsOfFile: bundle?.path(forResource: named, ofType: "png") ?? "")
            return image
        }else{
            return nil
        }
    }
}
