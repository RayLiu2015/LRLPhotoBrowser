//
//  LRLPBActionSheetView.swift
//  LRLPhotoBrowserDemo
//
//  Created by liuRuiLong on 2017/6/16.
//  Copyright © 2017年 codeWorm. All rights reserved.
//

import UIKit

class LRLPBActionSheetViewCell: UITableViewCell {
    var title: String?{
        set{
            label?.text = newValue
        }
        get{
            return label?.text
        }
    }
    private var label: UILabel?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label = UILabel(frame: self.contentView.bounds)
        label?.textAlignment = .center
        label?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(label!)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label?.frame = self.contentView.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func reuseIdentifier() -> String{
        return "LRLPBActionSheetViewCell"
    }
}


class LRLPBActionSheetView: UIView, UITableViewDelegate, UITableViewDataSource{
    let itemHeight = 50
    var height: CGFloat {
        get{
            return CGFloat((otherTitle.count + 1) * itemHeight + 10)
        }
    }
    var showFrame: CGRect{
        get{
            return CGRect(x: 0, y: self.bounds.height - height, width: self.bounds.width, height: height)
        }
    }
    var cancleTitle: String = "取消"
    var otherTitle: [String] = []
    var selectedBlock: ((Int) -> Void)?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(cancleTitle: String = "取消", otherTitle: [String], selectedBlock: ((Int) -> Void)?) {
        self.cancleTitle = cancleTitle
        self.otherTitle = otherTitle
        self.selectedBlock = selectedBlock
        super.init(frame: UIScreen.main.bounds)
        self.configUI()
    }
    var tableView: UITableView?

    func configUI() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        tableView = UITableView(frame: CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: height), style: UITableViewStyle.plain)
        tableView?.register(LRLPBActionSheetViewCell.self, forCellReuseIdentifier: LRLPBActionSheetViewCell.reuseIdentifier())
        tableView?.showsVerticalScrollIndicator = false
        tableView?.bounces = false
        tableView?.delegate = self
        tableView?.dataSource = self
        self.addSubview(tableView!)
    }
    
    func show(to: UIView) {
        to.addSubview(self)
        to.bringSubview(toFront: self)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            self.tableView?.frame = self.showFrame
        }, completion: nil)
        
    }
    func dismiss() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { 
            self.tableView?.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: self.height)
            self.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            selectedBlock?(0)
        }else{
            selectedBlock?(indexPath.item + 1)
        }
        dismiss()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }else{
            return 10.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return otherTitle.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LRLPBActionSheetViewCell.reuseIdentifier(), for: indexPath) as! LRLPBActionSheetViewCell
        if indexPath.section == 1 {
            cell.title = cancleTitle
        }else{
            cell.title = otherTitle[indexPath.item]
        }
        return cell
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
        dismiss()
    }
    
}
