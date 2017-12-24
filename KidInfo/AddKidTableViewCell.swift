//
//  AddKidTableViewCell.swift
//  KidInfo
//
//  Created by i814935 on 12/24/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class AddKidTableViewCell: UITableViewCell {

    @IBOutlet weak var addIconImageView: UIImageView!
    @IBOutlet weak var lblAddKid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addIconImageView.layer.cornerRadius = addIconImageView.frame.size.width / 2;
        addIconImageView.layer.borderWidth = 3;
        addIconImageView.layer.borderColor = UIColor.white.cgColor;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
