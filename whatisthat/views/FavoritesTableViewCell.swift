//
//  FavoritesTableViewCell.swift
//  whatisthat
//
//  Created by 靳亚芳 on 11/30/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
