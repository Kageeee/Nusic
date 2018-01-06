//
//  NewsicAlertController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicAlertController : YBAlertController {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init() {
        super.init()
        setupUI()
    }
    
    convenience init(title:String?, message:String?, style: YBAlertControllerStyle) {
        self.init()
        self.title = title
        self.message = message
        self.style = style
    }
    
    func setupUI() {
        super.overlayColor = UIColor.black.withAlphaComponent(0.9)
        
        //Title details
        super.titleFont = NewsicDefaults.font
        super.titleTextColor = NewsicDefaults.greenColor
        
        //Message Details
        super.messageFont = NewsicDefaults.font
        super.messageTextColor = NewsicDefaults.greenColor
        super.messageLabel.backgroundColor = NewsicDefaults.blackColor
        
        //Button Details
        super.buttonFont = NewsicDefaults.font
        super.buttonTextColor = NewsicDefaults.greenColor
        
        //Cancel Button Details
        super.cancelButtonFont = NewsicDefaults.font
        super.cancelButtonTextColor = NewsicDefaults.greenColor
        
    }
    
}
