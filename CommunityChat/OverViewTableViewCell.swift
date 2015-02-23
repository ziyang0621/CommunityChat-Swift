//
//  OverViewTableViewCell.swift
//  CommunityChat
//
//  Created by Ziyang Tan on 2/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class OverViewTableViewCell: UITableViewCell {

    @IBOutlet weak var newMessageIndicator: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
