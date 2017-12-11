//
//  TitleTableViewCell.swift
//  project2_NewsFeed
//
//  Created by Tenny on 12/10/17.
//  Copyright © 2017 Tenny. All rights reserved.
//

import UIKit

class TitleTableViewCell: SuperUITableViewCell {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var monthDay: UILabel!
    @IBOutlet weak var weekDay: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
