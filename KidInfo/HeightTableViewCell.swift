//
//  HeightTableViewCell.swift
//  KidInfo
//
//  Created by i814935 on 6/13/17.
//  Copyright © 2017 Chris Manciero. All rights reserved.
//

import UIKit

class HeightTableViewCell: UITableViewCell {

    @IBOutlet weak var txtHeight: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
