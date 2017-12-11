//
//  SuperUITableViewCell.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/14/17.
//  Copyright © 2017 Tenny. All rights reserved.
//

import UIKit

class SuperUITableViewCell: UITableViewCell {
/*
    @IBOutlet weak var datePublished: UITextView!
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var headlineText: UITextView!
    @IBOutlet weak var minutesAgo: UITextView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var rowID: Int?
*/
    @IBOutlet weak var searchResults: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
