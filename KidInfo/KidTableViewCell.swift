//
//  KidTableViewCell.swift
//  KidInfo
//
//  Created by i814935 on 6/2/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class KidTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
