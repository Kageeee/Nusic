

//
//  SongTableViewSectionHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 02/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SongTableViewSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var displayName: UILabel!
    
    static let reuseIdentifier: String = "SongTableViewHeader"
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongTableViewHeader
        self.displayName = contentView.displayName
        self.contentView.backgroundColor = UIColor.red
        self.addSubview(contentView)
    }
    
}
