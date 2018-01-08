//
//  SettingsCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemValue: UILabel!
    @IBOutlet weak var descriptionImage: UIImageView!
    
    //Image View Constraints
    @IBOutlet weak var itemDescriptionLeadingConstraint: NSLayoutConstraint!
    
    
    static let reuseIdentifier = "settingsCell"
    static let rowHeight:CGFloat = 45
    var initialDescriptionConstraintConstant: CGFloat? = nil
    var alertController: NewsicAlertController?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        UIView.animate(withDuration: 0.3, animations: {
            if selected {
                self.backgroundColor = NewsicDefaults.greenColor.withAlphaComponent(0.5)
            } else {
                self.backgroundColor = NewsicDefaults.deselectedColor
            }
        })
        
    }
    
    func configureCell(title: String, value: String, icon: UIImage?, options: [YBButton]? = nil, centerText: Bool? = false, alertText: String? = nil, enableCell: Bool? = true) {
        
        self.backgroundColor = NewsicDefaults.deselectedColor
        self.selectionStyle = .none
        if !self.subviews.contains(where: { (view) -> Bool in
            return view.tag == 1
        }) {
            self.addBlurEffect(style: .dark, alpha: 0.2)
        }
        
        self.itemValue.textColor = UIColor.white
        self.itemDescription.textAlignment = centerText! ? .center : .natural;
        self.itemDescription.textColor = UIColor.lightText
        if let icon = icon {
            self.descriptionImage.image = icon
        }
        else {
            if initialDescriptionConstraintConstant == nil {
                initialDescriptionConstraintConstant = self.descriptionImage.bounds.size.width
                self.itemDescriptionLeadingConstraint.constant += initialDescriptionConstraintConstant!
            }
        }
        
        
        if !enableCell! {
            self.isUserInteractionEnabled = enableCell!
            self.itemValue.textColor = UIColor.gray
        }
        
        itemDescription.text = title
        itemValue.text = value
        
        if let options = options {
            alertController = NewsicAlertController(title: alertText != nil ? alertText! : nil, message: nil, style: YBAlertControllerStyle.ActionSheet)
            for option in options {
                alertController?.addButton(icon: option.icon, title: option.textLabel.text!, action: option.action)
            }
            
        }
    }
    
}
