//
//  FriendsTableCellViewController.swift
//  Flare
//
//  Created by Tim Chung on 9/11/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var facebookNameLabel: UILabel!

    @IBOutlet weak var selectFriendImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
